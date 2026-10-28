package com.strongly.strongly.model;

import com.google.gson.JsonObject;
import com.strongly.strongly.ui.Icons;

import java.util.Locale;

public class WorkoutCategory {
    public final String id;
    public final String name;
    public final int icon;

    public WorkoutCategory(String id, String name, int icon) {
        this.id = id;
        this.name = name;
        this.icon = icon;
    }

    private static String s(JsonObject o, String k) {
        return o.has(k) && !o.get(k).isJsonNull() ? o.get(k).getAsString() : "";
    }

    public static WorkoutCategory fromJson(JsonObject o) {
        String rawId = s(o, "id");
        String rawName = s(o, "name");
        String iconStr = s(o, "icon").toLowerCase(Locale.ROOT);
        String idLower = rawId.toLowerCase(Locale.ROOT);

        int icon;
        if (iconStr.contains("home") || idLower.contains("home")) icon = Icons.HOME_ROUNDED;
        else if (iconStr.contains("fire") || iconStr.contains("burn") || idLower.contains("burn")) icon = Icons.FIRE_ROUNDED;
        else if (iconStr.contains("bolt") || iconStr.contains("strength") || idLower.contains("strength")) icon = Icons.BOLT_ROUNDED;
        else if (iconStr.contains("self") || iconStr.contains("yoga") || idLower.contains("yoga") || idLower.contains("stretch"))
            icon = Icons.SELF_IMPROVEMENT_ROUNDED;
        else if (idLower.contains("full") || idLower.contains("body")) icon = Icons.ACCESSIBILITY_NEW_ROUNDED;
        else if (idLower.contains("abs") || idLower.contains("core")) icon = Icons.GYMNASTICS_ROUNDED;
        else icon = Icons.FITNESS_CENTER;

        String name = rawName;
        if (name.isEmpty() || name.equals(rawId)) {
            StringBuilder sb = new StringBuilder();
            for (String w : rawId.replace("_", " ").split(" ")) {
                if (w.isEmpty()) continue;
                if (sb.length() > 0) sb.append(' ');
                sb.append(Character.toUpperCase(w.charAt(0))).append(w.substring(1));
            }
            name = sb.toString();
        }
        return new WorkoutCategory(rawId, name, icon);
    }
}
