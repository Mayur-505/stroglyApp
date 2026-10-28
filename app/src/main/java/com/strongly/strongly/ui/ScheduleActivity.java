package com.strongly.strongly.ui;

import android.content.Intent;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ListPopupWindow;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.gson.JsonObject;
import com.strongly.strongly.model.PlanModels;
import com.strongly.strongly.model.PlanState;
import com.strongly.strongly.net.ApiClient;

import java.util.ArrayList;
import java.util.List;

/** "Ready to go" schedule: hero with progress and the full day list (Flutter's WorkoutStartScheduleScreen). */
public class ScheduleActivity extends AppCompatActivity {
    public static final String EXTRA_PLAN_ID = "planId", EXTRA_TITLE = "workoutTitle", EXTRA_HERO = "heroImage",
            EXTRA_DIFFICULTY = "difficultyLevel";
    private static final int LIME = Kit.LIME;

    private String planId, workoutTitle, heroImage, level;
    private List<PlanModels.Day> days = new ArrayList<>();
    private PlanModels.Detail detail;
    private boolean planLocked = false;
    private FrameLayout root;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        UiUtil.edgeToEdge(this);
        planId = getIntent().getStringExtra(EXTRA_PLAN_ID);
        if (planId == null) planId = "full_body_burn";
        workoutTitle = orDefault(getIntent().getStringExtra(EXTRA_TITLE), "Full Body Burn");
        heroImage = orDefault(getIntent().getStringExtra(EXTRA_HERO), "assets/images/image 7 (1).png");
        level = orDefault(getIntent().getStringExtra(EXTRA_DIFFICULTY), "No experience");

        for (int i = 1; i <= 30; i++) days.add(new PlanModels.Day(i, "09-20 min", 0.0, i == 1, false));

        root = new FrameLayout(this);
        root.setBackgroundColor(0xFF0D0D0E);
        setContentView(root);
        render();
        fetch();
    }

    private static String orDefault(String v, String d) { return v == null ? d : v; }

    @Override
    protected void onResume() {
        super.onResume();
        render();
        // a purchase made on the paywall unlocks the plan
        if (planLocked && com.strongly.strongly.billing.PremiumService.get().isPremium()) fetch();
    }

    private void fetch() {
        ApiClient.get().get("/plans/" + planId, null, r -> {
            if (isFinishing() || isDestroyed() || !r.isOk() || r.data == null || !r.data.isJsonObject()) return;
            JsonObject o = r.data.getAsJsonObject();
            if (o.has("data") && o.get("data").isJsonObject()) o = o.getAsJsonObject("data");
            planLocked = o.has("isLocked") && !o.get("isLocked").isJsonNull() && o.get("isLocked").getAsBoolean();
            detail = PlanModels.Detail.fromJson(o);
            if (!detail.days.isEmpty()) days = detail.days;
            render();
        });
    }

    private int dp(float v) { return Kit.dp(this, v); }

    private List<PlanModels.Day> shownDays() {
        List<PlanModels.Day> out = new ArrayList<>();
        for (PlanModels.Day d : days) out.add(PlanState.apply(planId, d));
        return out;
    }

    private void render() {
        root.removeAllViews();
        List<PlanModels.Day> list = shownDays();
        int completed = 0;
        for (PlanModels.Day d : list) if (d.isCompleted) completed++;
        double overall = list.isEmpty() ? 0.0 : (double) completed / list.size();

        ScrollView sv = new ScrollView(this);
        sv.setVerticalScrollBarEnabled(false);
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        col.addView(hero(completed, list.size(), overall));

        LinearLayout dayList = new LinearLayout(this);
        dayList.setOrientation(LinearLayout.VERTICAL);
        for (PlanModels.Day d : list) {
            dayList.addView(DayCard.buildAlwaysTappable(this, d, v -> onDayTapped(d)), Kit.lp(this, -1, -2, 0, 0, 0, 12));
        }
        col.addView(dayList, Kit.lp(this, -1, -2, 20, 20, 20, 0));
        col.setPadding(0, 0, 0, dp(30));
        UiUtil.padForInsets(col, false, true);
        sv.addView(col);
        root.addView(sv, new FrameLayout.LayoutParams(-1, -1));
    }

    private View hero(int completed, int total, double overall) {
        FrameLayout hero = new FrameLayout(this);
        FrameLayout bg = new FrameLayout(this);
        TopCropImageView img = new TopCropImageView(this);
        ImageLoader.load(img, heroImage, 0xFF161619);
        bg.addView(img, new FrameLayout.LayoutParams(-1, -1));
        View shade = new View(this);
        shade.setBackground(Kit.stops(new int[]{0xA6000000, 0x33000000, 0xFF0D0D0E}, new float[]{0f, 0.45f, 1f}, true));
        bg.addView(shade, new FrameLayout.LayoutParams(-1, -1));
        hero.addView(bg, new FrameLayout.LayoutParams(-1, dp(310)));

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
        TextView help = Kit.circleIcon(this, Icons.HELP_OUTLINE_ROUNDED, 19, 38, 0xFF1D1D20, 0x1FFFFFFF);
        help.setOnClickListener(v -> showPlanInfo());
        top.addView(help);
        TextView more = Kit.circleIcon(this, Icons.MORE_VERT_ROUNDED, 20, 38, 0xFF1D1D20, 0x1FFFFFFF);
        ((LinearLayout.LayoutParams) more.getLayoutParams()).setMarginStart(dp(10));
        more.setOnClickListener(v -> showMenu(more));
        top.addView(more);
        fg.addView(top, new LinearLayout.LayoutParams(-1, -2));

        fg.addView(Kit.text(this, workoutTitle, 24, 800, 0xFFFFFFFF), Kit.lp(this, -2, -2, 0, 60, 0, 0));
        fg.addView(Kit.text(this, level, 13, 500, 0xB3FFFFFF), Kit.lp(this, -2, -2, 0, 6, 0, 0));

        LinearLayout count = new LinearLayout(this);
        count.setGravity(Gravity.BOTTOM);
        count.addView(Kit.text(this, completed + " / " + total, 15, 800, 0xFFFFFFFF));
        count.addView(Kit.text(this, " Days Finished", 14, 500, 0xB3FFFFFF));
        fg.addView(count, Kit.lp(this, -2, -2, 0, 10, 0, 0));

        FrameLayout track = new FrameLayout(this);
        track.setBackground(Kit.rounded(this, 0xFF28282D, 3));
        View fill = new View(this);
        fill.setBackground(Kit.rounded(this, LIME, 3));
        track.addView(fill, new FrameLayout.LayoutParams(0, -1));
        fg.addView(track, Kit.lp(this, -1, dp(6), 0, 12, 0, 0));
        track.post(() -> {
            fill.getLayoutParams().width = (int) (track.getWidth() * Math.max(0, Math.min(1, overall)));
            fill.requestLayout();
        });
        hero.addView(fg, new FrameLayout.LayoutParams(-1, -2));
        return hero;
    }

    // ------------------------------------------------------------------ actions

    private void onDayTapped(PlanModels.Day day) {
        if (planLocked) {
            GoPremiumActivity.open(this);
            return;
        }
        if (!day.isUnlocked) {
            Kit.snack(root, "Complete previous days to unlock Day " + day.dayNumber + " 🔒", 0xB3FFFFFF, 1000);
            return;
        }
        Intent i = new Intent(this, DayExercisesActivity.class);
        i.putExtra(DayExercisesActivity.EXTRA_PLAN_ID, planId);
        i.putExtra(DayExercisesActivity.EXTRA_DAY, day.dayNumber);
        i.putExtra(DayExercisesActivity.EXTRA_TITLE, workoutTitle);
        i.putExtra(DayExercisesActivity.EXTRA_HERO, heroImage);
        i.putExtra(DayExercisesActivity.EXTRA_DIFFICULTY, level);
        i.putExtra(DayExercisesActivity.EXTRA_IN_PROGRESS, day.isInProgress());
        startActivity(i);
    }

    private void showMenu(View anchor) {
        ListPopupWindow pw = new ListPopupWindow(this);
        pw.setAnchorView(anchor);
        pw.setModal(true);
        pw.setBackgroundDrawable(Kit.rounded(this, 0xFF1C1C1F, 14, 1, 0x1FFFFFFF));
        pw.setWidth(dp(170));
        pw.setHorizontalOffset(-dp(132));
        final String[] items = {"Choose level", "Plan info"};
        pw.setAdapter(new android.widget.BaseAdapter() {
            @Override public int getCount() { return items.length; }
            @Override public Object getItem(int i) { return items[i]; }
            @Override public long getItemId(int i) { return i; }
            @Override public View getView(int i, View cv, ViewGroup p) {
                TextView t = Kit.text(ScheduleActivity.this, items[i], 14, 600, 0xFFFFFFFF);
                t.setPadding(dp(16), dp(14), dp(16), dp(14));
                return t;
            }
        });
        pw.setOnItemClickListener((p, v, pos, id) -> {
            pw.dismiss();
            if (pos == 0) showChooseLevel(); else showPlanInfo();
        });
        pw.show();
    }

    private BottomSheetDialog sheet(LinearLayout content, boolean tall) {
        BottomSheetDialog d = new BottomSheetDialog(this);
        d.setContentView(content);
        View s = d.findViewById(com.google.android.material.R.id.design_bottom_sheet);
        if (s != null) s.setBackgroundColor(0x00000000);
        d.getBehavior().setState(BottomSheetBehavior.STATE_EXPANDED);
        return d;
    }

    private void showChooseLevel() {
        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        android.graphics.drawable.GradientDrawable bg = new android.graphics.drawable.GradientDrawable();
        bg.setColor(0xFF161619);
        float r = dp(26);
        bg.setCornerRadii(new float[]{r, r, r, r, 0, 0, 0, 0});
        content.setBackground(bg);
        content.setPadding(dp(20), dp(20), dp(20), dp(44));
        content.addView(Kit.text(this, "Choose Difficulty Level", 18, 800, 0xFFFFFFFF));
        BottomSheetDialog dialog = sheet(content, false);
        String[] levels = {"No experience", "Beginner", "Advanced", "Expert", "Pro"};
        for (String lvl : levels) {
            boolean sel = lvl.equals(level);
            LinearLayout row = new LinearLayout(this);
            row.setGravity(Gravity.CENTER_VERTICAL);
            row.setPadding(dp(18), dp(14), dp(18), dp(14));
            row.setBackground(Kit.rounded(this, sel ? 0x26A3D223 : 0xFF202024, 14, 1, sel ? LIME : 0x0FFFFFFF));
            row.addView(Kit.text(this, lvl, 15, 700, sel ? LIME : 0xFFFFFFFF), new LinearLayout.LayoutParams(0, -2, 1f));
            if (sel) row.addView(Icons.view(this, Icons.CHECK_ROUNDED, 18, LIME));
            row.setOnClickListener(v -> { level = lvl; dialog.dismiss(); render(); });
            content.addView(row, Kit.lp(this, -1, -2, 0, lvl.equals(levels[0]) ? 16 : 0, 0, 10));
        }
        dialog.show();
    }

    private View intensity(String label, int filled) {
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        col.addView(Kit.text(this, label, 12, 500, 0xB3FFFFFF));
        LinearLayout bars = new LinearLayout(this);
        for (int i = 0; i < 3; i++) {
            View b = new View(this);
            b.setBackground(Kit.rounded(this, i < filled ? 0xFFFFFFFF : 0x33FFFFFF, 2));
            bars.addView(b, Kit.lp(this, dp(14), dp(4), 0, 0, 3, 0));
        }
        col.addView(bars, Kit.lp(this, -2, -2, 0, 4, 0, 0));
        return col;
    }

    private void showPlanInfo() {
        PlanModels.Detail dt = detail;
        int strength = dt != null ? dt.strengthLevel : 2, cardio = dt != null ? dt.cardioLevel : 2;
        int totalDays = dt != null ? dt.totalDays : 30;
        String daily = dt != null ? dt.dailyDuration : "8-15";
        String p1 = dt != null ? dt.description1 : "Get ready to move, sweat, and feel stronger with a complete workout designed to activate your entire body in just 20 minutes.";
        String p2 = dt != null ? dt.description2 : "No matter where you are starting from, all you need is 20 minutes and the determination to show up.";

        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        android.graphics.drawable.GradientDrawable bg = new android.graphics.drawable.GradientDrawable();
        bg.setColor(0xFF141416);
        float rr = dp(28);
        bg.setCornerRadii(new float[]{rr, rr, rr, rr, 0, 0, 0, 0});
        content.setBackground(bg);
        content.setClipToOutline(true);
        int h = (int) (getResources().getDisplayMetrics().heightPixels * 0.85f);
        content.setLayoutParams(new ViewGroup.LayoutParams(-1, h));

        ScrollView sv = new ScrollView(this);
        sv.setVerticalScrollBarEnabled(false);
        LinearLayout inner = new LinearLayout(this);
        inner.setOrientation(LinearLayout.VERTICAL);

        FrameLayout hero = new FrameLayout(this);
        TopCropImageView img = new TopCropImageView(this);
        ImageLoader.load(img, heroImage, 0xFF161619);
        hero.addView(img, new FrameLayout.LayoutParams(-1, -1));
        View shade = new View(this);
        shade.setBackground(Kit.stops(new int[]{0x73000000, 0x00000000, 0xFF141416}, new float[]{0f, 0.45f, 1f}, true));
        hero.addView(shade, new FrameLayout.LayoutParams(-1, -1));
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.BOTTOM);
        row.setPadding(dp(20), dp(14), dp(20), dp(14));
        LinearLayout left = new LinearLayout(this);
        left.setOrientation(LinearLayout.VERTICAL);
        left.addView(Kit.text(this, workoutTitle, 24, 800, 0xFFFFFFFF));
        LinearLayout bars = new LinearLayout(this);
        bars.addView(intensity("Strength", strength));
        bars.addView(intensity("Cardio", cardio), Kit.lp(this, -2, -2, 16, 0, 0, 0));
        left.addView(bars, Kit.lp(this, -2, -2, 0, 10, 0, 0));
        row.addView(left, new LinearLayout.LayoutParams(0, -2, 1f));
        LinearLayout right = new LinearLayout(this);
        right.setOrientation(LinearLayout.VERTICAL);
        right.setGravity(Gravity.END);
        right.addView(Kit.text(this, String.valueOf(totalDays), 22, 800, 0xFFFFFFFF));
        right.addView(Kit.text(this, "Days", 11, 600, 0xB3FFFFFF));
        right.addView(Kit.text(this, daily, 19, 800, 0xFFFFFFFF), Kit.lp(this, -2, -2, 0, 12, 0, 0));
        TextView per = Kit.text(this, "Minutes\nper day", 10, 500, 0xA6FFFFFF);
        per.setGravity(Gravity.END);
        right.addView(per);
        row.addView(right);
        hero.addView(row, new FrameLayout.LayoutParams(-1, -1, Gravity.BOTTOM));
        inner.addView(hero, new LinearLayout.LayoutParams(-1, dp(250)));

        TextView t1 = Kit.text(this, p1, 13, 400, 0xA6FFFFFF);
        t1.setLineSpacing(0, 1.18f);
        TextView t2 = Kit.text(this, p2, 13, 400, 0xA6FFFFFF);
        t2.setLineSpacing(0, 1.18f);
        inner.addView(t1, Kit.lp(this, -1, -2, 20, 20, 20, 0));
        inner.addView(t2, Kit.lp(this, -1, -2, 20, 14, 20, 24));
        sv.addView(inner);
        content.addView(sv, new LinearLayout.LayoutParams(-1, 0, 1f));

        BottomSheetDialog dialog = sheet(content, true);
        TextView close = Kit.text(this, "Close", 16, 800, 0xFF141416);
        close.setGravity(Gravity.CENTER);
        close.setBackground(Kit.rounded(this, LIME, 26));
        close.setOnClickListener(v -> dialog.dismiss());
        content.addView(close, Kit.lp(this, -1, dp(52), 20, 12, 20, 24));
        dialog.show();
    }
}
