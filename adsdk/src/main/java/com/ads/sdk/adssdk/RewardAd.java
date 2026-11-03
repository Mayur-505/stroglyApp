package com.ads.sdk.adssdk;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;

import java.util.ArrayList;

/**
 * Rewarded ads (AdMob). Exactly one ad is kept preloaded: {@link #load} does nothing while one is ready or
 * loading, and the next one is requested after the current one has been shown. Unit ids come from the
 * "RewardAdx1..5" keys of the ads config JSON and are rotated on failure.
 */
public class RewardAd {
    private static final String TAG = "RewardAd";

    public static ArrayList<String> AdmobarrayList = new ArrayList<>();
    public static int AdintercountAdmob = 0;

    private static RewardedAd rewardedAd;
    private static boolean isAdLoading = false;
    private static boolean isShowing = false;

    private RewardAd() {}

    public static boolean isReady() {
        return rewardedAd != null;
    }

    public static boolean isShowing() {
        return isShowing;
    }

    /** Preloads the single reward ad. Safe to call any time. */
    public static void load(Context context) {
        if (context == null || rewardedAd != null || isAdLoading) return;
        if (AdmobarrayList.isEmpty()) {
            Log.w(TAG, "load: no reward ad unit configured");
            return;
        }
        if (AdintercountAdmob >= AdmobarrayList.size()) AdintercountAdmob = 0;

        isAdLoading = true;
        RewardedAd.load(context.getApplicationContext(), AdmobarrayList.get(AdintercountAdmob), new AdRequest.Builder().build(),
                new RewardedAdLoadCallback() {
                    @Override
                    public void onAdLoaded(@NonNull RewardedAd ad) {
                        isAdLoading = false;
                        rewardedAd = ad;
                    }

                    @Override
                    public void onAdFailedToLoad(@NonNull LoadAdError error) {
                        isAdLoading = false;
                        rewardedAd = null;
                        Log.w(TAG, "load failed: " + error.getMessage());
                        // next unit id for the following attempt
                        AdintercountAdmob = (AdintercountAdmob + 1) % Math.max(1, AdmobarrayList.size());
                    }
                });
    }

    /**
     * Shows the reward ad and runs {@code onClosed} once it is dismissed (or could not be shown).
     * When no ad is ready the callback runs immediately so the user is never blocked; a new ad loads in the background.
     */
    public static void show(Activity activity, Runnable onClosed) {
        RewardedAd ad = rewardedAd;
        if (activity == null || ad == null || isShowing) {
            load(activity);
            if (onClosed != null) onClosed.run();
            return;
        }
        rewardedAd = null;
        isShowing = true;
        ad.setFullScreenContentCallback(new FullScreenContentCallback() {
            @Override
            public void onAdDismissedFullScreenContent() {
                finish();
            }

            @Override
            public void onAdFailedToShowFullScreenContent(@NonNull AdError error) {
                Log.w(TAG, "show failed: " + error.getMessage());
                finish();
            }

            private void finish() {
                isShowing = false;
                load(activity); // the next single preload
                if (onClosed != null) onClosed.run();
            }
        });
        ad.show(activity, reward -> { });
    }
}
