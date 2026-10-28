package com.strongly.strongly.ui;

import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.strongly.strongly.model.CategoryWorkoutItem;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.net.ApiConstants;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/** Category list with filter chips (Flutter's CategoryWorkoutsScreen). */
public class CategoryWorkoutsActivity extends AppCompatActivity {
    public static final String EXTRA_CATEGORY = "initialCategory";
    private static final int LIME = Kit.LIME;

    private String selected;
    private List<String> filters = new ArrayList<>(java.util.Collections.singletonList("All"));
    private List<CategoryWorkoutItem> workouts = new ArrayList<>();
    private boolean loading = true;

    private LinearLayout chips, list;
    private FrameLayout body;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        UiUtil.edgeToEdge(this);
        String initial = getIntent().getStringExtra(EXTRA_CATEGORY);
        initial = initial == null ? null : initial.trim();
        selected = initial == null || initial.isEmpty() || initial.equalsIgnoreCase("all") ? "All" : initial.replace('_', ' ');

        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(0xFF0D0D0E);
        UiUtil.padForInsets(root, true, true);

        LinearLayout top = new LinearLayout(this);
        top.setGravity(Gravity.CENTER_VERTICAL);
        TextView back = Icons.view(this, Icons.ARROW_BACK_ROUNDED, 26, 0xFFFFFFFF);
        back.setOnClickListener(v -> finish());
        top.addView(back, new LinearLayout.LayoutParams(Kit.dp(this, 42), Kit.dp(this, 42)));
        top.addView(Kit.text(this, "Categories", 24, 800, 0xFFFFFFFF), Kit.lp(this, -2, -2, 8, 0, 0, 0));
        root.addView(top, Kit.lp(this, -1, -2, 16, 8, 16, 0));

        HorizontalScrollView hs = new HorizontalScrollView(this);
        hs.setHorizontalScrollBarEnabled(false);
        chips = new LinearLayout(this);
        chips.setPadding(Kit.dp(this, 20), 0, Kit.dp(this, 20), 0);
        hs.addView(chips);
        root.addView(hs, Kit.lp(this, -1, Kit.dp(this, 42), 0, 18, 0, 0));

        body = new FrameLayout(this);
        root.addView(body, Kit.lp(this, -1, 0, 0, 18, 0, 0));
        ((LinearLayout.LayoutParams) body.getLayoutParams()).weight = 1f;

        setContentView(root);
        fetch();
    }

    // ------------------------------------------------------------------ matching (same rules as Flutter)

    private boolean isAll(String cat) {
        String l = cat.trim().toLowerCase(Locale.ROOT);
        if (l.equals("all") || l.equals("सभी") || l.equals("બધા") || l.equals("todos") || l.equals("tous")) return true;
        return !filters.isEmpty() && cat.equals(filters.get(0));
    }

    private boolean matches(String chip, String sel) {
        if (isAll(chip) && isAll(sel)) return true;
        return chip.trim().toLowerCase(Locale.ROOT).replace('_', ' ')
                .equals(sel.trim().toLowerCase(Locale.ROOT).replace('_', ' '));
    }

    private int indexWhere(java.util.function.Predicate<String> p) {
        for (int i = 0; i < filters.size(); i++) if (p.test(filters.get(i))) return i;
        return -1;
    }

    private void fetch() {
        loading = true;
        renderBody();
        final String query = isAll(selected) ? "All" : selected;
        Map<String, String> q = new HashMap<>();
        q.put("category", query);
        ApiClient.get().get(ApiConstants.CATEGORY_WORKOUTS, q, r -> {
            if (isFinishing() || isDestroyed()) return;
            if (r.isOk() && r.data != null && r.data.isJsonObject()) {
                JsonObject d = r.data.getAsJsonObject();
                if (d.has("filterCategories") && d.get("filterCategories").isJsonArray() && d.getAsJsonArray("filterCategories").size() > 0) {
                    filters = new ArrayList<>();
                    for (JsonElement e : d.getAsJsonArray("filterCategories")) filters.add(e.getAsString());
                }
                String matchedApi = d.has("matchedCategory") && !d.get("matchedCategory").isJsonNull()
                        ? d.get("matchedCategory").getAsString() : null;

                final String sel0 = selected;
                int idx = indexWhere(c -> matches(c, sel0));
                if (idx < 0 && matchedApi != null && !matchedApi.isEmpty()) idx = indexWhere(c -> matches(c, matchedApi));
                if (idx < 0) {
                    String selLower = selected.toLowerCase(Locale.ROOT);
                    idx = indexWhere(c -> {
                        if (isAll(c)) return false;
                        String cl = c.toLowerCase(Locale.ROOT);
                        return selLower.contains(cl) || cl.contains(selLower);
                    });
                }
                selected = idx >= 0 ? filters.get(idx) : (!filters.isEmpty() ? filters.get(0) : "All");

                workouts = new ArrayList<>();
                if (d.has("workouts") && d.get("workouts").isJsonArray()) {
                    JsonArray a = d.getAsJsonArray("workouts");
                    for (JsonElement e : a) if (e.isJsonObject()) workouts.add(CategoryWorkoutItem.fromJson(e.getAsJsonObject()));
                }
                loading = false;
                renderChips();
                renderBody();
                // fell back to 'All' with nothing returned: refetch for 'All'
                if (isAll(selected) && !query.equals("All") && workouts.isEmpty()) fetch();
            } else {
                workouts = new ArrayList<>();
                loading = false;
                renderChips();
                renderBody();
            }
        });
    }

    // ------------------------------------------------------------------ rendering

    private void renderChips() {
        chips.removeAllViews();
        for (String cat : filters) {
            boolean sel = matches(cat, selected);
            TextView t = Kit.text(this, cat, 14, 700, sel ? 0xFF000000 : 0xB3FFFFFF);
            t.setGravity(Gravity.CENTER);
            t.setBackground(sel ? Kit.rounded(this, LIME, 24) : Kit.rounded(this, 0xFF1B1B1D, 24, 1, 0x1FFFFFFF));
            t.setPadding(Kit.dp(this, 22), 0, Kit.dp(this, 22), 0);
            t.setOnClickListener(v -> { selected = cat; renderChips(); fetch(); });
            chips.addView(t, Kit.lp(this, -2, -1, 0, 0, 10, 0));
        }
    }

    private void renderBody() {
        body.removeAllViews();
        if (loading) {
            ProgressBar pb = new ProgressBar(this);
            pb.setIndeterminateTintList(android.content.res.ColorStateList.valueOf(LIME));
            body.addView(pb, new FrameLayout.LayoutParams(Kit.dp(this, 36), Kit.dp(this, 36), Gravity.CENTER));
            return;
        }
        if (workouts.isEmpty()) {
            TextView t = Kit.text(this, "No workouts found", 16, 400, 0x99FFFFFF);
            body.addView(t, new FrameLayout.LayoutParams(-2, -2, Gravity.CENTER));
            return;
        }
        ScrollView sv = new ScrollView(this);
        sv.setVerticalScrollBarEnabled(false);
        list = new LinearLayout(this);
        list.setOrientation(LinearLayout.VERTICAL);
        list.setPadding(Kit.dp(this, 20), Kit.dp(this, 8), Kit.dp(this, 20), Kit.dp(this, 8));
        for (int i = 0; i < workouts.size(); i++) {
            final CategoryWorkoutItem w = workouts.get(i);
            if (com.strongly.strongly.billing.PremiumService.get().isPremium()) w.isFree = true; // premium users see everything unlocked
            View tile = WorkoutTile.build(this, w, v -> onWorkoutTap(w));
            list.addView(tile, Kit.lp(this, -1, -2, 0, 0, 0, i == workouts.size() - 1 ? 0 : 16));
        }
        sv.addView(list);
        body.addView(sv, new FrameLayout.LayoutParams(-1, -1));
    }

    /** Flutter opens the unlock sheet (rewarded ad) for locked items, then the customization sheet. */
    private void onWorkoutTap(CategoryWorkoutItem w) {
        if (w.isLocked()) {
            w.isFree = true; // ads removed: locked workouts unlock directly
            renderBody();
        }
        CustomizationSheet.show(this, w);
    }
}
