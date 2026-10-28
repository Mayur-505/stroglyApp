package com.strongly.strongly.model;

import com.google.gson.JsonObject;

/** Muscle group / target focus / "guess you may need" entry from /workouts/explore. */
public class ExploreItem {
    public final String id;
    public final String title;
    public final String workoutCount;
    public final String imagePath;

    public ExploreItem(String id, String title, String workoutCount, String imagePath) {
        this.id = id;
        this.title = title;
        this.workoutCount = workoutCount;
        this.imagePath = imagePath;
    }

    private static String s(JsonObject o, String k) {
        return o.has(k) && !o.get(k).isJsonNull() ? o.get(k).getAsString() : null;
    }

    public static ExploreItem fromJson(JsonObject o, String defaultCount, String defaultImage) {
        String id = s(o, "id"), title = s(o, "title"), count = s(o, "workoutCount"), img = s(o, "imagePath");
        return new ExploreItem(id != null ? id : "", title != null ? title : "",
                count != null ? count : defaultCount, img != null ? img : defaultImage);
    }
}
