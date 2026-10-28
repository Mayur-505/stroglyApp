package com.strongly.strongly.model;

import com.google.gson.JsonObject;

public class WorkoutItem {
    public final String id;
    public final String title;
    public final String duration;
    public final String calories;
    public final String level;
    public final String imagePath;
    public final boolean isFeatured;

    public WorkoutItem(String id, String title, String duration, String calories, String level,
                       String imagePath, boolean isFeatured) {
        this.id = id;
        this.title = title;
        this.duration = duration;
        this.calories = calories;
        this.level = level;
        this.imagePath = imagePath;
        this.isFeatured = isFeatured;
    }

    private static String s(JsonObject o, String k) {
        return o.has(k) && !o.get(k).isJsonNull() ? o.get(k).getAsString() : null;
    }

    public static WorkoutItem fromJson(JsonObject o) {
        String id = s(o, "id");
        if (id == null) id = s(o, "_id");
        String title = s(o, "title");
        String duration = s(o, "duration");
        String calories = s(o, "calories");
        String image = s(o, "imagePath");
        return new WorkoutItem(
                id != null ? id : "",
                title != null ? title : "",
                duration != null ? duration : "20 min",
                calories != null ? calories : "200 kcal",
                s(o, "level"),
                image != null ? image : "assets/images/featured_workout.jpg",
                o.has("isFeatured") && !o.get("isFeatured").isJsonNull() && o.get("isFeatured").getAsBoolean());
    }
}
