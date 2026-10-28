package com.strongly.strongly.util;

import android.content.Context;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.InputStreamReader;
import java.util.Map;

/** Runtime translations loaded from assets/translations.json (language -> key -> text). */
public final class Tr {
    private static Map<String, Map<String, String>> all;

    private Tr() {}

    public static void init(Context c) {
        try (InputStreamReader r = new InputStreamReader(c.getAssets().open("translations.json"), "UTF-8")) {
            all = new Gson().fromJson(r, new TypeToken<Map<String, Map<String, String>>>() {}.getType());
        } catch (Exception e) {
            all = new java.util.HashMap<>();
        }
    }

    public static boolean supports(String code) { return all != null && all.containsKey(code); }

    public static String t(String key) {
        if (all == null) return key;
        Map<String, String> m = all.get(Session.language());
        if (m != null && m.containsKey(key)) return m.get(key);
        Map<String, String> en = all.get("en");
        if (en != null && en.containsKey(key)) return en.get(key);
        return key;
    }

    public static void setLanguage(String code) {
        if (supports(code)) Prefs.putString(Session.K_LANG, code);
    }
}
