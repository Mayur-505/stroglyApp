package com.strongly.strongly.ui;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
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
import androidx.fragment.app.Fragment;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.strongly.strongly.model.ExploreItem;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.net.ApiConstants;
import com.strongly.strongly.util.Session;
import com.strongly.strongly.util.Tr;

import java.util.ArrayList;
import java.util.List;

/** Workouts tab: muscle groups, target focus and "guess you may need" carousels. */
public class WorkoutsFragment extends Fragment {
    private static final int LIME = Kit.LIME;

    private SwipeRefreshLayout refresh;
    private LinearLayout content;
    private List<ExploreItem> row1 = new ArrayList<>(), row2 = new ArrayList<>(), targets = new ArrayList<>(), needs = new ArrayList<>();
    private boolean loading = true;
    private String loadedLanguage;

    @Nullable @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle state) {
        Context c = requireContext();
        refresh = new SwipeRefreshLayout(c);
        refresh.setColorSchemeColors(LIME);
        refresh.setProgressBackgroundColorSchemeColor(0xFF1E293B);
        ScrollView scroll = new ScrollView(c);
        scroll.setVerticalScrollBarEnabled(false);
        content = new LinearLayout(c);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setPadding(0, Kit.dp(c, 10), 0, Kit.dp(c, 40));
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
        if (loadedLanguage != null && !loadedLanguage.equals(Session.language())) {
            loadedLanguage = Session.language();
            fetch();
        }
    }

    private boolean hasData() { return !row1.isEmpty() || !row2.isEmpty() || !targets.isEmpty() || !needs.isEmpty(); }

    private List<ExploreItem> parse(JsonObject d, String key, String count, String img) {
        List<ExploreItem> out = new ArrayList<>();
        if (d.has(key) && d.get(key).isJsonArray()) {
            JsonArray a = d.getAsJsonArray(key);
            for (JsonElement e : a) if (e.isJsonObject()) out.add(ExploreItem.fromJson(e.getAsJsonObject(), count, img));
        }
        return out;
    }

    private void fetch() {
        if (!hasData()) { loading = true; render(); }
        ApiClient.get().get(ApiConstants.EXPLORE_WORKOUTS, null, r -> {
            if (!isAdded()) return;
            refresh.setRefreshing(false);
            if (r.isOk() && r.data != null && r.data.isJsonObject()) {
                JsonObject d = r.data.getAsJsonObject();
                row1 = parse(d, "muscleGroupsRow1", "10 Workouts", "assets/images/muscle_abs.jpg");
                row2 = parse(d, "muscleGroupsRow2", "10 Workouts", "assets/images/muscle_abs.jpg");
                targets = parse(d, "targetFocusList", "10 Workouts", "assets/images/target_lose_weight.jpg");
                needs = parse(d, "guessYouNeedList", "5 Workouts", "assets/images/need_hiit.jpg");
            } else {
                row1 = new ArrayList<>(); row2 = new ArrayList<>(); targets = new ArrayList<>(); needs = new ArrayList<>();
            }
            loading = false;
            render();
        });
    }

    // ------------------------------------------------------------------ rendering

    private void render() {
        Context c = requireContext();
        content.removeAllViews();

        LinearLayout bar = new LinearLayout(c);
        bar.setGravity(Gravity.CENTER_VERTICAL);
        bar.addView(Kit.text(c, Tr.t("workouts"), 26, 800, 0xFFFFFFFF), new LinearLayout.LayoutParams(0, -2, 1f));
        bar.addView(circleButton(c, Icons.SEARCH_ROUNDED, v -> startActivity(new Intent(c, WorkoutSearchActivity.class))));
        LinearLayout.LayoutParams second = Kit.lp(c, Kit.dp(c, 44), Kit.dp(c, 44), 10, 0, 0, 0);
        bar.addView(circleButton(c, Icons.TUNE_ROUNDED, v -> openCategory(null)), second);
        content.addView(bar, Kit.lp(c, -1, -2, 20, 0, 20, 0));

        View gap = new View(c);
        content.addView(gap, new LinearLayout.LayoutParams(-1, Kit.dp(c, 22)));

        boolean has = hasData();
        if (loading && !has) {
            ProgressBar pb = new ProgressBar(c);
            pb.setIndeterminateTintList(android.content.res.ColorStateList.valueOf(LIME));
            content.addView(Kit.centered(c, pb, 36, 36), Kit.lp(c, -1, -2, 0, 40, 0, 40));
        } else if (!has) {
            LinearLayout col = new LinearLayout(c);
            col.setOrientation(LinearLayout.VERTICAL);
            col.setGravity(Gravity.CENTER_HORIZONTAL);
            col.addView(Icons.view(c, Icons.FITNESS_CENTER_ROUNDED, 56, 0x3DFFFFFF));
            col.addView(Kit.text(c, "No Workouts Available", 18, 700, 0xFFFFFFFF), Kit.lp(c, -2, -2, 0, 16, 0, 0));
            TextView d = Kit.text(c, "The database is currently empty. Workouts will appear here once added or seeded into the database.", 13, 400, 0x8AFFFFFF);
            d.setGravity(Gravity.CENTER);
            col.addView(d, Kit.lp(c, -2, -2, 0, 8, 0, 0));
            content.addView(col, Kit.lp(c, -1, -2, 24, 40, 24, 40));
        }

        if (!row1.isEmpty() || !row2.isEmpty()) {
            section(c, Tr.t("muscle_group"));
            LinearLayout rows = new LinearLayout(c);
            rows.setOrientation(LinearLayout.VERTICAL);
            if (!row1.isEmpty()) rows.addView(cardRow(c, row1, 0));
            if (!row2.isEmpty()) rows.addView(cardRow(c, row2, 0), Kit.lp(c, -2, -2, 0, 12, 0, 0));
            content.addView(hScroll(c, rows));
            content.addView(new View(c), new LinearLayout.LayoutParams(-1, Kit.dp(c, 26)));
        }
        if (!targets.isEmpty()) {
            section(c, Tr.t("focus_on_target"));
            LinearLayout row = new LinearLayout(c);
            for (ExploreItem it : targets) row.addView(targetCard(c, it), Kit.lp(c, -2, -2, 0, 0, 12, 0));
            content.addView(hScroll(c, row));
            content.addView(new View(c), new LinearLayout.LayoutParams(-1, Kit.dp(c, 26)));
        }
        if (!needs.isEmpty()) {
            section(c, Tr.t("guess_you_may_need"));
            LinearLayout row = new LinearLayout(c);
            for (ExploreItem it : needs) row.addView(needCard(c, it), Kit.lp(c, -2, -2, 0, 0, 12, 0));
            content.addView(hScroll(c, row));
        }
    }

    private void section(Context c, String title) {
        content.addView(Kit.text(c, title, 18, 700, 0xFFFFFFFF), Kit.lp(c, -2, -2, 20, 0, 20, 14));
    }

    private HorizontalScrollView hScroll(Context c, View inner) {
        HorizontalScrollView hs = new HorizontalScrollView(c);
        hs.setHorizontalScrollBarEnabled(false);
        inner.setPadding(Kit.dp(c, 20), 0, Kit.dp(c, 20), 0);
        hs.addView(inner);
        return hs;
    }

    private LinearLayout cardRow(Context c, List<ExploreItem> items, int unused) {
        LinearLayout row = new LinearLayout(c);
        for (ExploreItem it : items) row.addView(muscleCard(c, it), Kit.lp(c, -2, -2, 0, 0, 12, 0));
        return row;
    }

    private View circleButton(Context c, int icon, View.OnClickListener click) {
        TextView t = Icons.view(c, icon, 20, 0xFFFFFFFF);
        GradientDrawable bg = new GradientDrawable();
        bg.setShape(GradientDrawable.OVAL);
        bg.setColor(0xFF1E293B);
        bg.setStroke(Kit.dp(c, 1), 0xFF334155);
        t.setBackground(bg);
        t.setLayoutParams(new LinearLayout.LayoutParams(Kit.dp(c, 44), Kit.dp(c, 44)));
        t.setOnClickListener(click);
        return t;
    }

    private View muscleCard(Context c, ExploreItem it) {
        FrameLayout inner = new FrameLayout(c);
        inner.setBackground(Kit.rounded(c, 0xFF1B1B1D, 15));
        inner.setClipToOutline(true);

        FrameLayout photo = new FrameLayout(c);
        ImageView img = new ImageView(c);
        img.setScaleType(ImageView.ScaleType.CENTER_CROP);
        ImageLoader.load(img, it.imagePath, 0x00000000);
        photo.addView(img, new FrameLayout.LayoutParams(-1, -1));
        View blend = new View(c);
        blend.setBackground(Kit.stops(new int[]{0xFF1B1B1D, 0x001B1B1D}, new float[]{0f, 0.5f}, false));
        photo.addView(blend, new FrameLayout.LayoutParams(-1, -1));
        inner.addView(photo, new FrameLayout.LayoutParams(Kit.dp(c, 70), -1, Gravity.END));

        LinearLayout col = new LinearLayout(c);
        col.setOrientation(LinearLayout.VERTICAL);
        col.setPadding(Kit.dp(c, 14), Kit.dp(c, 14), 0, Kit.dp(c, 12));
        TextView title = Kit.text(c, it.title, 15, 800, 0xFFFFFFFF);
        title.setLineSpacing(0, 0.9f);
        col.addView(title);
        col.addView(new View(c), new LinearLayout.LayoutParams(-1, 0, 1f));
        col.addView(Kit.text(c, it.workoutCount, 11, 500, 0x99FFFFFF));
        inner.addView(col, new FrameLayout.LayoutParams(-1, -1));

        View card = Kit.gradientBorder(c, 16, inner, new FrameLayout.LayoutParams(Kit.dp(c, 143), Kit.dp(c, 88)));
        card.setOnClickListener(v -> openCategory(it.title));
        return card;
    }

    private View targetCard(Context c, ExploreItem it) {
        FrameLayout inner = new FrameLayout(c);
        inner.setBackground(Kit.rounded(c, 0xFF1B1B1D, 17));
        inner.setClipToOutline(true);
        ImageView img = new ImageView(c);
        img.setScaleType(ImageView.ScaleType.CENTER_CROP);
        ImageLoader.load(img, it.imagePath, 0x00000000);
        inner.addView(img, new FrameLayout.LayoutParams(-1, -1));
        View shade = new View(c);
        shade.setBackground(Kit.stops(new int[]{0xA6000000, 0x33000000, 0xB3000000}, new float[]{0f, 0.45f, 1f}, true));
        inner.addView(shade, new FrameLayout.LayoutParams(-1, -1));

        LinearLayout col = new LinearLayout(c);
        col.setOrientation(LinearLayout.VERTICAL);
        col.setPadding(Kit.dp(c, 14), Kit.dp(c, 14), Kit.dp(c, 14), Kit.dp(c, 14));
        TextView title = Kit.text(c, it.title, 14, 800, 0xFFFFFFFF);
        title.setLetterSpacing(0.035f);
        col.addView(title);
        col.addView(Kit.text(c, it.workoutCount, 11, 500, 0xB3FFFFFF), Kit.lp(c, -2, -2, 0, 4, 0, 0));
        inner.addView(col, new FrameLayout.LayoutParams(-1, -1));

        View card = Kit.gradientBorder(c, 18, inner, new FrameLayout.LayoutParams(Kit.dp(c, 173), Kit.dp(c, 123)));
        card.setOnClickListener(v -> openCategory(it.title));
        return card;
    }

    private View needCard(Context c, ExploreItem it) {
        LinearLayout card = new LinearLayout(c);
        card.setGravity(Gravity.CENTER_VERTICAL);
        card.setBackground(Kit.rounded(c, 0xFF1B1B1D, 16, 1, 0x1AFFFFFF));
        card.setPadding(Kit.dp(c, 10), Kit.dp(c, 10), Kit.dp(c, 10), Kit.dp(c, 10));
        card.setLayoutParams(new LinearLayout.LayoutParams(Kit.dp(c, 220), -2));

        ImageView img = new ImageView(c);
        img.setScaleType(ImageView.ScaleType.CENTER_CROP);
        img.setBackground(Kit.rounded(c, 0xFF242426, 10));
        img.setClipToOutline(true);
        ImageLoader.load(img, it.imagePath, 0xFF242426);
        card.addView(img, new LinearLayout.LayoutParams(Kit.dp(c, 48), Kit.dp(c, 48)));

        LinearLayout col = new LinearLayout(c);
        col.setOrientation(LinearLayout.VERTICAL);
        col.addView(Kit.text(c, it.title, 14, 700, 0xFFFFFFFF));
        col.addView(Kit.text(c, it.workoutCount, 11, 500, 0x99FFFFFF), Kit.lp(c, -2, -2, 0, 3, 0, 0));
        card.addView(col, Kit.lp(c, 0, -2, 12, 0, 0, 0));
        ((LinearLayout.LayoutParams) col.getLayoutParams()).weight = 1f;

        card.setOnClickListener(v -> openCategory(it.title));
        return card;
    }

    private void openCategory(@Nullable String title) {
        Intent i = new Intent(requireContext(), CategoryWorkoutsActivity.class);
        if (title != null) i.putExtra(CategoryWorkoutsActivity.EXTRA_CATEGORY, title.replace("\n", " "));
        startActivity(i);
    }
}
