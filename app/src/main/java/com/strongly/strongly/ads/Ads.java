package com.strongly.strongly.ads;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.appcompat.view.WindowCallbackWrapper;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdView;
import com.ads.sdk.adssdk.AdvanceNativeAd;
import com.ads.sdk.adssdk.AppOpenManager;
import com.ads.sdk.adssdk.BannerAd;
import com.ads.sdk.adssdk.GetFirebasedata;
import com.ads.sdk.adssdk.InterstitialAd;
import com.ads.sdk.adssdk.RewardAd;
import com.strongly.strongly.billing.PremiumService;
import com.strongly.strongly.ui.ActiveWorkoutActivity;
import com.strongly.strongly.ui.HomeActivity;
import com.strongly.strongly.ui.LanguageActivity;
import com.strongly.strongly.ui.OnboardingActivity;
import com.strongly.strongly.ui.QuestionnaireActivity;
import com.strongly.strongly.ui.SplashActivity;

import java.util.Random;

/**
 * Single entry point for ads (adsdk, Google test units). Nothing shows for premium users.
 *
 * <ul>
 *   <li>Banner: footer of every screen except splash, the workout player and the native-ad screens.</li>
 *   <li>Native: onboarding, language and every questionnaire step.</li>
 *   <li>Interstitial: on the 2nd tap, then after a random 4-6 taps, never within 10 s of the last one.</li>
 *   <li>App open: on every cold start (after splash) and every return to the foreground.</li>
 * </ul>
 */
public final class Ads {
    private static final long INTERSTITIAL_COOLDOWN_MS = 10_000;
    private static final int FIRST_AD_TAP = 2;
    private static final String TAG_WRAPPER = "ads_wrapper";
    private static final int FOOTER_BG = 0xFF0D0D0E;

    private static final Random RANDOM = new Random();
    private static final Handler MAIN = new Handler(Looper.getMainLooper());

    private static AdView sharedBanner;
    private static boolean bannerLoaded = false;
    private static ViewGroup bannerBox;
    private static Activity resumed;
    private static boolean homeReached = false;
    private static boolean configured = false;
    private static int taps = 0;
    private static int nextAdAtTap = FIRST_AD_TAP;
    private static long lastInterstitialAt = 0;

    private Ads() {}

    private static boolean enabled() {
        return configured && !PremiumService.get().isPremium();
    }

    private static boolean excluded(Activity a) {
        return a instanceof SplashActivity || a instanceof ActiveWorkoutActivity
                || a instanceof com.google.android.gms.ads.AdActivity; // full-screen ads get no footer ad
    }

    private static boolean wantsNative(Activity a) {
        return a instanceof OnboardingActivity || a instanceof LanguageActivity || a instanceof QuestionnaireActivity;
    }

    /** Registers lifecycle hooks. Call once from Application.onCreate. */
    public static void attach(Application app) {
        app.registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
            @Override public void onActivityCreated(@NonNull Activity a, Bundle b) {
                if (a instanceof HomeActivity) onHomeOpened(a);
            }
            @Override public void onActivityStarted(@NonNull Activity a) {
                if (excluded(a)) return;
                wrapContent(a);
                trackTaps(a);
            }
            @Override public void onActivityResumed(@NonNull Activity a) {
                resumed = a;
                if (configFailed && !loadingConfig && System.currentTimeMillis() - lastConfigAttempt > CONFIG_RETRY_MS) init(a);
                loadBanner(a);
            }
            @Override public void onActivityPaused(@NonNull Activity a) { if (resumed == a) resumed = null; }
            @Override public void onActivityStopped(@NonNull Activity a) { }
            @Override public void onActivitySaveInstanceState(@NonNull Activity a, @NonNull Bundle b) { }
            @Override public void onActivityDestroyed(@NonNull Activity a) {
                if (bannerBox != null && bannerBox.getContext() == a) { // don't hold on to a finished screen
                    if (sharedBanner != null && sharedBanner.getParent() == bannerBox) bannerBox.removeView(sharedBanner);
                    bannerBox = null;
                }
            }
        });
        // The app-open ad is only for the launch (showLaunchAppOpen); returning to the app neither shows nor preloads one.
    }

    // The ads configuration is fetched from this endpoint every time it is needed (app start, or a retry after a
    // failure). It is never written to disk or bundled with the app.
    private static final String CONFIG_URL =
            "https://api.ads-config.greewebsolutions.com/projects/f04f430f-adb3-4f90-8d5f-6179e4bb2fde/json/89527f58-ccf4-4e0b-9097-a95903f2d264";
    private static final long CONFIG_RETRY_MS = 15_000;

    private static final String TAG = "AdsCfg";
    private static boolean loadingConfig = false;
    private static boolean configFailed = false;
    private static long lastConfigAttempt = 0;

    /** Fetches the ads configuration and starts the preloads. Call from the first activity; resumes retry on failure. */
    public static void init(Activity activity) {
        if (configured || loadingConfig) return;
        loadingConfig = true;
        lastConfigAttempt = System.currentTimeMillis();
        android.util.Log.i(TAG, "fetching ads config");
        new Thread(() -> {
            final String json = fetchConfig();
            MAIN.post(() -> {
                loadingConfig = false;
                if (json == null) { // no ads this time; retried on the next resume
                    configFailed = true;
                    android.util.Log.w(TAG, "ads config fetch FAILED - no ads until a retry");
                    return;
                }
                android.util.Log.i(TAG, "ads config loaded (" + json.length() + " chars)");
                configFailed = false;
                configured = true;
                Activity host = resumed != null ? resumed : activity;
                GetFirebasedata.applyConfigJson(host, json); // preloads one interstitial, reward and app-open
                if (resumed != null) { // a screen that opened before the config arrived
                    loadBanner(resumed);
                    refreshNative(resumed);
                }
            });
        }, "ads-config").start();
    }

    /** Downloads the config and returns its "data" object as JSON text, or null when it cannot be read. */
    private static String fetchConfig() {
        java.net.HttpURLConnection c = null;
        try {
            c = (java.net.HttpURLConnection) new java.net.URL(CONFIG_URL).openConnection();
            c.setUseCaches(false); // never serve a stored copy
            c.setConnectTimeout(8000);
            c.setReadTimeout(8000);
            c.setRequestProperty("Accept", "application/json");
            int code = c.getResponseCode();
            if (code != 200) { android.util.Log.w(TAG, "ads config HTTP " + code); return null; }
            java.io.ByteArrayOutputStream out = new java.io.ByteArrayOutputStream();
            try (java.io.InputStream in = c.getInputStream()) {
                byte[] buf = new byte[4096];
                for (int n; (n = in.read(buf)) > 0; ) out.write(buf, 0, n);
            }
            org.json.JSONObject root = new org.json.JSONObject(out.toString("UTF-8"));
            org.json.JSONObject data = root.optJSONObject("data");
            if (data == null && root.has("InterAdx1")) data = root; // bare config
            return data == null || data.length() == 0 ? null : data.toString();
        } catch (Exception e) {
            android.util.Log.w(TAG, "ads config error: " + e);
            return null;
        } finally {
            if (c != null) c.disconnect();
        }
    }

    // ------------------------------------------------------------------ app open

    /** True when splash need not wait any longer for the launch app-open ad. */
    public static boolean launchAdReady() {
        if (loadingConfig) return false; // the config (and so the ad unit ids) has not arrived yet
        return !enabled() || AppOpenManager.isSplashAdAvailable() || AppOpenManager.isAdAvailable();
    }

    /** One line saying why the launch app-open ad is or is not going to show (for logcat, tag AdsCfg). */
    private static String launchAdState() {
        return "configured=" + configured + " loadingConfig=" + loadingConfig + " configFailed=" + configFailed
                + " premium=" + PremiumService.get().isPremium() + " splashAdReady=" + AppOpenManager.isSplashAdAvailable();
    }

    /** Shows the app-open ad for a cold start. Call right after leaving splash. */
    public static void showLaunchAppOpen() {
        android.util.Log.i(TAG, "launch app-open: " + launchAdState());
        if (!enabled()) return;
        MAIN.postDelayed(() -> {
            android.util.Log.i(TAG, "launch app-open show now: " + launchAdState() + " resumed=" + resumed);
            if (AppOpenManager.isSplashAdAvailable()) AppOpenManager.showSplashAppOpenAd(null);
            else AppOpenManager.showAdIfAvailable();
        }, 500);
    }

    // ------------------------------------------------------------------ footer: banner (+ native)

    /** Moves the screen's content into a column with the ad boxes underneath it. Runs once per activity. */
    private static void wrapContent(Activity a) {
        ViewGroup content = a.findViewById(android.R.id.content);
        if (content == null || content.getChildCount() == 0 || content.findViewWithTag(TAG_WRAPPER) != null) return;

        // language: native above the continue button; questions: native in the middle, above the options
        int anchorId = a instanceof LanguageActivity ? com.strongly.strongly.R.id.continue_btn
                : a instanceof QuestionnaireActivity ? com.strongly.strongly.R.id.scroll : 0;
        if (anchorId != 0) {
            if (content.findViewWithTag("ads_native") != null) return;
            View anchor = a.findViewById(anchorId);
            ViewGroup parent = (ViewGroup) anchor.getParent();
            parent.addView(adBox(a, "ads_native"), parent.indexOfChild(anchor), new LinearLayout.LayoutParams(-1, -2));
            loadNative(a);
            return;
        }

        View root = content.getChildAt(0);
        content.removeView(root);

        LinearLayout column = new LinearLayout(a);
        column.setTag(TAG_WRAPPER);
        column.setOrientation(LinearLayout.VERTICAL);
        column.addView(root, new LinearLayout.LayoutParams(-1, 0, 1f));

        // native screens (onboarding, language, questionnaire) get only the native ad, no banner
        if (wantsNative(a)) column.addView(adBox(a, "ads_native"), new LinearLayout.LayoutParams(-1, -2));
        else column.addView(adBox(a, "ads_banner"), new LinearLayout.LayoutParams(-1, -2));
        content.addView(column, new ViewGroup.LayoutParams(-1, -1));

        if (wantsNative(a)) loadNative(a);
    }

    private static FrameLayout adBox(Activity a, String tag) {
        FrameLayout box = new FrameLayout(a);
        box.setTag(tag);
        box.setBackgroundColor(FOOTER_BG);
        box.setVisibility(View.GONE);
        return box;
    }

    private static ViewGroup box(Activity a, String tag) {
        ViewGroup content = a.findViewById(android.R.id.content);
        return content == null ? null : content.findViewWithTag(tag);
    }

    private static void loadBanner(Activity a) {
        ViewGroup box = box(a, "ads_banner");
        if (box == null) return;
        if (!enabled()) { box.setVisibility(View.GONE); return; }
        // One banner for the whole app: it is loaded once and moved into each screen's footer, so changing
        // screens never reloads it (the SDK's own banner is destroyed and re-requested on every screen).
        if (sharedBanner == null) {
            if (BannerAd.AdmobarrayList.isEmpty()) return;
            AdView v = new AdView(a.getApplicationContext());
            v.setAdUnitId(BannerAd.AdmobarrayList.get(0));
            v.setAdSize(BannerAd.getAdSize(a));
            v.setAdListener(new AdListener() {
                @Override public void onAdLoaded() { bannerLoaded = true; showBannerBox(); }
            });
            sharedBanner = v;
            v.loadAd(new AdRequest.Builder().build());
        }
        if (sharedBanner.getParent() != box) {
            if (sharedBanner.getParent() instanceof ViewGroup) ((ViewGroup) sharedBanner.getParent()).removeView(sharedBanner);
            box.addView(sharedBanner, new FrameLayout.LayoutParams(-2, -2, Gravity.CENTER_HORIZONTAL));
        }
        bannerBox = box;
        showBannerBox();
    }

    private static void showBannerBox() {
        if (bannerBox != null) bannerBox.setVisibility(bannerLoaded ? View.VISIBLE : View.GONE);
    }

    private static void loadNative(Activity a) {
        ViewGroup box = box(a, "ads_native");
        if (box == null || !enabled()) return;
        // 1 = full native, 2 = compact (question screens keep the options visible)
        GetFirebasedata.SmallnativeorBignative = a instanceof QuestionnaireActivity ? 2 : 1;
        AdvanceNativeAd.ShowNativeAd(a, box);
    }

    /**
     * A native ad to place inside a scrolling tab. Pass the slot returned last time to keep it (re-attach it
     * after the content is rebuilt) instead of requesting another ad.
     */
    public static FrameLayout nativeSlot(Activity a, FrameLayout existing) {
        if (existing != null) {
            if (existing.getParent() instanceof ViewGroup) ((ViewGroup) existing.getParent()).removeView(existing);
            return existing;
        }
        FrameLayout slot = new FrameLayout(a);
        if (!enabled()) { slot.setVisibility(View.GONE); return slot; }
        GetFirebasedata.SmallnativeorBignative = 2; // compact, so it reads like a list item
        AdvanceNativeAd.ShowNativeAd(a, slot);
        return slot;
    }

    /** Loads a fresh native ad into the current screen. Call on each questionnaire step. */
    public static void refreshNative(Activity a) {
        if (wantsNative(a) && box(a, "ads_native") != null) loadNative(a);
    }

    // ------------------------------------------------------------------ interstitial

    /** Taps only count once the home screen has opened; preload so the 2nd tap there can show one. */
    private static void onHomeOpened(Activity home) {
        if (!homeReached) { homeReached = true; taps = 0; nextAdAtTap = FIRST_AD_TAP; }
        if (enabled() && !InterstitialAd.isAdmobInterstitialReady()) InterstitialAd.LoadAdmobInterstitial(home);
    }

    // ------------------------------------------------------------------ interstitial by taps

    private static void trackTaps(Activity a) {
        Window w = a.getWindow();
        Window.Callback cb = w.getCallback();
        if (cb == null || cb instanceof TapCallback) return;
        w.setCallback(new TapCallback(cb, a));
    }

    private static final class TapCallback extends WindowCallbackWrapper {
        private final Activity activity;
        private final int slop;
        private float downX, downY;
        private long downAt;

        TapCallback(Window.Callback wrapped, Activity activity) {
            super(wrapped);
            this.activity = activity;
            this.slop = ViewConfiguration.get(activity).getScaledTouchSlop();
        }

        @Override public boolean dispatchTouchEvent(MotionEvent e) {
            if (e.getActionMasked() == MotionEvent.ACTION_DOWN) {
                downX = e.getX(); downY = e.getY(); downAt = e.getEventTime();
            } else if (e.getActionMasked() == MotionEvent.ACTION_UP
                    && e.getEventTime() - downAt < 300
                    && Math.abs(e.getX() - downX) < slop && Math.abs(e.getY() - downY) < slop) {
                onTap(activity);
            }
            return super.dispatchTouchEvent(e);
        }
    }

    private static void onTap(Activity a) {
        if (!enabled() || !homeReached) return; // no interstitials before the home screen
        taps++;
        if (taps < nextAdAtTap) return;
        if (System.currentTimeMillis() - lastInterstitialAt < INTERSTITIAL_COOLDOWN_MS) return;

        if (!InterstitialAd.isAdmobInterstitialReady()) {
            InterstitialAd.ShowAdmobIntersrtitial(a); // starts loading; try again on a later tap
            return;
        }
        taps = 0;
        nextAdAtTap = 4 + RANDOM.nextInt(3); // 4..6 taps until the next one
        lastInterstitialAt = System.currentTimeMillis();
        // let the tapped control finish its own handling first
        a.getWindow().getDecorView().postDelayed(() -> {
            if (!rewardActive) InterstitialAd.ShowAdmobIntersrtitial(a); // the tap may have been "Start"
        }, 150);
    }

    // ------------------------------------------------------------------ rewarded (Start)

    private static boolean rewardActive = false;

    /**
     * Shows a rewarded ad (adsdk RewardAd) every time, then runs {@code then} once it is closed. Never blocks the
     * user: with no ad ready (still loading, no fill) or a premium user, {@code then} runs straight away.
     */
    public static void showRewarded(Activity a, Runnable then) {
        if (!enabled() || !RewardAd.isReady() || rewardActive) {
            if (enabled()) RewardAd.load(a);
            then.run();
            return;
        }
        rewardActive = true;
        RewardAd.show(a, () -> {
            rewardActive = false;
            lastInterstitialAt = System.currentTimeMillis(); // no interstitial right after a reward ad
            then.run();
        });
    }
}
