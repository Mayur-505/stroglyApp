package com.strongly.strongly.ui;

import android.content.Intent;
import android.graphics.LinearGradient;
import android.graphics.Shader;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.PaintDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.res.ResourcesCompat;
import androidx.fragment.app.Fragment;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.strongly.strongly.R;
import com.strongly.strongly.model.WorkoutCategory;
import com.strongly.strongly.model.WorkoutItem;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.net.ApiConstants;
import com.strongly.strongly.util.Session;
import com.strongly.strongly.util.Tr;

import java.util.ArrayList;
import java.util.List;

/** Home tab: greeting, featured workout, quick categories, recommended workouts. */
public class HomeFragment extends Fragment {
    private static final int LIME = 0xFFA3D223;

    private SwipeRefreshLayout refresh;
    private LinearLayout content;

    private WorkoutItem featured;
    private List<WorkoutCategory> categories = new ArrayList<>();
    private List<WorkoutItem> recommended = new ArrayList<>();
    private String selectedCategoryId = "";
    private boolean loading = true;
    private String loadedLanguage;

    @Nullable @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle state) {
        refresh = new SwipeRefreshLayout(requireContext());
        refresh.setColorSchemeColors(LIME);
        refresh.setProgressBackgroundColorSchemeColor(0xFF1E293B);
        ScrollView scroll = new ScrollView(requireContext());
        scroll.setOverScrollMode(View.OVER_SCROLL_ALWAYS);
        scroll.setVerticalScrollBarEnabled(false);
        content = new LinearLayout(requireContext());
        content.setOrientation(LinearLayout.VERTICAL);
        content.setPadding(0, dp(10), 0, dp(10));
        scroll.addView(content, new ViewGroup.LayoutParams(-1, -2));
        refresh.addView(scroll);
        refresh.setOnRefreshListener(this::fetch);
        loadedLanguage = Session.language();
        render();
        fetch();
        return refresh;
    }

    @Override
    public void onResume() {
        super.onResume();
        // Flutter re-fetches when the language changes
        if (loadedLanguage != null && !loadedLanguage.equals(Session.language())) {
            loadedLanguage = Session.language();
            fetch();
        }
    }

    private int dp(float v) { return UiUtil.dp(requireContext(), v); }

    // ------------------------------------------------------------------ data

    private void fetch() {
        boolean hasData = featured != null || !categories.isEmpty() || !recommended.isEmpty();
        if (!hasData) { loading = true; render(); }
        ApiClient.get().get(ApiConstants.HOME_FEED, null, r -> {
            if (!isAdded()) return;
            refresh.setRefreshing(false);
            if (r.isOk() && r.data != null && r.data.isJsonObject()) {
                JsonObject d = r.data.getAsJsonObject();
                featured = d.has("featuredWorkout") && d.get("featuredWorkout").isJsonObject()
                        ? WorkoutItem.fromJson(d.getAsJsonObject("featuredWorkout")) : null;
                categories = new ArrayList<>();
                if (d.has("categories") && d.get("categories").isJsonArray()) {
                    for (JsonElement e : d.getAsJsonArray("categories"))
                        if (e.isJsonObject()) categories.add(WorkoutCategory.fromJson(e.getAsJsonObject()));
                    if (!categories.isEmpty() && selectedCategoryId.isEmpty()) selectedCategoryId = categories.get(0).id;
                }
                recommended = new ArrayList<>();
                if (d.has("recommendedWorkouts") && d.get("recommendedWorkouts").isJsonArray()) {
                    JsonArray a = d.getAsJsonArray("recommendedWorkouts");
                    for (JsonElement e : a) if (e.isJsonObject()) recommended.add(WorkoutItem.fromJson(e.getAsJsonObject()));
                }
            } else {
                featured = null;
                categories = new ArrayList<>();
                recommended = new ArrayList<>();
            }
            loading = false;
            render();
        });
    }

    // ------------------------------------------------------------------ rendering

    private TextView text(String s, float sp, int weight, int color) {
        TextView t = new TextView(requireContext());
        t.setText(s);
        t.setTextSize(sp);
        t.setTextColor(color);
        UiUtil.weight(t, weight);
        return t;
    }

    private LinearLayout.LayoutParams lp(int w, int h, int l, int t, int r, int b) {
        LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(w, h);
        p.setMargins(dp(l), dp(t), dp(r), dp(b));
        return p;
    }

    private void render() {
        content.removeAllViews();
        boolean empty = featured == null && categories.isEmpty() && recommended.isEmpty();

        TextView logo = new TextView(requireContext());
        logo.setText("STRONGLY");
        logo.setTypeface(ResourcesCompat.getFont(requireContext(), R.font.lozange_no_commercial));
        logo.setTextColor(LIME);
        logo.setTextSize(24);
        logo.setLetterSpacing(-0.05f);
        content.addView(logo, lp(-2, -2, 20, 0, 20, 0));

        String name = Session.userName() != null ? Session.userName() : "Alex";
        LinearLayout greet = new LinearLayout(requireContext());
        greet.setOrientation(LinearLayout.VERTICAL);
        greet.addView(text(Tr.t("good_morning") + ", " + name + " 👋", 24, 800, 0xFFFFFFFF));
        greet.addView(text(Tr.t("ready_to_sweat"), 14, 400, 0x99FFFFFF), lp(-2, -2, 0, 4, 0, 0));
        content.addView(greet, lp(-1, -2, 20, 18, 20, 0));

        View gap = new View(requireContext());
        content.addView(gap, lp(-1, dp(18), 0, 0, 0, 0));

        if (loading && empty) {
            ProgressBar pb = new ProgressBar(requireContext());
            pb.setIndeterminateTintList(android.content.res.ColorStateList.valueOf(LIME));
            FrameLayout w = new FrameLayout(requireContext());
            w.addView(pb, new FrameLayout.LayoutParams(dp(36), dp(36), Gravity.CENTER));
            content.addView(w, lp(-1, -2, 0, 40, 0, 40));
        } else if (empty) {
            LinearLayout col = new LinearLayout(requireContext());
            col.setOrientation(LinearLayout.VERTICAL);
            col.setGravity(Gravity.CENTER_HORIZONTAL);
            col.addView(Icons.view(requireContext(), Icons.FITNESS_CENTER_ROUNDED, 56, 0x3DFFFFFF));
            col.addView(text("No Workouts Found", 18, 700, 0xFFFFFFFF), lp(-2, -2, 0, 16, 0, 0));
            TextView d = text("The database is currently empty. Run database seed or add workouts from the backend to display them here.",
                    13, 400, 0x8AFFFFFF);
            d.setGravity(Gravity.CENTER);
            col.addView(d, lp(-2, -2, 0, 8, 0, 0));
            content.addView(col, lp(-1, -2, 24, 40, 24, 40));
        }

        if (featured != null) content.addView(featuredCard(featured), lp(-1, -2, 20, 0, 20, 0));

        if (!categories.isEmpty()) content.addView(categoriesSection(), lp(-1, -2, 0, 24, 0, 0));

        if (!recommended.isEmpty()) {
            LinearLayout header = new LinearLayout(requireContext());
            header.setGravity(Gravity.CENTER_VERTICAL);
            TextView h = text(Tr.t("recommended_for_you"), 18, 700, 0xFFFFFFFF);
            h.setSingleLine();
            h.setEllipsize(android.text.TextUtils.TruncateAt.END);
            header.addView(h, new LinearLayout.LayoutParams(0, -2, 1f));
            TextView all = text(Tr.t("see_all"), 13, 600, LIME);
            all.setPadding(dp(4), dp(4), dp(4), dp(4));
            all.setOnClickListener(v -> openCategories(null));
            header.addView(all);
            content.addView(header, lp(-1, -2, 20, 24, 20, 14));

            for (WorkoutItem w : recommended) content.addView(recommendedCard(w), lp(-1, -2, 20, 0, 20, 14));
        }
        content.addView(new View(requireContext()), lp(-1, dp(10), 0, 0, 0, 0));
    }

    private GradientDrawable borderGradient(float radiusDp) {
        GradientDrawable g = new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, new int[]{0xFFA3D223, 0x00A3D223});
        g.setCornerRadius(dp(radiusDp));
        return g;
    }

    private View badge(Integer icon, String label) {
        LinearLayout b = new LinearLayout(requireContext());
        b.setGravity(Gravity.CENTER_VERTICAL);
        GradientDrawable bg = new GradientDrawable();
        bg.setColor(0x8C000000);
        bg.setCornerRadius(dp(16));
        bg.setStroke(Math.max(1, dp(0.8f)), 0x2EFFFFFF);
        b.setBackground(bg);
        b.setPadding(dp(10), dp(5), dp(10), dp(5));
        if (icon != null) {
            b.addView(Icons.view(requireContext(), icon, 12, 0xFFFFFFFF));
        }
        TextView t = text(label, 11, 700, 0xFFFFFFFF);
        t.setLetterSpacing(0.055f);
        LinearLayout.LayoutParams tp = new LinearLayout.LayoutParams(-2, -2);
        if (icon != null) tp.setMarginStart(dp(4));
        b.addView(t, tp);
        return b;
    }

    private View featuredCard(WorkoutItem w) {
        FrameLayout outer = new FrameLayout(requireContext());
        outer.setPadding(dp(1), dp(1), dp(1), dp(1));
        outer.setBackground(borderGradient(24));

        FrameLayout inner = new FrameLayout(requireContext());
        GradientDrawable fill = new GradientDrawable();
        fill.setColor(0xFF1B1B1D);
        fill.setCornerRadius(dp(23));
        inner.setBackground(fill);
        inner.setClipToOutline(true);
        outer.addView(inner, new FrameLayout.LayoutParams(-1, dp(330)));

        TopCropImageView img = new TopCropImageView(requireContext());
        ImageLoader.load(img, w.imagePath, 0xFF1E2616);
        inner.addView(img, new FrameLayout.LayoutParams(-1, -1));

        View overlay = new View(requireContext());
        PaintDrawable shade = new PaintDrawable();
        shade.setShape(new android.graphics.drawable.shapes.RectShape());
        shade.setShaderFactory(new ShapeDrawable.ShaderFactory() {
            @Override public Shader resize(int width, int height) {
                return new LinearGradient(0, 0, 0, height, new int[]{0x59000000, 0x26000000, 0xE6000000},
                        new float[]{0f, 0.35f, 0.9f}, Shader.TileMode.CLAMP);
            }
        });
        overlay.setBackground(shade);
        inner.addView(overlay, new FrameLayout.LayoutParams(-1, -1));

        LinearLayout col = new LinearLayout(requireContext());
        col.setOrientation(LinearLayout.VERTICAL);
        col.setPadding(dp(18), dp(18), dp(18), dp(18));
        inner.addView(col, new FrameLayout.LayoutParams(-1, -1));

        LinearLayout badges = new LinearLayout(requireContext());
        if (w.level != null) badges.addView(badge(null, w.level), lp(-2, -2, 0, 0, 8, 0));
        badges.addView(badge(Icons.TIMER_OUTLINED, w.duration), lp(-2, -2, 0, 0, 8, 0));
        badges.addView(badge(Icons.FIRE_OUTLINED, w.calories));
        col.addView(badges);

        View spacer = new View(requireContext());
        col.addView(spacer, new LinearLayout.LayoutParams(-1, 0, 1f));

        TextView title = text(w.title, 34, 900, 0xFFFFFFFF);
        title.setLetterSpacing(-0.015f);
        title.setLineSpacing(0, 0.86f);
        col.addView(title);

        LinearLayout btn = new LinearLayout(requireContext());
        btn.setGravity(Gravity.CENTER);
        GradientDrawable bb = new GradientDrawable();
        bb.setColor(LIME);
        bb.setCornerRadius(dp(24));
        btn.setBackground(bb);
        btn.addView(text("Start Workout", 15, 800, 0xFF000000));
        TextView arrow = Icons.view(requireContext(), Icons.ARROW_FORWARD_ROUNDED, 18, 0xFF000000);
        btn.addView(arrow, lp(-2, -2, 6, 0, 0, 0));
        btn.setOnClickListener(v -> openPlan(w));
        col.addView(btn, lp(-1, dp(48), 0, 16, 0, 0));
        return outer;
    }

    private View categoriesSection() {
        LinearLayout col = new LinearLayout(requireContext());
        col.setOrientation(LinearLayout.VERTICAL);

        LinearLayout header = new LinearLayout(requireContext());
        header.setGravity(Gravity.CENTER_VERTICAL);
        TextView h = text(Tr.t("quick_categories"), 18, 700, 0xFFFFFFFF);
        h.setSingleLine();
        h.setEllipsize(android.text.TextUtils.TruncateAt.END);
        header.addView(h, new LinearLayout.LayoutParams(0, -2, 1f));
        TextView all = text(Tr.t("see_all"), 13, 600, LIME);
        all.setPadding(dp(4), dp(4), dp(4), dp(4));
        all.setOnClickListener(v -> openCategories(null));
        header.addView(all);
        col.addView(header, lp(-1, -2, 20, 0, 20, 14));

        HorizontalScrollView hs = new HorizontalScrollView(requireContext());
        hs.setHorizontalScrollBarEnabled(false);
        LinearLayout row = new LinearLayout(requireContext());
        row.setPadding(dp(20), 0, dp(20), 0);
        for (WorkoutCategory c : categories) {
            boolean sel = c.id.equals(selectedCategoryId);
            LinearLayout chip = new LinearLayout(requireContext());
            chip.setGravity(Gravity.CENTER_VERTICAL);
            GradientDrawable bg = new GradientDrawable();
            bg.setColor(sel ? LIME : 0xFF1B1B1D);
            bg.setCornerRadius(dp(24));
            bg.setStroke(dp(1), sel ? LIME : 0x1FFFFFFF);
            chip.setBackground(bg);
            chip.setPadding(dp(16), 0, dp(16), 0);
            chip.addView(Icons.view(requireContext(), c.icon, 16, sel ? 0xFF000000 : 0xB3FFFFFF));
            chip.addView(text(c.name, 13, sel ? 700 : 600, sel ? 0xFF000000 : 0xFFFFFFFF), lp(-2, -2, 8, 0, 0, 0));
            chip.setOnClickListener(v -> {
                selectedCategoryId = c.id;
                render();
                openCategories(c.name);
            });
            row.addView(chip, lp(-2, dp(42), 0, 0, 10, 0));
        }
        hs.addView(row);
        col.addView(hs, new LinearLayout.LayoutParams(-1, -2));
        return col;
    }

    private View recommendedCard(WorkoutItem w) {
        FrameLayout outer = new FrameLayout(requireContext());
        outer.setPadding(dp(1), dp(1), dp(1), dp(1));
        outer.setBackground(borderGradient(20));

        LinearLayout inner = new LinearLayout(requireContext());
        inner.setOrientation(LinearLayout.VERTICAL);
        GradientDrawable fill = new GradientDrawable();
        fill.setColor(0xFF1B1B1D);
        fill.setCornerRadius(dp(19));
        inner.setBackground(fill);
        inner.setClipToOutline(true);
        outer.addView(inner, new FrameLayout.LayoutParams(-1, -2));

        ImageView img = new ImageView(requireContext());
        img.setScaleType(ImageView.ScaleType.CENTER_CROP);
        ImageLoader.load(img, w.imagePath, 0xFF222818);
        inner.addView(img, new LinearLayout.LayoutParams(-1, dp(125)));

        LinearLayout d = new LinearLayout(requireContext());
        d.setOrientation(LinearLayout.VERTICAL);
        d.setPadding(dp(14), dp(14), dp(14), dp(14));
        TextView title = text(w.title, 15, 700, 0xFFFFFFFF);
        title.setLetterSpacing(0.033f);
        d.addView(title);
        LinearLayout meta = new LinearLayout(requireContext());
        meta.setGravity(Gravity.CENTER_VERTICAL);
        meta.addView(Icons.view(requireContext(), Icons.TIMER_OUTLINED, 13, LIME));
        meta.addView(text(w.duration, 12, 500, 0xB3FFFFFF), lp(-2, -2, 4, 0, 0, 0));
        meta.addView(Icons.view(requireContext(), Icons.FIRE_OUTLINED, 13, LIME), lp(-2, -2, 14, 0, 0, 0));
        meta.addView(text(w.calories, 12, 500, 0xB3FFFFFF), lp(-2, -2, 4, 0, 0, 0));
        d.addView(meta, lp(-2, -2, 0, 6, 0, 0));
        inner.addView(d);

        outer.setOnClickListener(v -> openPlan(w));
        return outer;
    }

    // ------------------------------------------------------------------ navigation (targets not ported yet)

    private void openPlan(WorkoutItem w) {
        Intent i = new Intent(requireContext(), PlanDetailActivity.class);
        i.putExtra(PlanDetailActivity.EXTRA_PLAN_ID, w.id);
        i.putExtra(PlanDetailActivity.EXTRA_TITLE, w.title);
        i.putExtra(PlanDetailActivity.EXTRA_HERO, w.imagePath);
        startActivity(i);
    }

    private void openCategories(String initialCategory) {
        Intent i = new Intent(requireContext(), CategoryWorkoutsActivity.class);
        if (initialCategory != null) i.putExtra(CategoryWorkoutsActivity.EXTRA_CATEGORY, initialCategory);
        startActivity(i);
    }
}
