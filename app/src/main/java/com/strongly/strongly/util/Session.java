package com.strongly.strongly.util;

import com.strongly.strongly.billing.PremiumService;

public final class Session {
    private static final String K_TOKEN = "strongly_auth_token";
    private static final String K_USER_ID = "strongly_user_id";
    private static final String K_GUEST = "strongly_is_guest";
    private static final String K_NAME = "strongly_user_name";
    private static final String K_EMAIL = "strongly_user_email";
    private static final String K_AVATAR = "strongly_user_avatar";
    public static final String K_LANG = "strongly_language";

    private Session() {}

    public static String token() { return Prefs.getString(K_TOKEN, null); }
    public static String userId() { return Prefs.getString(K_USER_ID, null); }
    public static boolean isGuest() { return Prefs.getBool(K_GUEST, false); }
    public static String userName() { return Prefs.getString(K_NAME, null); }
    public static String userEmail() { return Prefs.getString(K_EMAIL, null); }
    public static String userAvatar() { return Prefs.getString(K_AVATAR, null); }
    public static boolean isAuthenticated() { String t = token(); return t != null && !t.isEmpty(); }
    /** Flutter treats guests and signed-out sessions alike on the profile screens. */
    public static boolean isGuestOrAnonymous() { return isGuest() || !isAuthenticated(); }
    public static String language() { return Prefs.getString(K_LANG, "en"); }

    /** Like Flutter's saveSession: null name/email/avatar keep the stored value. */
    public static void save(String token, String userId, boolean guest, String name, String email, String avatar) {
        Prefs.putString(K_TOKEN, token);
        Prefs.putString(K_USER_ID, userId);
        Prefs.putBool(K_GUEST, guest);
        if (name != null) Prefs.putString(K_NAME, name);
        if (email != null) Prefs.putString(K_EMAIL, email);
        if (avatar != null) Prefs.putString(K_AVATAR, avatar);
        // load the new user's premium status
        PremiumService.get().refreshStatus(null);
    }

    public static void clear() {
        for (String k : new String[]{K_TOKEN, K_USER_ID, K_GUEST, K_NAME, K_EMAIL, K_AVATAR}) Prefs.remove(k);
        PremiumService.get().reset();
    }
}
