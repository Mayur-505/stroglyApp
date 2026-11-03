package com.ads.sdk.adssdk;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;


public class AppPreference {

    private static SharedPreferences sharedPreferences;
    private static SharedPreferences.Editor editor;
    public static int NativeCount = 1;
    public static int InterstitialCount = 1;

    public AppPreference(Context activity) {
        sharedPreferences = activity.getSharedPreferences("PREF_NAME", Context.MODE_PRIVATE);
        editor = sharedPreferences.edit();
    }

    public static void setPrefs(String key, String value) {
        if (editor != null) {
            editor.putString(key, value);
            editor.apply();
        }
    }

    public static void setPrefs(String key, int value) {
        if (editor != null) {
            editor.putInt(key, value);
            editor.apply();
        }
    }


    public static String getPref(String key) {
        if (sharedPreferences != null) {
            return sharedPreferences.getString(key, "");
        }
        return "";
    }

    public static int getint(String key) {
        if (sharedPreferences != null) {
            return sharedPreferences.getInt(key, 0);
        }
        return 0;
    }

    public String AdmobAppopenKey() {
        return getPref("AdmobAppopenKey");
    }

    public String AdmobSplashAppopenKey() {
        return getPref("AdmobSplashAppopenKey");
    }


    // Admobinterstitial start
    public String AdmobIntertitialKey1() {
        return getPref("AdmobIntertitialKey1");
    }

    public String AdmobIntertitialKey2() {
        return getPref("AdmobIntertitialKey2");
    }

    public String AdmobIntertitialKey3() {
        return getPref("AdmobIntertitialKey3");
    }

    public String AdmobIntertitialKey4() {
        return getPref("AdmobIntertitialKey4");
    }

    public String AdmobIntertitialKey5() {
        return getPref("AdmobIntertitialKey5");
    }
    // Admobinterstitial end


    // Admobbanner start
    public String AdmobBannerKey1() {
        return getPref("AdmobBannerKey1");
    }

    public String AdmobBannerKey2() {
        return getPref("AdmobBannerKey2");
    }

    public String AdmobBannerKey3() {
        return getPref("AdmobBannerKey3");
    }

    public String AdmobBannerKey4() {
        return getPref("AdmobBannerKey4");
    }

    public String AdmobBannerKey5() {
        return getPref("AdmobBannerKey5");
    }
    // Admobbanner end


    // AdmobRectanglebanner start
    public String AdmobRectangleBannerKey1() {
        return getPref("AdmobRectangleBannerKey1");
    }

    public String AdmobRectangleBannerKey2() {
        return getPref("AdmobRectangleBannerKey2");
    }

    public String AdmobRectangleBannerKey3() {
        return getPref("AdmobRectangleBannerKey3");
    }

    public String AdmobRectangleBannerKey4() {
        return getPref("AdmobRectangleBannerKey4");
    }

    public String AdmobRectangleBannerKey5() {
        return getPref("AdmobRectangleBannerKey5");
    }
    // AdmobRectanglebanner end


    // AdmobNative start
    public String AdmobNativeKey1() {
        return getPref("AdmobNativeKey1");
    }

    public String AdmobNativeKey2() {
        return getPref("AdmobNativeKey2");
    }

    public String AdmobNativeKey3() {
        return getPref("AdmobNativeKey3");
    }

    public String AdmobNativeKey4() {
        return getPref("AdmobNativeKey4");
    }

    public String AdmobNativeKey5() {
        return getPref("AdmobNativeKey5");
    }
    // AdmobNative end


    // facebookbanner start
    public String FacebookBannerKey1() {
        return getPref("FacebookBannerKey1");
    }

    public String FacebookBannerKey2() {
        return getPref("FacebookBannerKey2");
    }

    public String FacebookBannerKey3() {
        return getPref("FacebookBannerKey3");
    }

    public String FacebookBannerKey4() {
        return getPref("FacebookBannerKey4");
    }

    public String FacebookBannerKey5() {
        return getPref("FacebookBannerKey5");
    }
    // facebookbanner end


    // FacebookRectangleBanner start
    public String FacebookRectangleBannerKey1() {
        return getPref("FacebookRectangleBannerKey1");
    }

    public String FacebookRectangleBannerKey2() {
        return getPref("FacebookRectangleBannerKey2");
    }

    public String FacebookRectangleBannerKey3() {
        return getPref("FacebookRectangleBannerKey3");
    }

    public String FacebookRectangleBannerKey4() {
        return getPref("FacebookRectangleBannerKey4");
    }

    public String FacebookRectangleBannerKey5() {
        return getPref("FacebookRectangleBannerKey5");
    }
    // FacebookRectangleBanner end


    // FacebookNative Start
    public String FacebookNativeKey1() {
        return getPref("FacebookNativeKey1");
    }

    public String FacebookNativeKey2() {
        return getPref("FacebookNativeKey2");
    }

    public String FacebookNativeKey3() {
        return getPref("FacebookNativeKey3");
    }

    public String FacebookNativeKey4() {
        return getPref("FacebookNativeKey4");
    }

    public String FacebookNativeKey5() {
        return getPref("FacebookNativeKey5");
    }
    // FacebookNative end


    // FacebookInterstitial Start
    public String FacebookIntertitialKey1() {
        return getPref("FacebookIntertitialKey1");
    }

    public String FacebookIntertitialKey2() {
        return getPref("FacebookIntertitialKey2");
    }

    public String FacebookIntertitialKey3() {
        return getPref("FacebookIntertitialKey3");
    }

    public String FacebookIntertitialKey4() {
        return getPref("FacebookIntertitialKey4");
    }

    public String FacebookIntertitialKey5() {
        return getPref("FacebookIntertitialKey5");
    }
    // FacebookInterstitial end


    public static boolean CheckInternet(Activity activity) {
        ConnectivityManager cm = (ConnectivityManager) activity.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo networkInfo = cm.getActiveNetworkInfo();
        if (networkInfo != null && networkInfo.isConnectedOrConnecting()) {
            return true;
        }
        return false;
    }
}
