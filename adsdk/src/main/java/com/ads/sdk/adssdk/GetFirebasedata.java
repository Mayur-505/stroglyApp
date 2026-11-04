package com.ads.sdk.adssdk;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.List;

public class GetFirebasedata {
    public static Activity activity;
    public static int InterCount;
    public static int InterCountRefral;
    public static int LoanTypeCounter;
    public static int NativeCount;
    public static int NativeCountRefral;
    public static int BannerCount;
    public static int BannerCountRefral;
    public static int RecbannerorNative;
    public static int RecbannerorNativeCounter = 1;
    public static int Extrascreen;
    public static boolean ExtraLooping;
    public static int AdsType;
    public static int InterorAppopen;
    public static int InterorAppopen_reff = 1;
    public static int Adsdemotype;
    public static int FacebookCustom;
    public static int Isonnotification;
    public static int SmallnativeorBignative;
    public static int Timing;
    public static String QurekaAppURL;
    public static String qureka_server;
    public static String notification_server;
    public static String gamePlayURL;
    public static String privacy_policy_url;
    public static Boolean showNotnotButton;
    public static int notifiction_time = 1;
    public static int BackPressAd;
    public static int BackPressAdCounterRefral;
    public static int BackPressAdCounter;
    public static int BannerorCollepsiblebanner;
    public static int NewBannerorCollepsiblebanner;
    public static int ShowLoanTypesButton;
    public static boolean ShowAffiliateAd = false;

    // Google's published test ad units, used when no config JSON is given
    private static final String TEST_INTERSTITIAL = "ca-app-pub-3940256099942544/1033173712";
    private static final String TEST_NATIVE = "ca-app-pub-3940256099942544/2247696110";
    private static final String TEST_BANNER = "ca-app-pub-3940256099942544/6300978111";
    private static final String TEST_APP_OPEN = "ca-app-pub-3940256099942544/9257395921";
    private static final String TEST_REWARDED = "ca-app-pub-3940256099942544/5224354917";

    public static String getNextQurekaUrl(Context context) {
        if (TextUtils.isEmpty(QurekaAppURL)) {
            return "";
        }
        String[] urls = QurekaAppURL.split(",");
        if (urls.length == 0) {
            return "";
        }
        if (context != null) {
            new AppPreference(context);
        }
        int index = AppPreference.getint("qureka_index");
        if (index >= urls.length || index < 0) {
            index = 0;
        }
        AppPreference.setPrefs("qureka_index", index + 1);
        return urls[index].trim();
    }

    public GetFirebasedata(Activity activity) {
        GetFirebasedata.activity = activity;
    }

    /** Fills {@code list} from the keys prefix1..prefix5; without any JSON the test unit is used instead. */
    private static void ids(List<String> list, JSONObject o, boolean hasJson, String prefix, String testId) {
        list.clear();
        if (!hasJson) {
            if (testId != null) for (int i = 0; i < 5; i++) list.add(testId);
            return;
        }
        for (int i = 1; i <= 5; i++) {
            String id = o.optString(prefix + i, "").trim();
            if (!id.isEmpty()) list.add(id);
        }
    }

    /** Same as {@link #applyConfigJson} with no JSON: Google's test ad units and AdMob-only settings. */
    public static void applyTestConfig(Activity activity) {
        applyConfigJson(activity, null);
    }

    /**
     * Applies the ads configuration (the JSON that used to live in Firebase Remote Config under "ADID") and
     * starts the preloads: one interstitial, one reward ad and the launch app-open ad. Keys that are missing keep a
     * safe default, so a short JSON works. Safe to call repeatedly.
     */
    public static void applyConfigJson(Activity activity, String json) {
        GetFirebasedata.activity = activity;
        new AppPreference(activity); // initializes the static prefs/editor used by setPrefs

        JSONObject o = new JSONObject();
        boolean hasJson = false;
        if (!TextUtils.isEmpty(json)) {
            try {
                o = new JSONObject(json);
                hasJson = true;
            } catch (Exception e) {
                Log.w("GetFirebasedata", "ads config JSON is invalid, using test ads: " + e.getMessage());
            }
        }

        boolean live = hasJson; // the remote config's own (live) ad units

        ids(InterstitialAd.AdmobarrayList, o, live, "InterAdx", TEST_INTERSTITIAL);
        ids(AdvanceNativeAd.AdmobarrayList, o, live, "NativeAdx", TEST_NATIVE);
        ids(AdvanceNativeAd.AdmobSmallarrayList, o, live, "NativeAdxSmall", TEST_NATIVE);
        ids(BannerAd.AdmobarrayList, o, live, "BannerAdx", TEST_BANNER);
        ids(New_BannerAd.AdmobarrayList, o, live, "New_BannerAdx", TEST_BANNER);
        ids(RectangleBannerAd.AdmobarrayList, o, live, "RBannerAdx", TEST_BANNER);
        ids(RewardAd.AdmobarrayList, o, live, "RewardAdx", TEST_REWARDED);
        ids(InterstitialAd.FacebookarrayList, o, live, "InterFB", null);
        ids(AdvanceNativeAd.FacebookarrayList, o, live, "NativeFB", null);
        ids(BannerAd.FacebookarrayList, o, live, "BannerFB", null);
        ids(New_BannerAd.FacebookarrayList, o, live, "New_BannerFB", null);
        ids(RectangleBannerAd.FacebookarrayList, o, live, "RBannerFB", null);
        RewardAd.AdintercountAdmob = 0;

        AdsType = o.optInt("AdsType", 1); // 1 = AdMob only
        FacebookCustom = o.optInt("FacebookCustom", 0);
        InterorAppopen = o.optInt("InterorAppopen", 1);
        InterorAppopen_reff = 1;
        InterCount = o.optInt("InterCount", 1);
        InterCountRefral = o.optInt("InterCountRefral", 1);
        NativeCount = o.optInt("NativeCount", 1);
        NativeCountRefral = o.optInt("NativeCountRefral", 1);
        BannerCount = o.optInt("BannerCount", 1);
        BannerCountRefral = o.optInt("BannerCountRefral", 1);
        BackPressAd = o.optInt("BackPressAd", 0);
        BackPressAdCounter = o.optInt("BackPressAdCounter", 1);
        BackPressAdCounterRefral = o.optInt("BackPressAdCounterRefral", 1);
        LoanTypeCounter = o.optInt("LoanTypeCounter", 1);
        Extrascreen = o.optInt("Extrascreen", 0);
        ExtraLooping = false;
        Adsdemotype = o.optInt("Adsdemotype", 0);
        Isonnotification = o.optInt("Isonnotification", 0);
        SmallnativeorBignative = o.optInt("SmallnativeorBignative", 1); // 1 full, 2 compact (question screens switch in Ads)
        Timing = o.optInt("Timing", 0);
        RecbannerorNative = o.optInt("RecbannerorNative", 1);
        BannerorCollepsiblebanner = o.optInt("BannerorCollepsiblebanner", 1);
        NewBannerorCollepsiblebanner = o.optInt("NewBannerorCollepsiblebanner", 1);
        ShowLoanTypesButton = o.optInt("ShowLoanTypesButton", 0);
        ShowAffiliateAd = o.optBoolean("ShowCustomAds", false);

        QurekaAppURL = "";
        JSONArray urls = o.optJSONArray("QurekaAppURL");
        if (urls != null) {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < urls.length(); i++) {
                String u = urls.optString(i, "").trim();
                if (u.isEmpty()) continue;
                if (sb.length() > 0) sb.append(",");
                sb.append(u);
            }
            QurekaAppURL = sb.toString();
        } else {
            QurekaAppURL = o.optString("QurekaAppURL", "");
        }
        qureka_server = o.optString("qureka_server", "");
        notification_server = o.optString("notification_server", "");
        notifiction_time = o.has("notifiction_time") ? o.optInt("notifiction_time", 30) : o.optInt("notification_time", 30);
        gamePlayURL = o.optString("gamePlayURL", "");
        privacy_policy_url = o.optString("PrivacyPolicyURL", "");
        showNotnotButton = o.optBoolean("showNotnotButton", false);

        String appOpen = live ? o.optString("AppOpenAdmob", "") : TEST_APP_OPEN;
        String splashOpen = live ? o.optString("SplashAppOpenAdmob", "") : TEST_APP_OPEN;
        AppPreference.setPrefs("AdmobAppopenKey", appOpen);
        AppPreference.setPrefs("AdmobSplashAppopenKey", splashOpen);

        if (!TextUtils.isEmpty(qureka_server)) AffiliateAdHelper.fetchAndCache(activity);

        // exactly one of each is preloaded
        InterstitialAd.LoadAdmobInterstitial(activity);
        RewardAd.load(activity);
        if (!TextUtils.isEmpty(splashOpen) && !AppOpenManager.isSplashAdAvailable()) {
            AppOpenManager.fetchSplashAd(); // the one app-open ad, shown at launch
        }
    }
}
