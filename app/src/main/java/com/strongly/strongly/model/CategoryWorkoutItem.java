package com.strongly.strongly.model;

import com.google.gson.JsonObject;

import java.io.Serializable;

public class CategoryWorkoutItem implements Serializable {
    public final String id;
    public final String title;
    public final String category;
    public final int levels;
    public final String duration;
    public final String imagePath;
    public boolean isFree;

    public CategoryWorkoutItem(String id, String title, String category, int levels, String duration,
                               String imagePath, boolean isFree) {
        this.id = id;
        this.title = title;
        this.category = category;
        this.levels = levels;
        this.duration = duration;
        this.imagePath = imagePath;
        this.isFree = isFree;
    }

    public boolean isLocked() { return !isFree; }

    private static String s(JsonObject o, String k) {
        return o.has(k) && !o.get(k).isJsonNull() ? o.get(k).getAsString() : null;
    }

    public static CategoryWorkoutItem fromJson(JsonObject o) {
        String id = s(o, "id");
        if (id == null) id = s(o, "_id");
        String title = s(o, "title"), category = s(o, "category"), duration = s(o, "duration"), image = s(o, "imagePath");
        int levels = 6;
        if (o.has("levelsCount") && !o.get("levelsCount").isJsonNull()) {
            try { levels = o.get("levelsCount").getAsInt(); } catch (Exception ignored) { }
        }
        boolean free = true;
        if (o.has("isFree") && !o.get("isFree").isJsonNull()) free = o.get("isFree").getAsBoolean();
        return new CategoryWorkoutItem(id != null ? id : "", title != null ? title : "",
                category != null ? category : "Full body", levels,
                duration != null ? duration : "20 min",
                image != null ? image : "assets/images/featured_workout.jpg", free);
    }
}
