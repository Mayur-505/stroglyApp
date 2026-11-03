package com.ads.sdk.adssdk;

import static androidx.lifecycle.Lifecycle.Event.ON_START;
import static androidx.lifecycle.Lifecycle.Event.ON_STOP;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.OnLifecycleEvent;
import androidx.lifecycle.ProcessLifecycleOwner;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.appopen.AppOpenAd;

import org.jetbrains.annotations.Nullable;

import java.util.Date;

public class AppOpenManager implements LifecycleObserver, Application.ActivityLifecycleCallbacks {
    private static AppManifestClass myApplication;
    private static Activity currentActivity;
    private static AppOpenAd.AppOpenAdLoadCallback loadCallback;
    private static AppOpenAd.AppOpenAdLoadCallback splashLoadCallback;
    private static AppOpenAd app_open_ad = null;
    private static AppOpenAd splash_app_open_ad = null;

    private static boolean isShowingAd = false;
    private static boolean isAdLoading = false;
    private static boolean isSplashAdLoading = false;
    private static long loadTime = 0;
    private static long splashLoadTime = 0;

    public AppOpenManager(AppManifestClass application) {
        myApplication = application;
        myApplication.registerActivityLifecycleCallbacks(this);
        ProcessLifecycleOwner.get().getLifecycle().addObserver(this);
    }

    public static void showAdIfAvailable() {
        if (!isShowingAd && isAdAvailable()) {
            FullScreenContentCallback fullScreenContentCallback = new FullScreenContentCallback() {
                @Override
                public void onAdDismissedFullScreenContent() {
                    app_open_ad = null;
                    isShowingAd = false;
                }

                @Override
                public void onAdFailedToShowFullScreenContent(AdError adError) {
                    Log.w("AppOpenManager", "show failed: " + adError.getMessage());
                    app_open_ad = null;
                    isShowingAd = false;
                }

                @Override
                public void onAdShowedFullScreenContent() {
                    Log.i("AppOpenManager", "app-open ad shown");
                    isShowingAd = true;
                }
            };

            app_open_ad.setFullScreenContentCallback(fullScreenContentCallback);
            app_open_ad.show(currentActivity);
        }
    }

    public static void showSplashAppOpenAd(Activity activity) {
        Activity targetActivity = activity != null ? activity : currentActivity;

        if (!isShowingAd && isSplashAdAvailable()) {
            FullScreenContentCallback fullScreenContentCallback = new FullScreenContentCallback() {
                @Override
                public void onAdDismissedFullScreenContent() {
                    splash_app_open_ad = null;
                    isShowingAd = false;
                }

                @Override
                public void onAdFailedToShowFullScreenContent(AdError adError) {
                    Log.w("AppOpenManager", "show failed: " + adError.getMessage());
                    splash_app_open_ad = null;
                    isShowingAd = false;
                    if (targetActivity != null) {
                        InterstitialAd.tryShowAffiliateAd(targetActivity);
                    }
                }

                @Override
                public void onAdShowedFullScreenContent() {
                    Log.i("AppOpenManager", "app-open ad shown");
                    isShowingAd = true;
                }
            };

            splash_app_open_ad.setFullScreenContentCallback(fullScreenContentCallback);
            splash_app_open_ad.show(targetActivity);
        } else {
            if (targetActivity != null) {
                InterstitialAd.tryShowAffiliateAd(targetActivity);
            }
        }
    }

    @OnLifecycleEvent(ON_START)
    public void onStart() {
        // no preload on resume: only the launch app-open ad is loaded (see GetFirebasedata.applyTestConfig)
    }

    @OnLifecycleEvent(ON_STOP)
    public void onStop() {
    }

    public static void fetchAd() {
        if (myApplication == null || isAdLoading || isAdAvailable()) {
            return;
        }
        String adUnitId = AppPreference.getPref("AdmobAppopenKey");
        if (adUnitId == null || adUnitId.trim().isEmpty()) {
            return;
        }

        isAdLoading = true;
        loadCallback = new AppOpenAd.AppOpenAdLoadCallback() {
            @Override
            public void onAdLoaded(AppOpenAd appOpenAd) {
                super.onAdLoaded(appOpenAd);
                app_open_ad = appOpenAd;
                isAdLoading = false;
                loadTime = (new Date()).getTime();
                Log.i("AppOpenManager", "app_open_ad loaded successfully!");
            }

            @Override
            public void onAdFailedToLoad(LoadAdError loadAdError) {
                super.onAdFailedToLoad(loadAdError);
                app_open_ad = null;
                isAdLoading = false;
                Log.i("AppOpenManager", "app_open_ad failed to load: " + loadAdError.getMessage());
            }
        };

        AdRequest openAppAdRequest = getAdRequest();
        AppOpenAd.load(myApplication, adUnitId, openAppAdRequest, loadCallback);
    }

    public static void fetchSplashAd() {
        if (myApplication == null || isSplashAdLoading || isSplashAdAvailable()) {
            return;
        }
        String splashKey = AppPreference.getPref("AdmobSplashAppopenKey");
        if (splashKey == null || splashKey.trim().isEmpty()) {
            splashKey = AppPreference.getPref("AdmobAppopenKey");
        }
        if (splashKey == null || splashKey.trim().isEmpty()) {
            return;
        }

        isSplashAdLoading = true;
        splashLoadCallback = new AppOpenAd.AppOpenAdLoadCallback() {
            @Override
            public void onAdLoaded(AppOpenAd appOpenAd) {
                super.onAdLoaded(appOpenAd);
                splash_app_open_ad = appOpenAd;
                isSplashAdLoading = false;
                splashLoadTime = (new Date()).getTime();
                Log.i("AppOpenManager", "splash_app_open_ad loaded successfully!");
            }

            @Override
            public void onAdFailedToLoad(LoadAdError loadAdError) {
                super.onAdFailedToLoad(loadAdError);
                splash_app_open_ad = null;
                isSplashAdLoading = false;
                Log.i("AppOpenManager", "splash_app_open_ad failed to load: " + loadAdError.getMessage());
            }
        };

        AdRequest openAppAdRequest = getAdRequest();
        AppOpenAd.load(myApplication, splashKey, openAppAdRequest, splashLoadCallback);
    }

    private static AdRequest getAdRequest() {
        return new AdRequest.Builder().build();
    }

    private static boolean wasLoadTimeLessThanNHoursAgo(long time, long numHours) {
        if (time == 0) return false;
        long dateDifference = (new Date()).getTime() - time;
        long numMilliSecondsPerHour = 3600000;
        return (dateDifference < (numMilliSecondsPerHour * numHours));
    }

    public static boolean isAdAvailable() {
        return app_open_ad != null && wasLoadTimeLessThanNHoursAgo(loadTime, 4);
    }

    public static boolean isSplashAdAvailable() {
        return splash_app_open_ad != null && wasLoadTimeLessThanNHoursAgo(splashLoadTime, 4);
    }

    @Override
    public void onActivityCreated(Activity activity, @Nullable Bundle savedInstanceState) {

    }

    @Override
    public void onActivityStarted(Activity activity) {
        currentActivity = activity;
    }

    @Override
    public void onActivityResumed(Activity activity) {
        currentActivity = activity;
    }

    @Override
    public void onActivityPaused(Activity activity) {

    }

    @Override
    public void onActivityStopped(Activity activity) {

    }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle outState) {

    }

    @Override
    public void onActivityDestroyed(Activity activity) {
        currentActivity = null;
    }
}