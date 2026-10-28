package com.strongly.strongly.ui;

import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ListPopupWindow;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.strongly.strongly.model.PlanModels;
import com.strongly.strongly.model.PlanState;
import com.strongly.strongly.net.ApiClient;

import java.util.ArrayList;

/** Exercises of one plan day with Start / Restart / Continue (Flutter's DayWorkoutExercisesScreen). */
public class DayExercisesActivity extends AppCompatActivity {
    public static final String EXTRA_PLAN_ID = "planId", EXTRA_DAY = "dayNumber", EXTRA_TITLE = "workoutTitle",
            EXTRA_HERO = "heroImage", EXTRA_DIFFICULTY = "difficultyLevel", EXTRA_IN_PROGRESS = "isInProgress";
    private static final int LIME = Kit.LIME;

    private String planId, title, hero, difficulty;
    private int day;
    private boolean inProgress;
    private final ArrayList<PlanModels.Exercise> exercises = new ArrayList<>();
    private boolean loading = true;
    private FrameLayout root;

    private final ActivityResultLauncher<Intent> premiumLauncher =
            registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), result -> {
                if (com.strongly.strongly.billing.PremiumService.get().isPremium()) fetch(); else finish();
            });

    private final ActivityResultLauncher<Intent> previewLauncher =
            registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), result -> {
                if (PlanState.isStarted(planId, day)) inProgress = true;
                if (result.getResultCode() == RESULT_OK && result.getData() != null) {
                    int elapsed = result.getData().getIntExtra(ExercisePreviewActivity.EXTRA_ELAPSED, 0);
                    submitCompletion(elapsed);
                    PlanState.complete(planId, day);
                }
                render();
            });

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        UiUtil.edgeToEdge(this);
        Intent in = getIntent();
        planId = in.getStringExtra(EXTRA_PLAN_ID);
        if (planId == null) planId = "full_body_burn";
        day = in.getIntExtra(EXTRA_DAY, 1);
        title = in.getStringExtra(EXTRA_TITLE) != null ? in.getStringExtra(EXTRA_TITLE) : "Full Body Burn";
        hero = in.getStringExtra(EXTRA_HERO) != null ? in.getStringExtra(EXTRA_HERO) : "assets/images/image 7 (1).png";
        difficulty = in.getStringExtra(EXTRA_DIFFICULTY) != null ? in.getStringExtra(EXTRA_DIFFICULTY) : "No experience";
        inProgress = in.getBooleanExtra(EXTRA_IN_PROGRESS, false);

        root = new FrameLayout(this);
        root.setBackgroundColor(0xFF0D0D0E);
        setContentView(root);
        render();
        fetch();
    }

    private int dp(float v) { return Kit.dp(this, v); }

    private void fetch() {
        loading = true;
        ApiClient.get().get("/plans/" + planId + "/days/" + day, null, r -> {
            if (isFinishing() || isDestroyed()) return;
            // premium plan on a free account: show the paywall, retry after a purchase or leave
            if (r.statusCode == 403) {
                if (com.strongly.strongly.billing.PremiumService.get().isPremium()) { fetch(); return; }
                premiumLauncher.launch(new Intent(this, GoPremiumActivity.class));
                return;
            }
            exercises.clear();
            if (r.isOk() && r.data != null && r.data.isJsonObject()) {
                JsonObject o = r.data.getAsJsonObject();
                if (o.has("data") && o.get("data").isJsonObject()) o = o.getAsJsonObject("data");
                if (o.has("exercises") && o.get("exercises").isJsonArray())
                    for (JsonElement e : o.getAsJsonArray("exercises"))
                        if (e.isJsonObject()) exercises.add(PlanModels.Exercise.fromJson(e.getAsJsonObject()));
            }
            loading = false;
            render();
        });
    }

    // ------------------------------------------------------------------ actions

    private void openPreview(int index) {
        Intent i = new Intent(this, ExercisePreviewActivity.class);
        i.putExtra(ExercisePreviewActivity.EXTRA_DAY, day);
        i.putExtra(ExercisePreviewActivity.EXTRA_PLAN_ID, planId);
        i.putExtra(ExercisePreviewActivity.EXTRA_TITLE, title);
        i.putExtra(ExercisePreviewActivity.EXTRA_INDEX, index);
        i.putExtra(ExercisePreviewActivity.EXTRA_EXERCISES, exercises);
        previewLauncher.launch(i);
    }

    private void handleStart() {
        inProgress = true;
        PlanState.start(planId, day);
        openPreview(0);
    }

    private void handleRestart() {
        inProgress = false;
        PlanState.restart(planId, day);
        render();
        Kit.snack(root, "Day " + day + " Reset to Start ⏱", 0xB3FFFFFF, 1000);
    }

    private void submitCompletion(int elapsedSeconds) {
        String key = planId + "_day_" + day;
        if (PlanState.SUBMITTED.contains(key)) return;
        PlanState.SUBMITTED.add(key);
        int actual = elapsedSeconds > 0 ? elapsedSeconds : 600;
        int calc = Math.round(actual / 60f * 8.5f);
        int calories = calc > 0 ? calc : 85;
        JsonObject body = new JsonObject();
        body.addProperty("durationSeconds", actual);
        body.addProperty("caloriesBurned", calories);
        ApiClient.get().post("/plans/" + planId + "/days/" + day + "/complete", body, r -> { });
    }

    private void showFinishSheet() {
        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        GradientDrawable bg = new GradientDrawable();
        bg.setColor(0xFF161619);
        float r = dp(26);
        bg.setCornerRadii(new float[]{r, r, r, r, 0, 0, 0, 0});
        content.setBackground(bg);
        content.setPadding(dp(20), dp(20), dp(20), dp(44));
        content.addView(Kit.text(this, "Day " + day + " Session", 18, 800, 0xFFFFFFFF));
        content.addView(Kit.text(this, "Ready to complete today's workout session?", 14, 400, 0x99FFFFFF), Kit.lp(this, -2, -2, 0, 8, 0, 0));

        BottomSheetDialog dialog = new BottomSheetDialog(this);
        dialog.setContentView(content);
        View s = dialog.findViewById(com.google.android.material.R.id.design_bottom_sheet);
        if (s != null) s.setBackgroundColor(0x00000000);
        dialog.getBehavior().setState(BottomSheetBehavior.STATE_EXPANDED);

        LinearLayout btn = new LinearLayout(this);
        btn.setGravity(Gravity.CENTER);
        btn.setBackground(Kit.rounded(this, LIME, 25));
        btn.addView(Icons.view(this, Icons.CHECK_CIRCLE_ROUNDED, 20, 0xFF141416));
        btn.addView(Kit.text(this, "Complete Day " + day, 15, 800, 0xFF141416), Kit.lp(this, -2, -2, 8, 0, 0, 0));
        btn.setOnClickListener(v -> {
            dialog.dismiss();
            submitCompletion(0);
            PlanState.complete(planId, day);
            finish();
        });
        content.addView(btn, Kit.lp(this, -1, dp(50), 0, 20, 0, 0));
        dialog.show();
    }

    // ------------------------------------------------------------------ rendering

    private void render() {
        root.removeAllViews();
        if (loading && exercises.isEmpty()) {
            ProgressBar pb = new ProgressBar(this);
            pb.setIndeterminateTintList(android.content.res.ColorStateList.valueOf(LIME));
            root.addView(pb, new FrameLayout.LayoutParams(dp(36), dp(36), Gravity.CENTER));
            return;
        }

        ScrollView sv = new ScrollView(this);
        sv.setVerticalScrollBarEnabled(false);
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        col.addView(hero());
        col.addView(Kit.text(this, exercises.size() + " Exercises", 16, 700, 0xFFFFFFFF), Kit.lp(this, -2, -2, 20, 24, 20, 14));

        LinearLayout list = new LinearLayout(this);
        list.setOrientation(LinearLayout.VERTICAL);
        for (int i = 0; i < exercises.size(); i++) {
            final int idx = i;
            list.addView(exerciseRow(exercises.get(i), v -> openPreview(idx)), Kit.lp(this, -1, dp(76), 0, 0, 0, 12));
        }
        col.addView(list, Kit.lp(this, -1, -2, 20, 0, 20, 0));
        col.setPadding(0, 0, 0, dp(110));
        UiUtil.padForInsets(col, false, true);
        sv.addView(col);
        root.addView(sv, new FrameLayout.LayoutParams(-1, -1));

        FrameLayout bottom = new FrameLayout(this);
        bottom.setPadding(dp(20), 0, dp(20), dp(16));
        bottom.addView(bottomButtons(), new FrameLayout.LayoutParams(-1, -2));
        UiUtil.padForInsets(bottom, false, true);
        root.addView(bottom, new FrameLayout.LayoutParams(-1, -2, Gravity.BOTTOM));
    }

    private View exerciseRow(PlanModels.Exercise ex, View.OnClickListener click) {
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setBackground(Kit.rounded(this, 0xFF161619, 18, 1, 0x0FFFFFFF));
        row.setPadding(dp(14), dp(10), dp(14), dp(10));
        row.setOnClickListener(click);

        android.widget.ImageView img = new android.widget.ImageView(this);
        img.setScaleType(android.widget.ImageView.ScaleType.FIT_CENTER);
        img.setBackground(Kit.rounded(this, 0xFFFFFFFF, 14));
        img.setClipToOutline(true);
        img.setPadding(dp(4), dp(4), dp(4), dp(4));
        ImageLoader.load(img, ex.imagePath, 0xFFFFFFFF);
        row.addView(img, new LinearLayout.LayoutParams(dp(56), dp(56)));

        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        col.setGravity(Gravity.CENTER_VERTICAL);
        col.addView(Kit.text(this, ex.title, 15, 700, 0xFFFFFFFF));
        col.addView(Kit.text(this, ex.duration, 13, 500, 0x99FFFFFF), Kit.lp(this, -2, -2, 0, 4, 0, 0));
        row.addView(col, Kit.lp(this, 0, -2, 16, 0, 0, 0));
        ((LinearLayout.LayoutParams) col.getLayoutParams()).weight = 1f;
        return row;
    }

    private View hero() {
        FrameLayout h = new FrameLayout(this);
        FrameLayout bg = new FrameLayout(this);
        TopCropImageView img = new TopCropImageView(this);
        ImageLoader.load(img, hero, 0xFF161619);
        bg.addView(img, new FrameLayout.LayoutParams(-1, -1));
        View shade = new View(this);
        shade.setBackground(Kit.stops(new int[]{0xA6000000, 0x33000000, 0xFF0D0D0E}, new float[]{0f, 0.45f, 1f}, true));
        bg.addView(shade, new FrameLayout.LayoutParams(-1, -1));
        h.addView(bg, new FrameLayout.LayoutParams(-1, dp(300)));

        LinearLayout fg = new LinearLayout(this);
        fg.setOrientation(LinearLayout.VERTICAL);
        fg.setPadding(dp(20), dp(8), dp(20), 0);
        UiUtil.padForInsets(fg, true, false);

        LinearLayout top = new LinearLayout(this);
        top.setGravity(Gravity.CENTER_VERTICAL);
        TextView back = Kit.circleIcon(this, Icons.ARROW_BACK_ROUNDED, 20, 38, 0xFF1D1D20, 0x1FFFFFFF);
        back.setOnClickListener(v -> finish());
        top.addView(back);
        top.addView(new View(this), new LinearLayout.LayoutParams(0, 1, 1f));
        TextView more = Kit.circleIcon(this, Icons.MORE_VERT_ROUNDED, 20, 38, 0xFF1D1D20, 0x1FFFFFFF);
        more.setOnClickListener(v -> showMenu(more));
        top.addView(more);
        fg.addView(top, new LinearLayout.LayoutParams(-1, -2));

        fg.addView(Kit.text(this, title + " " + difficulty, 13, 500, 0xB3FFFFFF), Kit.lp(this, -2, -2, 0, 70, 0, 0));
        fg.addView(Kit.text(this, "DAY " + day, 28, 800, 0xFFFFFFFF), Kit.lp(this, -2, -2, 0, 6, 0, 0));
        LinearLayout stats = new LinearLayout(this);
        stats.setGravity(Gravity.CENTER_VERTICAL);
        stats.addView(Icons.view(this, Icons.ACCESS_TIME_ROUNDED, 14, 0xB3FFFFFF));
        stats.addView(Kit.text(this, "10 min", 13, 500, 0xB3FFFFFF), Kit.lp(this, -2, -2, 5, 0, 0, 0));
        stats.addView(Icons.view(this, Icons.FIRE_ROUNDED, 14, 0xB3FFFFFF), Kit.lp(this, -2, -2, 18, 0, 0, 0));
        stats.addView(Kit.text(this, "85 Cal", 13, 500, 0xB3FFFFFF), Kit.lp(this, -2, -2, 5, 0, 0, 0));
        fg.addView(stats, Kit.lp(this, -2, -2, 0, 10, 0, 0));
        h.addView(fg, new FrameLayout.LayoutParams(-1, -2));
        return h;
    }

    private void showMenu(View anchor) {
        ListPopupWindow pw = new ListPopupWindow(this);
        pw.setAnchorView(anchor);
        pw.setModal(true);
        pw.setBackgroundDrawable(Kit.rounded(this, 0xFF1C1C1F, 14, 1, 0x1FFFFFFF));
        pw.setWidth(dp(180));
        pw.setHorizontalOffset(-dp(142));
        pw.setAdapter(new android.widget.BaseAdapter() {
            @Override public int getCount() { return 1; }
            @Override public Object getItem(int i) { return "Complete Day"; }
            @Override public long getItemId(int i) { return i; }
            @Override public View getView(int i, View cv, ViewGroup p) {
                TextView t = Kit.text(DayExercisesActivity.this, "Complete Day", 14, 600, 0xFFFFFFFF);
                t.setPadding(dp(16), dp(14), dp(16), dp(14));
                return t;
            }
        });
        pw.setOnItemClickListener((p, v, pos, id) -> { pw.dismiss(); showFinishSheet(); });
        pw.show();
    }

    private View bottomButtons() {
        if (!inProgress) {
            TextView start = Kit.text(this, "Start", 16, 800, 0xFF141416);
            start.setGravity(Gravity.CENTER);
            start.setBackground(Kit.rounded(this, LIME, 26));
            start.setElevation(dp(8));
            start.setOnClickListener(v -> handleStart());
            start.setLayoutParams(new FrameLayout.LayoutParams(-1, dp(52)));
            return start;
        }
        LinearLayout row = new LinearLayout(this);
        TextView restart = Kit.text(this, "Restart", 15, 700, 0xFFFFFFFF);
        restart.setGravity(Gravity.CENTER);
        restart.setBackground(Kit.rounded(this, 0xFF242428, 26, 1, 0x1FFFFFFF));
        restart.setOnClickListener(v -> handleRestart());
        row.addView(restart, new LinearLayout.LayoutParams(0, dp(52), 1f));
        TextView cont = Kit.text(this, "Continue", 16, 800, 0xFF141416);
        cont.setGravity(Gravity.CENTER);
        cont.setBackground(Kit.rounded(this, LIME, 26));
        cont.setElevation(dp(6));
        cont.setOnClickListener(v -> openPreview(0));
        LinearLayout.LayoutParams cp = new LinearLayout.LayoutParams(0, dp(52), 2f);
        cp.setMarginStart(dp(12));
        row.addView(cont, cp);
        return row;
    }
}
