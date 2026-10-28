package com.strongly.strongly.ui;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.strongly.strongly.model.ProgressModels;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.net.ApiConstants;
import com.strongly.strongly.util.Session;
import com.strongly.strongly.util.Tr;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

/** Progress tab: week strip, stat cards, steps gauge and weekly charts. */
public class ProgressFragment extends Fragment {
    private SwipeRefreshLayout refresh;
    private LinearLayout content;

    private List<ProgressModels.DayStatus> weekDays = new ArrayList<>();
    private ProgressModels.Stat workout = new ProgressModels.Stat("Workout", "min", "0", "0");
    private ProgressModels.Stat calories = new ProgressModels.Stat("Calories", "cal", "0", "0");
    private ProgressModels.Stat weight = new ProgressModels.Stat("Weight", "lbs", "0", "0");
    private int currentSteps = 0, targetSteps = 6000;
    private ProgressModels.Chart workoutChart = ProgressModels.Chart.empty("Workout", "0 min");
    private ProgressModels.Chart calorieChart = ProgressModels.Chart.empty("Calories", "0 Calories");
    private boolean chartsLocked = false;
    private String loadedLanguage;

    @Nullable @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle state) {
        Context c = requireContext();
        refresh = new SwipeRefreshLayout(c);
        refresh.setColorSchemeColors(0xFFCEFF00);
        refresh.setProgressBackgroundColorSchemeColor(0xFF161619);
        ScrollView sv = new ScrollView(c);
        sv.setVerticalScrollBarEnabled(false);
        content = new LinearLayout(c);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setPadding(Kit.dp(c, 20), Kit.dp(c, 10), Kit.dp(c, 20), Kit.dp(c, 30));
        sv.addView(content, new ViewGroup.LayoutParams(-1, -2));
        refresh.addView(sv);
        refresh.setOnRefreshListener(this::fetchDashboard);
        weekDays = defaultWeekDays();
        loadedLanguage = Session.language();
        render();
        fetchDashboard();
        return refresh;
    }

    @Override
    public void onResume() {
        super.onResume();
        if (chartsLocked && com.strongly.strongly.billing.PremiumService.get().isPremium()) fetchDashboard();
        if (loadedLanguage != null && !loadedLanguage.equals(Session.language())) {
            loadedLanguage = Session.language();
            fetchDashboard();
        }
    }

    // ------------------------------------------------------------------ data

    private List<ProgressModels.DayStatus> defaultWeekDays() {
        String[] names = {"S", "M", "T", "W", "T", "F", "S"};
        Calendar today = Calendar.getInstance();
        Calendar sunday = (Calendar) today.clone();
        sunday.add(Calendar.DAY_OF_MONTH, -(today.get(Calendar.DAY_OF_WEEK) - 1));
        List<ProgressModels.DayStatus> out = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            Calendar d = (Calendar) sunday.clone();
            d.add(Calendar.DAY_OF_MONTH, i);
            boolean isToday = d.get(Calendar.DAY_OF_MONTH) == today.get(Calendar.DAY_OF_MONTH)
                    && d.get(Calendar.MONTH) == today.get(Calendar.MONTH);
            out.add(new ProgressModels.DayStatus(names[i], String.valueOf(d.get(Calendar.DAY_OF_MONTH)), false, isToday));
        }
        return out;
    }

    /** Called by the host when the tab is selected (Flutter's ProgressScreenState.fetchDashboard). */
    public void fetchDashboard() {
        if (!isAdded()) return;
        ApiClient.get().get(ApiConstants.PROGRESS_DASHBOARD, null, r -> {
            if (!isAdded()) return;
            refresh.setRefreshing(false);
            JsonObject d = r.isOk() && r.data != null && r.data.isJsonObject() ? r.data.getAsJsonObject() : new JsonObject();
            JsonObject stats = obj(d, "stats"), charts = obj(d, "charts");

            chartsLocked = d.has("chartsLocked") && !d.get("chartsLocked").isJsonNull() && d.get("chartsLocked").getAsBoolean();
            List<ProgressModels.DayStatus> days = new ArrayList<>();
            if (d.has("weekDays") && d.get("weekDays").isJsonArray())
                for (JsonElement e : d.getAsJsonArray("weekDays")) if (e.isJsonObject()) days.add(ProgressModels.DayStatus.fromJson(e.getAsJsonObject()));
            weekDays = days.isEmpty() ? defaultWeekDays() : days;

            workout = stats.has("workout") && stats.get("workout").isJsonObject()
                    ? ProgressModels.Stat.fromJson(stats.getAsJsonObject("workout")) : new ProgressModels.Stat("Workout", "min", "0", "0");
            calories = stats.has("calories") && stats.get("calories").isJsonObject()
                    ? ProgressModels.Stat.fromJson(stats.getAsJsonObject("calories")) : new ProgressModels.Stat("Calories", "cal", "0", "0");
            weight = stats.has("weight") && stats.get("weight").isJsonObject()
                    ? ProgressModels.Stat.fromJson(stats.getAsJsonObject("weight")) : new ProgressModels.Stat("Weight", "lbs", "0", "0");

            if (stats.has("steps") && stats.get("steps").isJsonObject()) {
                JsonObject s = stats.getAsJsonObject("steps");
                currentSteps = intOf(s, "currentSteps", 0);
                targetSteps = intOf(s, "targetSteps", 6000);
            } else { currentSteps = 0; targetSteps = 6000; }

            workoutChart = charts.has("workoutChart") && charts.get("workoutChart").isJsonObject()
                    ? ProgressModels.Chart.fromJson(charts.getAsJsonObject("workoutChart")) : ProgressModels.Chart.empty("Workout", "0 min");
            calorieChart = charts.has("calorieChart") && charts.get("calorieChart").isJsonObject()
                    ? ProgressModels.Chart.fromJson(charts.getAsJsonObject("calorieChart")) : ProgressModels.Chart.empty("Calories", "0 Calories");
            render();
        });
    }

    private static JsonObject obj(JsonObject o, String k) {
        return o.has(k) && o.get(k).isJsonObject() ? o.getAsJsonObject(k) : new JsonObject();
    }

    private static int intOf(JsonObject o, String k, int def) {
        if (!o.has(k) || o.get(k).isJsonNull()) return def;
        try { return o.get(k).getAsInt(); } catch (Exception e) {
            try { return Integer.parseInt(o.get(k).getAsString()); } catch (Exception e2) { return def; }
        }
    }

    // ------------------------------------------------------------------ rendering

    private void openDetail(boolean history) {
        Intent i = new Intent(requireContext(), ProgressDetailActivity.class);
        i.putExtra(ProgressDetailActivity.EXTRA_HISTORY, history);
        startActivity(i);
    }

    private void unlockCharts(View v) {
        GoPremiumActivity.open(requireContext());
    }

    private void render() {
        Context c = requireContext();
        content.removeAllViews();

        LinearLayout top = new LinearLayout(c);
        top.setGravity(Gravity.CENTER_VERTICAL);
        TextView back = Icons.view(c, Icons.ARROW_BACK_ROUNDED, 22, 0xFFFFFFFF);
        back.setOnClickListener(v -> { if (getActivity() instanceof HomeActivity) ((HomeActivity) getActivity()).goHome(); });
        top.addView(back, new LinearLayout.LayoutParams(Kit.dp(c, 38), Kit.dp(c, 38)));
        top.addView(Kit.text(c, Tr.t("progress_title"), 24, 800, 0xFFFFFFFF), Kit.lp(c, -2, -2, 8, 0, 0, 0));
        content.addView(top, new LinearLayout.LayoutParams(-1, -2));

        content.addView(ProgressCards.weeklyCalendar(c, weekDays, v -> openDetail(true)), Kit.lp(c, -1, -2, 0, 18, 0, 0));

        LinearLayout row1 = new LinearLayout(c);
        row1.setGravity(Gravity.CENTER_VERTICAL);
        row1.addView(ProgressCards.statCard(c, workout, v -> openDetail(false)), new LinearLayout.LayoutParams(0, -2, 1f));
        row1.addView(ProgressCards.statCard(c, calories, v -> openDetail(false)), Kit.lp(c, 0, -2, 12, 0, 0, 0));
        ((LinearLayout.LayoutParams) row1.getChildAt(1).getLayoutParams()).weight = 1f;
        content.addView(row1, Kit.lp(c, -1, -2, 0, 14, 0, 0));

        LinearLayout row2 = new LinearLayout(c);
        row2.setGravity(Gravity.CENTER_VERTICAL);
        row2.addView(ProgressCards.statCard(c, weight, v -> openDetail(false)), new LinearLayout.LayoutParams(0, -2, 1f));
        row2.addView(ProgressCards.stepsCard(c, currentSteps, targetSteps, v -> openDetail(false)), Kit.lp(c, 0, -2, 12, 0, 0, 0));
        ((LinearLayout.LayoutParams) row2.getChildAt(1).getLayoutParams()).weight = 1f;
        content.addView(row2, Kit.lp(c, -1, -2, 0, 12, 0, 0));

        content.addView(ProgressCards.premiumLock(c, ProgressCards.barChart(c, workoutChart, v -> openDetail(false)),
                chartsLocked, this::unlockCharts), Kit.lp(c, -1, -2, 0, 14, 0, 0));
        content.addView(ProgressCards.premiumLock(c, ProgressCards.barChart(c, calorieChart, v -> openDetail(false)),
                chartsLocked, this::unlockCharts), Kit.lp(c, -1, -2, 0, 14, 0, 0));
    }
}
