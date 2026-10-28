package com.strongly.strongly.ui;

import android.content.Intent;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

import com.strongly.strongly.model.PlanModels;
import com.strongly.strongly.model.PlanState;

import java.util.ArrayList;

/** Browse a day's exercises one at a time before starting (Flutter's ExercisePreviewScreen). */
public class ExercisePreviewActivity extends AppCompatActivity {
    public static final String EXTRA_DAY = "dayNumber", EXTRA_PLAN_ID = "planId", EXTRA_TITLE = "workoutTitle",
            EXTRA_INDEX = "initialIndex", EXTRA_EXERCISES = "exercises", EXTRA_ELAPSED = "elapsedSeconds";
    private static final int LIME = Kit.LIME;

    private ArrayList<PlanModels.Exercise> exercises = new ArrayList<>();
    private int index = 0, day;
    private String planId, title;
    private FrameLayout root;

    private final ActivityResultLauncher<Intent> activeLauncher =
            registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), result -> {
                if (result.getResultCode() == RESULT_OK && result.getData() != null) {
                    Intent out = new Intent();
                    out.putExtra(EXTRA_ELAPSED, result.getData().getIntExtra(EXTRA_ELAPSED, 0));
                    setResult(RESULT_OK, out);
                    finish();
                }
            });

    @SuppressWarnings("unchecked")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        UiUtil.edgeToEdge(this);
        Intent in = getIntent();
        day = in.getIntExtra(EXTRA_DAY, 1);
        planId = in.getStringExtra(EXTRA_PLAN_ID);
        title = in.getStringExtra(EXTRA_TITLE) != null ? in.getStringExtra(EXTRA_TITLE) : "Full Body Burn";
        Object ex = in.getSerializableExtra(EXTRA_EXERCISES);
        if (ex instanceof ArrayList) exercises = (ArrayList<PlanModels.Exercise>) ex;
        int i = in.getIntExtra(EXTRA_INDEX, 0);
        index = i >= 0 && i < exercises.size() ? i : 0;

        root = new FrameLayout(this);
        root.setBackgroundColor(0xFF0D0D0E);
        UiUtil.padForInsets(root, true, true);
        setContentView(root);
        render();
    }

    private int dp(float v) { return Kit.dp(this, v); }

    private void render() {
        root.removeAllViews();
        LinearLayout page = new LinearLayout(this);
        page.setOrientation(LinearLayout.VERTICAL);
        root.addView(page, new FrameLayout.LayoutParams(-1, -1));

        if (exercises.isEmpty()) {
            TextView back = Icons.view(this, Icons.ARROW_BACK_ROUNDED, 24, 0xFFFFFFFF);
            back.setOnClickListener(v -> finish());
            page.addView(back, Kit.lp(this, dp(48), dp(48), 8, 8, 0, 0));
            TextView msg = Kit.text(this, "No exercises available for this workout.", 14, 400, 0xB3FFFFFF);
            msg.setGravity(Gravity.CENTER);
            page.addView(msg, new LinearLayout.LayoutParams(-1, 0, 1f));
            return;
        }
        PlanModels.Exercise cur = exercises.get(index);

        // top bar: back, < 1/13 >
        LinearLayout bar = new LinearLayout(this);
        bar.setGravity(Gravity.CENTER_VERTICAL);
        bar.setPadding(dp(20), dp(12), dp(20), dp(12));
        TextView back = Kit.circleIcon(this, Icons.ARROW_BACK_ROUNDED, 20, 38, 0xFF1D1D20, 0x1AFFFFFF);
        back.setOnClickListener(v -> finish());
        bar.addView(back);
        bar.addView(new View(this), new LinearLayout.LayoutParams(0, 1, 1f));
        boolean canPrev = index > 0, canNext = index < exercises.size() - 1;
        TextView prev = Kit.circleIcon(this, Icons.CHEVRON_LEFT_ROUNDED, 20, 32, 0xFF1D1D20, 0x14FFFFFF);
        prev.setTextColor(canPrev ? 0xFFFFFFFF : 0x3DFFFFFF);
        if (canPrev) prev.setOnClickListener(v -> { index--; render(); });
        bar.addView(prev);
        bar.addView(Kit.text(this, (index + 1) + "/" + exercises.size(), 14, 700, 0xFFFFFFFF), Kit.lp(this, -2, -2, 10, 0, 10, 0));
        TextView next = Kit.circleIcon(this, Icons.CHEVRON_RIGHT_ROUNDED, 20, 32, 0xFF1D1D20, 0x14FFFFFF);
        next.setTextColor(canNext ? 0xFFFFFFFF : 0x3DFFFFFF);
        if (canNext) next.setOnClickListener(v -> { index++; render(); });
        bar.addView(next);
        page.addView(bar, new LinearLayout.LayoutParams(-1, -2));

        ScrollView sv = new ScrollView(this);
        sv.setVerticalScrollBarEnabled(false);
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        col.setPadding(dp(20), dp(8), dp(20), dp(20));

        col.addView(Kit.text(this, cur.title, 24, 800, 0xFFFFFFFF));
        TextView area = Kit.text(this, cur.targetArea, 12, 500, 0xB3FFFFFF);
        area.setBackground(Kit.rounded(this, 0xFF1C1C1F, 14, 1, 0x14FFFFFF));
        area.setPadding(dp(14), dp(5), dp(14), dp(5));
        col.addView(area, Kit.lp(this, -2, -2, 0, 8, 0, 0));

        FrameLayout card = new FrameLayout(this);
        card.setBackground(Kit.rounded(this, 0xFFFFFFFF, 20));
        card.setClipToOutline(true);
        ImageView img = new ImageView(this);
        img.setScaleType(ImageView.ScaleType.FIT_CENTER);
        ImageLoader.load(img, cur.imagePath, 0xFFFFFFFF);
        card.addView(img, new FrameLayout.LayoutParams(-1, -1));
        card.setPadding(dp(16), dp(16), dp(16), dp(16));
        col.addView(card, Kit.lp(this, -1, dp(280), 0, 18, 0, 0));

        col.addView(Kit.text(this, cur.title, 18, 800, 0xFFFFFFFF), Kit.lp(this, -2, -2, 0, 24, 0, 12));
        for (String s : cur.instructions) col.addView(bullet(s));
        col.addView(Kit.text(this, "Key Tips", 18, 800, 0xFFFFFFFF), Kit.lp(this, -2, -2, 0, 22, 0, 12));
        for (String s : cur.keyTips) col.addView(bullet(s));
        sv.addView(col);
        page.addView(sv, new LinearLayout.LayoutParams(-1, 0, 1f));

        TextView start = Kit.text(this, "Start", 16, 800, 0xFF141416);
        start.setGravity(Gravity.CENTER);
        start.setBackground(Kit.rounded(this, LIME, 26));
        start.setOnClickListener(v -> startWorkout());
        page.addView(start, Kit.lp(this, -1, dp(52), 20, 8, 20, 16));
    }

    private View bullet(String text) {
        LinearLayout row = new LinearLayout(this);
        TextView star = Kit.text(this, "✦", 11, 400, 0xFFFFFFFF);
        row.addView(star, Kit.lp(this, -2, -2, 0, 3, 10, 0));
        star.setIncludeFontPadding(false);
        TextView t = Kit.text(this, text, 13, 400, 0xB3FFFFFF);
        t.setLineSpacing(0, 1.18f);
        row.addView(t, new LinearLayout.LayoutParams(0, -2, 1f));
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(-1, -2);
        lp.bottomMargin = dp(10);
        row.setLayoutParams(lp);
        return row;
    }

    private void startWorkout() {
        if (planId != null && !PlanState.isStarted(planId, day)) PlanState.start(planId, day);
        Intent i = new Intent(this, ActiveWorkoutActivity.class);
        i.putExtra(ActiveWorkoutActivity.EXTRA_DAY, day);
        i.putExtra(ActiveWorkoutActivity.EXTRA_TITLE, title);
        i.putExtra(ActiveWorkoutActivity.EXTRA_INDEX, index);
        i.putExtra(ActiveWorkoutActivity.EXTRA_EXERCISES, exercises);
        activeLauncher.launch(i);
    }
}
