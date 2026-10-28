package com.strongly.strongly.ui;

import android.app.Activity;
import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.strongly.strongly.model.CategoryWorkoutItem;
import com.strongly.strongly.util.Tr;

/** Three-step "where / equipment / difficulty" sheet (Flutter's WorkoutCustomizationFlowSheet). */
public final class CustomizationSheet {
    private static final int LIME = Kit.LIME;

    private static final String[][] LEVELS = {
            {"no_experience", "No experience", "0"}, {"beginner", "Beginner", "1"}, {"advanced", "Advanced", "2"},
            {"expert", "Expert", "3"}, {"pro", "Pro", "4"}};

    private final Activity a;
    private final CategoryWorkoutItem workout;
    private final BottomSheetDialog dialog;
    private LinearLayout root, step;
    private TextView headerTitle, headerIcon;
    private int current = 0;
    private String locationId;

    private CustomizationSheet(Activity a, CategoryWorkoutItem workout) {
        this.a = a;
        this.workout = workout;
        this.dialog = new BottomSheetDialog(a);
    }

    public static void show(Activity a, CategoryWorkoutItem workout) {
        new CustomizationSheet(a, workout).open();
    }

    private int dp(float v) { return Kit.dp(a, v); }

    private void open() {
        root = new LinearLayout(a);
        root.setOrientation(LinearLayout.VERTICAL);
        GradientDrawable bg = new GradientDrawable();
        bg.setColor(0xFF141416);
        float r = dp(30);
        bg.setCornerRadii(new float[]{r, r, r, r, 0, 0, 0, 0});
        root.setBackground(bg);
        root.setPadding(dp(16), dp(16), dp(16), dp(36));

        FrameLayout header = new FrameLayout(a);
        headerIcon = Icons.view(a, Icons.CLOSE_ROUNDED, 20, 0xB3FFFFFF);
        headerIcon.setBackground(Kit.rounded(a, 0xFF222226, 19, 1, 0x1AFFFFFF));
        headerIcon.setOnClickListener(v -> {
            if (current > 0) { current--; render(); } else dialog.dismiss();
        });
        header.addView(headerIcon, new FrameLayout.LayoutParams(dp(38), dp(38), Gravity.START | Gravity.CENTER_VERTICAL));
        headerTitle = Kit.text(a, "", 20, 800, 0xFFFFFFFF);
        header.addView(headerTitle, new FrameLayout.LayoutParams(-2, -2, Gravity.CENTER));
        root.addView(header, new LinearLayout.LayoutParams(-1, dp(38)));

        step = new LinearLayout(a);
        step.setOrientation(LinearLayout.VERTICAL);
        root.addView(step, Kit.lp(a, -1, -2, 0, 20, 0, 0));

        dialog.setContentView(root);
        View sheet = dialog.findViewById(com.google.android.material.R.id.design_bottom_sheet);
        if (sheet != null) sheet.setBackgroundColor(0x00000000);
        dialog.getBehavior().setState(com.google.android.material.bottomsheet.BottomSheetBehavior.STATE_EXPANDED);
        render();
        dialog.show();
    }

    private void render() {
        step.removeAllViews();
        headerIcon.setText(new String(Character.toChars(current > 0 ? Icons.ARROW_BACK_ROUNDED : Icons.CLOSE_ROUNDED)));
        switch (current) {
            case 0:
                headerTitle.setText(Tr.t("where_to_train"));
                buildLocations();
                break;
            case 1:
                headerTitle.setText("Training equipment");
                buildEquipment();
                break;
            default:
                headerTitle.setText("Difficulty Level");
                buildDifficulty();
        }
        step.setAlpha(0f);
        step.animate().alpha(1f).setDuration(250).start();
    }

    private View imageCard(String image, String title, String subtitle, float[] stops, View.OnClickListener click) {
        FrameLayout inner = new FrameLayout(a);
        inner.setBackground(Kit.rounded(a, 0xFF1B1B1B, 15));
        inner.setClipToOutline(true);
        AlignedCropImageView img = new AlignedCropImageView(a, 1f, 0.5f);
        ImageLoader.load(img, image, 0x00000000);
        inner.addView(img, new FrameLayout.LayoutParams(-1, -1));
        View overlay = new View(a);
        overlay.setBackground(Kit.stops(new int[]{0xFF000000, 0xF2000000, 0x80000000, 0x00000000}, stops, false));
        inner.addView(overlay, new FrameLayout.LayoutParams(-1, -1));

        LinearLayout col = new LinearLayout(a);
        col.setOrientation(LinearLayout.VERTICAL);
        col.setGravity(Gravity.CENTER_VERTICAL);
        col.setPadding(dp(24), subtitle == null ? 0 : dp(20), dp(24), subtitle == null ? 0 : dp(20));
        col.addView(Kit.text(a, title, 18, 800, 0xFFFFFFFF));
        if (subtitle != null) {
            TextView s = Kit.text(a, subtitle, 12, 400, 0xBFFFFFFF);
            s.setLineSpacing(0, 1.2f);
            col.addView(s, Kit.lp(a, -2, -2, 0, 8, 0, 0));
        }
        inner.addView(col, new FrameLayout.LayoutParams(-1, -1));

        FrameLayout card = Kit.gradientBorder(a, 16, inner, new FrameLayout.LayoutParams(-1, -1));
        card.setOnClickListener(click);
        card.setLayoutParams(Kit.lp(a, -1, dp(160), 0, 0, 0, 16));
        return card;
    }

    private void buildLocations() {
        String[][] locs = {{"gym", Tr.t("in_the_gym"), "image_7_1_"}, {"home", Tr.t("at_home"), "image_7"}};
        for (String[] l : locs) {
            step.addView(imageCard("assets/images/" + (l[2].equals("image_7_1_") ? "image 7 (1).png" : "image 7.png"), l[1], null,
                    new float[]{0f, 0.35f, 0.60f, 1f}, v -> { locationId = l[0]; current = 1; render(); }));
        }
    }

    private void buildEquipment() {
        String[][] choices = "gym".equals(locationId)
                ? new String[][]{
                        {"Full gym equipment", "- Barbells, cable machines, squat rack\n- Weight machines, benches, dumbbells", "image 7 (1).png"},
                        {"Without any equipment", "- Bodyweight & calisthenics exercises\n- When machines are busy or not needed", "image 7.png"}}
                : new String[][]{
                        {"Basic equipment", "- Dumbbells, weights, barbell\n- ab wheel, resistance bands, gym mat", "image 7 (1).png"},
                        {"Without any equipment", "- When there is no equipment and it is not needed\n- even without a gym mat", "image 7.png"}};
        for (String[] c : choices) {
            step.addView(imageCard("assets/images/" + c[2], c[0], c[1], new float[]{0f, 0.45f, 0.65f, 1f},
                    v -> { current = 2; render(); }));
        }
    }

    private void buildDifficulty() {
        for (String[] lvl : LEVELS) {
            boolean selected = lvl[0].equals("no_experience"); // Flutter's default selection
            int filled = Integer.parseInt(lvl[2]);
            LinearLayout row = new LinearLayout(a);
            row.setGravity(Gravity.CENTER_VERTICAL);
            row.setPadding(dp(20), 0, dp(20), 0);
            row.setBackground(selected ? Kit.rounded(a, LIME, 16) : Kit.rounded(a, 0xFF1B1B1B, 16, 1, 0x1AFFFFFF));
            row.addView(Kit.text(a, lvl[1], 15, selected ? 800 : 600, selected ? 0xFF141416 : 0xFFFFFFFF),
                    new LinearLayout.LayoutParams(0, -2, 1f));
            for (int i = 0; i < 4; i++) {
                boolean on = i < filled;
                int color = selected ? 0xFF141416 : (on ? LIME : 0x61FFFFFF);
                row.addView(Icons.view(a, on ? Icons.STAR_ROUNDED : Icons.STAR_OUTLINE_ROUNDED, 19, color),
                        Kit.lp(a, dp(19), dp(19), 3, 0, 0, 0));
            }
            row.setOnClickListener(v -> {
                row.setBackground(Kit.rounded(a, LIME, 16));
                v.postDelayed(() -> finish(lvl[1]), 180);
            });
            step.addView(row, Kit.lp(a, -1, dp(54), 0, 0, 0, 12));
        }
    }

    private void finish(String difficulty) {
        dialog.dismiss();
        Intent i = new Intent(a, PlanDetailActivity.class);
        i.putExtra(PlanDetailActivity.EXTRA_PLAN_ID, workout.id);
        i.putExtra(PlanDetailActivity.EXTRA_TITLE, workout.title);
        i.putExtra(PlanDetailActivity.EXTRA_HERO, workout.imagePath);
        i.putExtra(PlanDetailActivity.EXTRA_DIFFICULTY, difficulty);
        a.startActivity(i);
    }
}
