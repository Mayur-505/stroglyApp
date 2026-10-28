package com.strongly.strongly.model;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.List;

/** Progress tab models (Flutter's progress_models.dart). */
public final class ProgressModels {
    private ProgressModels() {}

    static String str(JsonObject o, String k, String def) {
        return o.has(k) && !o.get(k).isJsonNull() ? o.get(k).getAsString() : def;
    }

    static boolean bool(JsonObject o, String k) {
        return o.has(k) && !o.get(k).isJsonNull() && o.get(k).getAsBoolean();
    }

    static double dbl(JsonObject o, String k) {
        if (!o.has(k) || o.get(k).isJsonNull()) return 0.0;
        try { return o.get(k).getAsDouble(); } catch (Exception e) { return 0.0; }
    }

    public static class DayStatus {
        public final String dayName, dateText;
        public final boolean isCompleted, isToday;

        public DayStatus(String dayName, String dateText, boolean isCompleted, boolean isToday) {
            this.dayName = dayName; this.dateText = dateText; this.isCompleted = isCompleted; this.isToday = isToday;
        }

        public static DayStatus fromJson(JsonObject o) {
            return new DayStatus(str(o, "dayName", ""), str(o, "dateText", ""), bool(o, "isCompleted"), bool(o, "isToday"));
        }
    }

    public static class Stat {
        public final String title, unit, totalValue, weekValue;

        public Stat(String title, String unit, String totalValue, String weekValue) {
            this.title = title; this.unit = unit; this.totalValue = totalValue; this.weekValue = weekValue;
        }

        public static Stat fromJson(JsonObject o) {
            return new Stat(str(o, "title", ""), str(o, "unit", ""), str(o, "totalValue", "0"), str(o, "weekValue", "0"));
        }
    }

    public static class ChartDay {
        public final String dayLabel;
        public final double value;
        public final boolean hasActivity, isHighlighted;

        public ChartDay(String dayLabel, double value, boolean hasActivity, boolean isHighlighted) {
            this.dayLabel = dayLabel; this.value = value; this.hasActivity = hasActivity; this.isHighlighted = isHighlighted;
        }

        public static ChartDay fromJson(JsonObject o) {
            return new ChartDay(str(o, "dayLabel", ""), dbl(o, "value"), bool(o, "hasActivity"), bool(o, "isHighlighted"));
        }
    }

    public static class Chart {
        public final String metricTitle, weeklyAverageText, mainValueText;
        public final List<ChartDay> days;

        public Chart(String metricTitle, String weeklyAverageText, String mainValueText, List<ChartDay> days) {
            this.metricTitle = metricTitle; this.weeklyAverageText = weeklyAverageText;
            this.mainValueText = mainValueText; this.days = days;
        }

        public static Chart fromJson(JsonObject o) {
            List<ChartDay> days = new ArrayList<>();
            if (o.has("days") && o.get("days").isJsonArray())
                for (JsonElement e : o.getAsJsonArray("days")) if (e.isJsonObject()) days.add(ChartDay.fromJson(e.getAsJsonObject()));
            return new Chart(str(o, "metricTitle", ""), str(o, "weeklyAverageText", ""), str(o, "mainValueText", ""), days);
        }

        public static Chart empty(String title, String avg) {
            String[] names = {"S", "M", "T", "W", "T", "F", "S"};
            List<ChartDay> days = new ArrayList<>();
            for (String n : names) days.add(new ChartDay(n, 0.0, false, false));
            return new Chart(title, avg, avg, days);
        }
    }

    public static class HistoryLog {
        public final String id, title, time, date, duration, calories;

        public HistoryLog(String id, String title, String time, String date, String duration, String calories) {
            this.id = id; this.title = title; this.time = time; this.date = date; this.duration = duration; this.calories = calories;
        }

        public static HistoryLog fromJson(JsonObject o) {
            String id = str(o, "id", null);
            if (id == null) id = str(o, "_id", "");
            return new HistoryLog(id, str(o, "title", ""), str(o, "time", ""), str(o, "date", ""),
                    str(o, "duration", ""), str(o, "calories", ""));
        }
    }
}
