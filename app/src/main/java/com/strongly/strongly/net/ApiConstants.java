package com.strongly.strongly.net;

public final class ApiConstants {
    private ApiConstants() {}

    public static final String BASE_URL = "https://2846z2xn-5001.inc1.devtunnels.ms/api/v1";

    public static final String HEALTH = "/health";
    public static final String GUEST_LOGIN = "/auth/guest";
    public static final String GOOGLE_LOGIN = "/auth/google";
    public static final String SIGNUP = "/auth/signup";
    public static final String LOGIN = "/auth/login";
    public static final String FORGOT_PASSWORD = "/auth/forgot-password";
    public static final String RESEND_OTP = "/auth/resend-otp";
    public static final String OTP_VERIFY = "/auth/otp-verify";
    public static final String RESET_PASSWORD = "/auth/reset-password";
    public static final String ME = "/auth/me";
    public static final String LOGOUT = "/auth/logout";
    public static final String QUESTIONNAIRE = "/user/questionnaire";
    public static final String UPDATE_LANGUAGE = "/user/language";
    public static final String BACKUP = "/user/backup";
    public static final String RESTORE = "/user/restore";
    public static final String UPLOAD_PHOTO = "/upload/photo";
    public static final String HOME_FEED = "/home/feed";
    public static final String EXPLORE_WORKOUTS = "/workouts/explore";
    public static final String CATEGORY_WORKOUTS = "/workouts/categories";
    public static final String SEARCH_TAGS = "/workouts/search-tags";
    public static final String SEARCH_WORKOUTS = "/workouts/search";
    public static final String PROGRESS_DASHBOARD = "/progress/dashboard";
    public static final String PROGRESS_HISTORY = "/progress/history";
    public static final String LOG_WEIGHT = "/progress/weight";
    public static final String SYNC_STEPS = "/progress/steps";
    public static final String SUBSCRIPTION_PLANS = "/subscriptions/plans";
    public static final String VERIFY_PURCHASE = "/subscriptions/verify";
    public static final String SUBSCRIPTION_STATUS = "/subscriptions/my-status";
    public static final String RESTORE_PURCHASES = "/subscriptions/restore";
    public static final String CANCEL_SUBSCRIPTION = "/subscriptions/cancel";
    public static final String SUBSCRIPTION_HISTORY = "/subscriptions/history";

    public static String customizationOptions(String id) { return "/workouts/" + id + "/customization-options"; }
    public static String planDetail(String planId) { return "/plans/" + planId; }
    public static String planDayExercises(String planId, int day) { return "/plans/" + planId + "/days/" + day; }
    public static String completePlanDay(String planId, int day) { return "/plans/" + planId + "/days/" + day + "/complete"; }
}
