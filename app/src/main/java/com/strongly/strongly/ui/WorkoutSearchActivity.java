package com.strongly.strongly.ui;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.View;
import android.widget.EditText;
import android.widget.FrameLayout;
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

/** Search with body-focus / hot-topic tags (Flutter's WorkoutSearchScreen). */
public class WorkoutSearchActivity extends AppCompatActivity {
    private static final int LIME = Kit.LIME;

    private EditText input;
    private TextView clear;
    private FrameLayout body;
    private String active = "";
    private List<String> bodyFocus = new ArrayList<>(), hotTopics = new ArrayList<>();
    private List<CategoryWorkoutItem> results = new ArrayList<>();
    private boolean searching = false;
    private int requestSeq = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        UiUtil.edgeToEdge(this);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(0xFF0D0D0E);
        root.setPadding(Kit.dp(this, 20), Kit.dp(this, 12), Kit.dp(this, 20), Kit.dp(this, 12));
        UiUtil.padForInsets(root, true, true);

        LinearLayout header = new LinearLayout(this);
        header.setGravity(Gravity.CENTER_VERTICAL);

        LinearLayout field = new LinearLayout(this);
        field.setGravity(Gravity.CENTER_VERTICAL);
        field.setBackground(Kit.rounded(this, 0xFF1B1B1D, 16, 1, 0x1AFFFFFF));
        field.setPadding(Kit.dp(this, 14), 0, Kit.dp(this, 14), 0);
        field.addView(Icons.view(this, Icons.SEARCH_ROUNDED, 20, 0x8AFFFFFF));
        input = new EditText(this);
        input.setBackground(null);
        input.setSingleLine();
        input.setHint("Search workouts, plans...");
        input.setHintTextColor(0x61FFFFFF);
        input.setTextColor(0xFFFFFFFF);
        input.setTextSize(15);
        UiUtil.weight(input, 500);
        input.setPadding(0, 0, 0, 0);
        field.addView(input, Kit.lp(this, 0, -1, 10, 0, 0, 0));
        ((LinearLayout.LayoutParams) input.getLayoutParams()).weight = 1f;
        clear = Icons.view(this, Icons.CLEAR_ROUNDED, 18, 0x8AFFFFFF);
        clear.setVisibility(View.GONE);
        clear.setOnClickListener(v -> input.setText(""));
        field.addView(clear);
        LinearLayout.LayoutParams fp = new LinearLayout.LayoutParams(0, Kit.dp(this, 48), 1f);
        header.addView(field, fp);

        TextView close = Icons.view(this, Icons.CLOSE_ROUNDED, 20, 0xFFFFFFFF);
        close.setBackground(Kit.rounded(this, 0xFF1B1B1D, 22, 1, 0x1FFFFFFF));
        close.setOnClickListener(v -> finish());
        header.addView(close, Kit.lp(this, Kit.dp(this, 44), Kit.dp(this, 44), 12, 0, 0, 0));
        root.addView(header, new LinearLayout.LayoutParams(-1, -2));

        body = new FrameLayout(this);
        LinearLayout.LayoutParams bp = Kit.lp(this, -1, 0, 0, 20, 0, 0);
        bp.weight = 1f;
        root.addView(body, bp);
        setContentView(root);

        input.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int a, int b, int c) {}
            @Override public void onTextChanged(CharSequence s, int a, int b, int c) {}
            @Override public void afterTextChanged(Editable e) {
                String text = e.toString().trim();
                clear.setVisibility(text.isEmpty() ? View.GONE : View.VISIBLE);
                if (!text.equals(active)) {
                    active = text;
                    if (!text.isEmpty()) search(text);
                    else { results = new ArrayList<>(); }
                    render();
                }
            }
        });
        render();
        fetchTags();
    }

    private List<String> names(JsonArray a) {
        List<String> out = new ArrayList<>();
        for (JsonElement e : a) {
            String s;
            if (e.isJsonObject()) s = e.getAsJsonObject().has("name") ? e.getAsJsonObject().get("name").getAsString() : "";
            else s = e.getAsString();
            if (!s.isEmpty()) out.add(s);
        }
        return out;
    }

    private void fetchTags() {
        ApiClient.get().get(ApiConstants.SEARCH_TAGS, null, r -> {
            if (isFinishing() || isDestroyed()) return;
            if (r.isOk() && r.data != null && r.data.isJsonObject()) {
                JsonObject d = r.data.getAsJsonObject();
                if (d.has("bodyFocusTags") && d.get("bodyFocusTags").isJsonArray() && d.getAsJsonArray("bodyFocusTags").size() > 0)
                    bodyFocus = names(d.getAsJsonArray("bodyFocusTags"));
                if (d.has("hotTopicTags") && d.get("hotTopicTags").isJsonArray() && d.getAsJsonArray("hotTopicTags").size() > 0)
                    hotTopics = names(d.getAsJsonArray("hotTopicTags"));
                render();
            }
        });
    }

    private void search(String query) {
        searching = true;
        final int seq = ++requestSeq;
        Map<String, String> q = new HashMap<>();
        q.put("query", query);
        ApiClient.get().get(ApiConstants.SEARCH_WORKOUTS, q, r -> {
            // ignore stale responses so a slow earlier query can't overwrite a newer one
            if (isFinishing() || isDestroyed() || seq != requestSeq) return;
            results = new ArrayList<>();
            if (r.isOk() && r.data != null && r.data.isJsonArray()) {
                for (JsonElement e : r.data.getAsJsonArray()) if (e.isJsonObject()) results.add(CategoryWorkoutItem.fromJson(e.getAsJsonObject()));
            }
            searching = false;
            render();
        });
    }

    // ------------------------------------------------------------------ rendering

    private void render() {
        body.removeAllViews();
        if (active.isEmpty()) { body.addView(tagsView(), new FrameLayout.LayoutParams(-1, -1)); return; }
        if (searching) {
            ProgressBar pb = new ProgressBar(this);
            pb.setIndeterminateTintList(android.content.res.ColorStateList.valueOf(LIME));
            body.addView(pb, new FrameLayout.LayoutParams(Kit.dp(this, 36), Kit.dp(this, 36), Gravity.CENTER));
            return;
        }
        if (results.isEmpty()) {
            LinearLayout col = new LinearLayout(this);
            col.setOrientation(LinearLayout.VERTICAL);
            col.setGravity(Gravity.CENTER_HORIZONTAL);
            col.addView(Icons.view(this, Icons.SEARCH_OFF_ROUNDED, 48, 0x61FFFFFF));
            col.addView(Kit.text(this, "No workouts found for \"" + active + "\"", 15, 400, 0x99FFFFFF), Kit.lp(this, -2, -2, 0, 12, 0, 0));
            body.addView(col, new FrameLayout.LayoutParams(-2, -2, Gravity.CENTER));
            return;
        }
        ScrollView sv = new ScrollView(this);
        sv.setVerticalScrollBarEnabled(false);
        LinearLayout list = new LinearLayout(this);
        list.setOrientation(LinearLayout.VERTICAL);
        for (int i = 0; i < results.size(); i++) {
            final CategoryWorkoutItem w = results.get(i);
            list.addView(WorkoutTile.build(this, w, v -> CustomizationSheet.show(this, w)),
                    Kit.lp(this, -1, -2, 0, 0, 0, i == results.size() - 1 ? 0 : 14));
        }
        sv.addView(list);
        body.addView(sv, new FrameLayout.LayoutParams(-1, -1));
    }

    private View tagsView() {
        ScrollView sv = new ScrollView(this);
        sv.setVerticalScrollBarEnabled(false);
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        col.addView(Kit.text(this, "Body Focus", 18, 700, 0xFFFFFFFF));
        col.addView(tagFlow(bodyFocus), Kit.lp(this, -1, -2, 0, 14, 0, 0));
        col.addView(Kit.text(this, "Hot Topics", 18, 700, 0xFFFFFFFF), Kit.lp(this, -2, -2, 0, 28, 0, 0));
        col.addView(tagFlow(hotTopics), Kit.lp(this, -1, -2, 0, 14, 0, 0));
        sv.addView(col);
        return sv;
    }

    /** Wrapping chip layout (Flutter's Wrap with spacing 10 / runSpacing 12). */
    private View tagFlow(List<String> tags) {
        FlowLayout flow = new FlowLayout(this, Kit.dp(this, 10), Kit.dp(this, 12));
        for (String tag : tags) {
            boolean sel = active.toLowerCase(Locale.ROOT).equals(tag.toLowerCase(Locale.ROOT));
            TextView t = Kit.text(this, tag, 13, sel ? 700 : 500, sel ? 0xFF000000 : 0xB3FFFFFF);
            t.setBackground(Kit.rounded(this, sel ? LIME : 0xFF1B1B1D, 20, 1, sel ? LIME : 0x1AFFFFFF));
            t.setPadding(Kit.dp(this, 18), Kit.dp(this, 10), Kit.dp(this, 18), Kit.dp(this, 10));
            t.setOnClickListener(v -> { input.setText(tag); input.setSelection(tag.length()); });
            flow.addView(t);
        }
        return flow;
    }

    /** Minimal wrapping layout. */
    static final class FlowLayout extends android.view.ViewGroup {
        private final int hGap, vGap;

        FlowLayout(android.content.Context c, int hGap, int vGap) {
            super(c);
            this.hGap = hGap;
            this.vGap = vGap;
        }

        @Override
        protected void onMeasure(int wSpec, int hSpec) {
            int maxW = MeasureSpec.getSize(wSpec);
            int x = 0, y = 0, rowH = 0;
            for (int i = 0; i < getChildCount(); i++) {
                View ch = getChildAt(i);
                ch.measure(MeasureSpec.makeMeasureSpec(maxW, MeasureSpec.AT_MOST), MeasureSpec.UNSPECIFIED);
                int cw = ch.getMeasuredWidth(), chh = ch.getMeasuredHeight();
                if (x > 0 && x + cw > maxW) { x = 0; y += rowH + vGap; rowH = 0; }
                x += cw + hGap;
                rowH = Math.max(rowH, chh);
            }
            setMeasuredDimension(maxW, y + rowH);
        }

        @Override
        protected void onLayout(boolean changed, int l, int t, int r, int b) {
            int maxW = r - l;
            int x = 0, y = 0, rowH = 0;
            for (int i = 0; i < getChildCount(); i++) {
                View ch = getChildAt(i);
                int cw = ch.getMeasuredWidth(), chh = ch.getMeasuredHeight();
                if (x > 0 && x + cw > maxW) { x = 0; y += rowH + vGap; rowH = 0; }
                ch.layout(x, y, x + cw, y + chh);
                x += cw + hGap;
                rowH = Math.max(rowH, chh);
            }
        }
    }
}
