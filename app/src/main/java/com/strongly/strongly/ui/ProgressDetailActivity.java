package com.strongly.strongly.ui;

import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.strongly.strongly.model.ProgressModels;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.util.Session;
import com.strongly.strongly.util.Tr;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/** Progress detail with Summary and History tabs (Flutter's ProgressDetailScreen). */
public class ProgressDetailActivity extends AppCompatActivity {
    public static final String EXTRA_HISTORY = "history";
    private static final int LIME = Kit.LIME;

    private boolean historyTab;
    private String month = "September 2026";
    private final Calendar monthDate = Calendar.getInstance();
    private Integer selectedDay = null;
    private Set<Integer> completedDays = new HashSet<>();
    private List<ProgressModels.HistoryLog> logs = new ArrayList<>();
    private ProgressModels.Chart workoutChart;
    private boolean chartsLocked = false;
    private Integer historyDays = null;

    private LinearLayout tabs, body;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        UiUtil.edgeToEdge(this);
        historyTab = getIntent().getBooleanExtra(EXTRA_HISTORY, false);
        monthDate.set(Calendar.DAY_OF_MONTH, 1);

        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(0xFF0D0D0E);
        UiUtil.padForInsets(root, true, true);

        LinearLayout top = new LinearLayout(this);
        top.setGravity(Gravity.CENTER_VERTICAL);
        top.setPadding(Kit.dp(this, 16), Kit.dp(this, 8), Kit.dp(this, 16), Kit.dp(this, 8));
        TextView back = Icons.view(this, Icons.ARROW_BACK_ROUNDED, 22, 0xFFFFFFFF);
        back.setOnClickListener(v -> finish());
        top.addView(back, new LinearLayout.LayoutParams(Kit.dp(this, 38), Kit.dp(this, 38)));
        top.addView(Kit.text(this, Tr.t("progress_title"), 22, 800, 0xFFFFFFFF), Kit.lp(this, -2, -2, 8, 0, 0, 0));
        root.addView(top, new LinearLayout.LayoutParams(-1, -2));

        tabs = new LinearLayout(this);
        root.addView(tabs, Kit.lp(this, -1, -2, 20, 0, 20, 0));
        View divider = new View(this);
        divider.setBackgroundColor(0xFF222226);
        root.addView(divider, Kit.lp(this, -1, Math.max(1, dp(1)), 20, 0, 20, 0));

        ScrollView sv = new ScrollView(this);
        sv.setVerticalScrollBarEnabled(false);
        body = new LinearLayout(this);
        body.setOrientation(LinearLayout.VERTICAL);
        body.setPadding(Kit.dp(this, 20), Kit.dp(this, 18), Kit.dp(this, 20), Kit.dp(this, 30));
        sv.addView(body);
        root.addView(sv, new LinearLayout.LayoutParams(-1, 0, 1f));
        setContentView(root);

        render();
        fetchHistory(selectedDay, false, false);
    }

    private int dp(float v) { return Kit.dp(this, v); }

    // ------------------------------------------------------------------ data

    private void fetchHistory(Integer day, boolean explicit, boolean skipDashboard) {
        Integer effective = explicit ? day : (day != null ? day : selectedDay);
        int year = monthDate.get(Calendar.YEAR), m = monthDate.get(Calendar.MONTH) + 1;
        StringBuilder path = new StringBuilder("/progress/history?lang=" + Session.language()
                + "&year=" + year + "&month=" + m + "&_t=" + System.currentTimeMillis());
        if (effective != null) path.append("&date=").append(year).append('-').append(String.format("%02d", m))
                .append('-').append(String.format("%02d", effective));

        ApiClient.get().get(path.toString(), null, r -> {
            if (isFinishing() || isDestroyed()) return;
            if (r.isOk() && r.data != null && r.data.isJsonObject()) {
                JsonObject d = r.data.getAsJsonObject();
                if (d.has("month") && !d.get("month").isJsonNull()) month = d.get("month").getAsString();
                historyDays = d.has("historyLimited") && !d.get("historyLimited").isJsonNull() && d.get("historyLimited").getAsBoolean()
                        && d.has("historyDays") && !d.get("historyDays").isJsonNull() ? d.get("historyDays").getAsInt() : null;
                completedDays = new HashSet<>();
                if (d.has("completedDays") && d.get("completedDays").isJsonArray())
                    for (JsonElement e : d.getAsJsonArray("completedDays")) completedDays.add(e.getAsInt());
                logs = new ArrayList<>();
                if (d.has("workoutHistoryLogs") && d.get("workoutHistoryLogs").isJsonArray())
                    for (JsonElement e : d.getAsJsonArray("workoutHistoryLogs"))
                        if (e.isJsonObject()) logs.add(ProgressModels.HistoryLog.fromJson(e.getAsJsonObject()));
            }
            if (skipDashboard) { render(); return; }
            ApiClient.get().get("/progress/dashboard", null, dr -> {
                if (isFinishing() || isDestroyed()) return;
                if (dr.isOk() && dr.data != null && dr.data.isJsonObject()) {
                    JsonObject o = dr.data.getAsJsonObject();
                    chartsLocked = o.has("chartsLocked") && !o.get("chartsLocked").isJsonNull() && o.get("chartsLocked").getAsBoolean();
                    if (o.has("charts") && o.get("charts").isJsonObject()) {
                        JsonObject charts = o.getAsJsonObject("charts");
                        if (charts.has("workoutChart") && charts.get("workoutChart").isJsonObject())
                            workoutChart = ProgressModels.Chart.fromJson(charts.getAsJsonObject("workoutChart"));
                    }
                }
                render();
            });
        });
    }

    private void openPaywall(View v) {
        GoPremiumActivity.open(this);
    }

    // ------------------------------------------------------------------ rendering

    private void render() {
        renderTabs();
        body.removeAllViews();
        if (!historyTab) renderSummary(); else renderHistory();
    }

    private void renderTabs() {
        tabs.removeAllViews();
        String[] titles = {Tr.t("summary"), Tr.t("history")};
        for (int i = 0; i < 2; i++) {
            final boolean sel = (i == 1) == historyTab;
            final boolean toHistory = i == 1;
            LinearLayout col = new LinearLayout(this);
            col.setOrientation(LinearLayout.VERTICAL);
            TextView t = Kit.text(this, titles[i], 15, sel ? 700 : 500, sel ? 0xFFFFFFFF : 0x61FFFFFF);
            t.setGravity(Gravity.CENTER);
            t.setPadding(0, dp(12), 0, dp(12));
            col.addView(t, new LinearLayout.LayoutParams(-1, -2));
            View line = new View(this);
            line.setBackground(Kit.rounded(this, sel ? LIME : 0x00000000, 2));
            col.addView(line, new LinearLayout.LayoutParams(-1, Math.max(1, dp(2.5f))));
            col.setOnClickListener(v -> { historyTab = toHistory; render(); });
            tabs.addView(col, new LinearLayout.LayoutParams(0, -2, 1f));
        }
    }

    private void renderSummary() {
        body.addView(Kit.text(this, month, 12, 500, 0x99FFFFFF));
        View card = ProgressCards.summaryCard(this, workoutChart != null ? workoutChart.days : null,
                workoutChart != null ? workoutChart.weeklyAverageText : "1");
        body.addView(ProgressCards.premiumLock(this, card, chartsLocked, this::openPaywall), Kit.lp(this, -1, -2, 0, 12, 0, 0));
    }

    private void renderHistory() {
        String sectionTitle = selectedDay != null ? month + " (Day " + selectedDay + ")" : month;
        body.addView(ProgressCards.monthlyCalendar(this, month, completedDays, selectedDay,
                v -> shiftMonth(-1), v -> shiftMonth(1), (dayNumber, current) -> {
                    if (!current) return;
                    Integer newDay = (selectedDay != null && selectedDay == dayNumber) ? null : dayNumber;
                    selectedDay = newDay;
                    render();
                    fetchHistory(newDay, true, true);
                }));
        body.addView(Kit.text(this, sectionTitle, 12, 500, 0x99FFFFFF), Kit.lp(this, -2, -2, 0, 22, 0, 12));

        if (historyDays != null) {
            LinearLayout banner = new LinearLayout(this);
            banner.setGravity(Gravity.CENTER_VERTICAL);
            banner.setBackground(Kit.rounded(this, 0xFF1F290F, 14, 1, LIME));
            banner.setPadding(dp(14), dp(10), dp(14), dp(10));
            banner.addView(Icons.view(this, Icons.LOCK_ROUNDED, 16, LIME));
            banner.addView(Kit.text(this, "Showing last " + historyDays + " days. Go Premium for full history.", 12, 600, LIME),
                    Kit.lp(this, 0, -2, 8, 0, 0, 0));
            ((LinearLayout.LayoutParams) banner.getChildAt(1).getLayoutParams()).weight = 1f;
            banner.setOnClickListener(this::openPaywall);
            body.addView(banner, Kit.lp(this, -1, -2, 0, 0, 0, 12));
        }
        body.addView(ProgressCards.historyCard(this, logs, logs.size()));
    }

    private void shiftMonth(int delta) {
        monthDate.add(Calendar.MONTH, delta);
        monthDate.set(Calendar.DAY_OF_MONTH, 1);
        selectedDay = null;
        render();
        fetchHistory(null, true, false);
    }
}
