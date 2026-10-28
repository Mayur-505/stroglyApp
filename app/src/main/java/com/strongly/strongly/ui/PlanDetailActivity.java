package com.strongly.strongly.ui;

import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.google.gson.JsonObject;
import com.strongly.strongly.model.PlanModels;
import com.strongly.strongly.model.PlanState;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.net.ApiConstants;

/** Workout plan overview: hero, description and the day list (Flutter's WorkoutDetailPlanScreen). */
public class PlanDetailActivity extends AppCompatActivity {
    public static final String EXTRA_PLAN_ID = "planId", EXTRA_TITLE = "title", EXTRA_HERO = "heroImage",
            EXTRA_DIFFICULTY = "difficultyLevel";
    private static final int LIME = Kit.LIME;

    private String planId, difficulty;
    private PlanModels.Detail detail;
    private boolean loading = true;
    private FrameLayout root;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        UiUtil.edgeToEdge(this);
        planId = getIntent().getStringExtra(EXTRA_PLAN_ID);
        if (planId == null) planId = "full_body_burn";
        difficulty = getIntent().getStringExtra(EXTRA_DIFFICULTY);
        root = new FrameLayout(this);
        root.setBackgroundColor(0xFF0D0D0E);
        setContentView(root);
        render();
        fetch();
    }

    @Override
    protected void onResume() {
        super.onResume();
        // day progress may have changed after completing a day
        if (detail != null) render();
    }

    private void fetch() {
        ApiClient.get().get("/plans/" + planId, null, r -> {
            if (isFinishing() || isDestroyed()) return;
            detail = null;
            if (r.isOk() && r.data != null && r.data.isJsonObject()) {
                JsonObject o = r.data.getAsJsonObject();
                if (o.has("data") && o.get("data").isJsonObject()) o = o.getAsJsonObject("data");
                detail = PlanModels.Detail.fromJson(o);
            }
            loading = false;
            render();
        });
    }

    private int dp(float v) { return Kit.dp(this, v); }

    private void render() {
        root.removeAllViews();
        if (loading && detail == null) {
            ProgressBar pb = new ProgressBar(this);
            pb.setIndeterminateTintList(android.content.res.ColorStateList.valueOf(LIME));
            root.addView(pb, new FrameLayout.LayoutParams(dp(36), dp(36), Gravity.CENTER));
            return;
        }
        if (detail == null) {
            TextView back = Icons.view(this, Icons.ARROW_BACK_ROUNDED, 26, 0xFFFFFFFF);
            back.setOnClickListener(v -> finish());
            FrameLayout.LayoutParams bp = new FrameLayout.LayoutParams(dp(48), dp(48), Gravity.TOP | Gravity.START);
            bp.topMargin = dp(40);
            root.addView(back, bp);
            root.addView(Kit.text(this, "Unable to load workout plan.", 14, 400, 0xB3FFFFFF),
                    new FrameLayout.LayoutParams(-2, -2, Gravity.CENTER));
            return;
        }

        ScrollView sv = new ScrollView(this);
        sv.setVerticalScrollBarEnabled(false);
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        col.addView(hero());

        LinearLayout desc = new LinearLayout(this);
        desc.setOrientation(LinearLayout.VERTICAL);
        TextView p1 = Kit.text(this, detail.description1, 13, 400, 0xA6FFFFFF);
        p1.setLineSpacing(0, 1.15f);
        TextView p2 = Kit.text(this, detail.description2, 13, 400, 0xA6FFFFFF);
        p2.setLineSpacing(0, 1.15f);
        desc.addView(p1);
        desc.addView(p2, Kit.lp(this, -2, -2, 0, 14, 0, 0));
        col.addView(desc, Kit.lp(this, -1, -2, 20, 18, 20, 0));

        LinearLayout days = new LinearLayout(this);
        days.setOrientation(LinearLayout.VERTICAL);
        for (PlanModels.Day d : detail.days) {
            PlanModels.Day shown = PlanState.apply(planId, d);
            days.addView(DayCard.build(this, shown, v -> openDay(shown.dayNumber)), Kit.lp(this, -1, -2, 0, 0, 0, 12));
        }
        col.addView(days, Kit.lp(this, -1, -2, 20, 24, 20, 0));
        col.setPadding(0, 0, 0, dp(100));
        sv.addView(col);
        UiUtil.padForInsets(col, false, true);
        root.addView(sv, new FrameLayout.LayoutParams(-1, -1));

        // sticky "Ready to go!" button
        LinearLayout btn = new LinearLayout(this);
        btn.setGravity(Gravity.CENTER);
        btn.setBackground(Kit.rounded(this, LIME, 27));
        btn.setElevation(dp(8));
        btn.addView(Kit.text(this, "Ready to go!", 16, 800, 0xFF141416));
        btn.addView(Icons.view(this, Icons.ARROW_FORWARD_ROUNDED, 20, 0xFF141416), Kit.lp(this, -2, -2, 8, 0, 0, 0));
        btn.setOnClickListener(v -> openSchedule());
        FrameLayout wrap = new FrameLayout(this);
        wrap.setPadding(dp(20), 0, dp(20), dp(18));
        wrap.addView(btn, new FrameLayout.LayoutParams(-1, dp(54)));
        UiUtil.padForInsets(wrap, false, true);
        root.addView(wrap, new FrameLayout.LayoutParams(-1, -2, Gravity.BOTTOM));
    }

    private View hero() {
        FrameLayout hero = new FrameLayout(this);
        FrameLayout bg = new FrameLayout(this);
        TopCropImageView img = new TopCropImageView(this);
        ImageLoader.load(img, detail.heroImage, 0xFF161619);
        bg.addView(img, new FrameLayout.LayoutParams(-1, -1));
        View shade = new View(this);
        shade.setBackground(Kit.stops(new int[]{0xA6000000, 0x33000000, 0xFF0D0D0E}, new float[]{0f, 0.4f, 1f}, true));
        bg.addView(shade, new FrameLayout.LayoutParams(-1, -1));
        hero.addView(bg, new FrameLayout.LayoutParams(-1, dp(310)));

        LinearLayout fg = new LinearLayout(this);
        fg.setOrientation(LinearLayout.VERTICAL);
        fg.setPadding(dp(20), dp(8), dp(20), 0);
        UiUtil.padForInsets(fg, true, false);

        TextView back = Icons.view(this, Icons.ARROW_BACK_ROUNDED, 26, 0xFFFFFFFF);
        back.setOnClickListener(v -> finish());
        fg.addView(back, new LinearLayout.LayoutParams(dp(40), dp(40)));

        FrameLayout row = new FrameLayout(this);
        LinearLayout left = new LinearLayout(this);
        left.setOrientation(LinearLayout.VERTICAL);
        TextView title = Kit.text(this, detail.title, 26, 800, 0xFFFFFFFF);
        title.setLineSpacing(0, 0.92f);
        left.addView(title);
        LinearLayout bars = new LinearLayout(this);
        bars.addView(intensity("Strength", detail.strengthLevel));
        bars.addView(intensity("Cardio", detail.cardioLevel), Kit.lp(this, -2, -2, 20, 0, 0, 0));
        left.addView(bars, Kit.lp(this, -2, -2, 0, 16, 0, 0));
        left.setPadding(0, 0, dp(110), 0);
        row.addView(left, new FrameLayout.LayoutParams(-1, -2, Gravity.START | Gravity.BOTTOM));

        LinearLayout right = new LinearLayout(this);
        right.setOrientation(LinearLayout.VERTICAL);
        right.setGravity(Gravity.END);
        LinearLayout daysRow = new LinearLayout(this);
        daysRow.setGravity(Gravity.BOTTOM | Gravity.END);
        daysRow.addView(Kit.text(this, String.valueOf(detail.totalDays), 24, 800, 0xFFFFFFFF));
        daysRow.addView(Kit.text(this, "Days", 12, 600, 0xB3FFFFFF), Kit.lp(this, -2, -2, 4, 0, 0, 3));
        right.addView(daysRow, new LinearLayout.LayoutParams(-1, -2));
        LinearLayout mins = new LinearLayout(this);
        mins.setOrientation(LinearLayout.VERTICAL);
        mins.setGravity(Gravity.END);
        mins.addView(Kit.text(this, detail.dailyDuration, 22, 800, 0xFFFFFFFF));
        TextView per = Kit.text(this, "Minutes\nper day", 10, 500, 0x99FFFFFF);
        per.setGravity(Gravity.END);
        per.setLineSpacing(0, 0.95f);
        mins.addView(per);
        right.addView(mins, Kit.lp(this, -2, -2, 0, 14, 0, 0));
        row.addView(right, new FrameLayout.LayoutParams(dp(110), -2, Gravity.END | Gravity.BOTTOM));
        fg.addView(row, Kit.lp(this, -1, -2, 0, 50, 0, 0));
        hero.addView(fg, new FrameLayout.LayoutParams(-1, -2));
        return hero;
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
        col.addView(bars, Kit.lp(this, -2, -2, 0, 5, 0, 0));
        return col;
    }

    private String diff() { return difficulty != null ? difficulty : "No experience"; }

    private void openDay(int dayNumber) {
        Intent i = new Intent(this, DayExercisesActivity.class);
        i.putExtra(DayExercisesActivity.EXTRA_PLAN_ID, planId);
        i.putExtra(DayExercisesActivity.EXTRA_DAY, dayNumber);
        i.putExtra(DayExercisesActivity.EXTRA_TITLE, detail.title);
        i.putExtra(DayExercisesActivity.EXTRA_HERO, detail.heroImage);
        i.putExtra(DayExercisesActivity.EXTRA_DIFFICULTY, diff());
        startActivity(i);
    }

    private void openSchedule() {
        Intent i = new Intent(this, ScheduleActivity.class);
        i.putExtra(ScheduleActivity.EXTRA_PLAN_ID, planId);
        i.putExtra(ScheduleActivity.EXTRA_TITLE, detail.title);
        i.putExtra(ScheduleActivity.EXTRA_HERO, detail.heroImage);
        i.putExtra(ScheduleActivity.EXTRA_DIFFICULTY, diff());
        startActivity(i);
    }
}
