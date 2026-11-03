package com.ads.sdk.adssdk;

import android.content.Context;
import android.content.SharedPreferences;

public class PreferencesHelper {

    private static final String PREFS_NAME = "my_prefs";
    private static final String KEY_IS_LOCK = "is_lock";
    private static final String KEY_IS_ORGANIC= "is_organic";
    private static final String one_time_activity_call= "one_time_activity_call";
    private static final String KEY_AFFILIATE_ADS_JSON = "affiliate_ads_json";

    private final SharedPreferences sharedPreferences;
    private final SharedPreferences.Editor editor;

    public PreferencesHelper(Context context) {
        sharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        editor = sharedPreferences.edit();
    }

    public void setLock(boolean isLoggedIn) {
        editor.putBoolean(KEY_IS_LOCK, isLoggedIn);
        editor.apply();
    }

    public boolean getLock() {
        return sharedPreferences.getBoolean(KEY_IS_LOCK, false);
    }

    public void seIsOrganic(boolean isLoggedIn) {
        editor.putBoolean(KEY_IS_ORGANIC, isLoggedIn);
        editor.apply();
    }

    public boolean IsOrganic() {
        return sharedPreferences.getBoolean(KEY_IS_ORGANIC, false);
    }

    public void set_one_time_activity_call(boolean lock) {
        editor.putBoolean(one_time_activity_call, lock);
        editor.apply();
    }

    public boolean get_one_time_activity_call() {
        return sharedPreferences.getBoolean(one_time_activity_call, false);
    }

    public void setAffiliateAdsJson(String json) {
        editor.putString(KEY_AFFILIATE_ADS_JSON, json != null ? json : "");
        editor.apply();
    }

    public String getAffiliateAdsJson() {
        return sharedPreferences.getString(KEY_AFFILIATE_ADS_JSON, "");
    }

    public void clear() {
        editor.clear();
        editor.apply();
    }
}