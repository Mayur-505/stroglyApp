package com.strongly.strongly.model;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.List;

/** Workout plan detail models (Flutter's workout_detail_models.dart / exercise_detail_models.dart). */
public final class PlanModels {
    private PlanModels() {}

    static String str(JsonObject o, String k, String def) {
        return o.has(k) && !o.get(k).isJsonNull() ? o.get(k).getAsString() : def;
    }

    static int integer(JsonObject o, String k, int def) {
        if (!o.has(k) || o.get(k).isJsonNull()) return def;
        try { return o.get(k).getAsInt(); } catch (Exception e) {
            try { return (int) Double.parseDouble(o.get(k).getAsString()); } catch (Exception e2) { return def; }
        }
    }

    static double dbl(JsonObject o, String k, double def) {
        if (!o.has(k) || o.get(k).isJsonNull()) return def;
        try { return o.get(k).getAsDouble(); } catch (Exception e) { return def; }
    }

    static boolean bool(JsonObject o, String k) {
        return o.has(k) && !o.get(k).isJsonNull() && o.get(k).getAsBoolean();
    }

    public static class Day {
        public final int dayNumber;
        public final String duration;
        public final double progress;
        public final boolean isUnlocked, isCompleted;

        public Day(int dayNumber, String duration, double progress, boolean isUnlocked, boolean isCompleted) {
            this.dayNumber = dayNumber;
            this.duration = duration;
            this.progress = progress;
            this.isUnlocked = isUnlocked;
            this.isCompleted = isCompleted;
        }

        public boolean isInProgress() { return isUnlocked && !isCompleted && progress > 0; }

        public static Day fromJson(JsonObject o) {
            return new Day(integer(o, "dayNumber", 1), str(o, "duration", "10-20 min"),
                    dbl(o, "progress", 0.0), bool(o, "isUnlocked"), bool(o, "isCompleted"));
        }
    }

    public static class Detail {
        public final String id, title, heroImage, dailyDuration, description1, description2;
        public final int totalDays, strengthLevel, cardioLevel;
        public final List<Day> days;

        Detail(String id, String title, String heroImage, int totalDays, String dailyDuration, int strength, int cardio,
               String d1, String d2, List<Day> days) {
            this.id = id; this.title = title; this.heroImage = heroImage; this.totalDays = totalDays;
            this.dailyDuration = dailyDuration; this.strengthLevel = strength; this.cardioLevel = cardio;
            this.description1 = d1; this.description2 = d2; this.days = days;
        }

        public static Detail fromJson(JsonObject o) {
            List<Day> days = new ArrayList<>();
            if (o.has("days") && o.get("days").isJsonArray())
                for (JsonElement e : o.getAsJsonArray("days")) if (e.isJsonObject()) days.add(Day.fromJson(e.getAsJsonObject()));
            String id = str(o, "id", null);
            if (id == null) id = str(o, "_id", "");
            return new Detail(id, str(o, "title", "Workout Plan"), str(o, "heroImage", "assets/images/featured_workout.jpg"),
                    integer(o, "totalDays", 30), str(o, "dailyDuration", "8-15"), integer(o, "strengthLevel", 2),
                    integer(o, "cardioLevel", 2), str(o, "descriptionParagraph1", ""), str(o, "descriptionParagraph2", ""), days);
        }
    }

    public static class Exercise implements java.io.Serializable {
        public final String id, title, targetArea, imagePath, videoUrl, duration;
        public final List<String> instructions, keyTips;

        Exercise(String id, String title, String targetArea, String imagePath, String videoUrl, String duration,
                 List<String> instructions, List<String> keyTips) {
            this.id = id; this.title = title; this.targetArea = targetArea; this.imagePath = imagePath;
            this.videoUrl = videoUrl; this.duration = duration; this.instructions = instructions; this.keyTips = keyTips;
        }

        static List<String> strings(JsonObject o, String k) {
            List<String> out = new ArrayList<>();
            if (o.has(k) && o.get(k).isJsonArray()) for (JsonElement e : o.getAsJsonArray(k)) out.add(e.getAsString());
            return out;
        }

        public static Exercise fromJson(JsonObject o) {
            String id = str(o, "id", null);
            if (id == null) id = str(o, "_id", "");
            return new Exercise(id, str(o, "title", ""), str(o, "targetArea", ""),
                    str(o, "imagePath", "assets/images/jumping_jacks.jpg"), str(o, "videoUrl", null),
                    str(o, "duration", "00:30"), strings(o, "instructions"), strings(o, "keyTips"));
        }
    }
}
