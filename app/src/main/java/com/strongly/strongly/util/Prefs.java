package com.strongly.strongly.util;

import android.content.Context;
import android.content.SharedPreferences;

public final class Prefs {
    private static SharedPreferences sp;

    private Prefs() {}

    public static void init(Context c) {
        sp = c.getSharedPreferences("strongly_prefs", Context.MODE_PRIVATE);
    }

    public static String getString(String key, String def) { return sp.getString(key, def); }
    public static void putString(String key, String v) { sp.edit().putString(key, v).apply(); }
    public static boolean getBool(String key, boolean def) { return sp.getBoolean(key, def); }
    public static void putBool(String key, boolean v) { sp.edit().putBoolean(key, v).apply(); }
    public static void remove(String key) { sp.edit().remove(key).apply(); }
}
