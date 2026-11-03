package com.ads.sdk.adssdk;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.browser.customtabs.CustomTabsIntent;
import androidx.core.content.ContextCompat;

import com.facebook.ads.Ad;
import com.facebook.ads.AdError;
import com.facebook.ads.InterstitialAdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback;

import java.util.ArrayList;

public class InterstitialAd {

    static Activity activity;
    private static com.google.android.gms.ads.interstitial.InterstitialAd AdmobInterstitial;

    public static boolean isAdmobInterstitialReady() {
        return AdmobInterstitial != null;
    }
    public static com.facebook.ads.InterstitialAd FacebookinterstitialAd;
    public static ProgressDialog dialog;
    public static ArrayList<String> AdmobarrayList = new ArrayList<>();
    public static ArrayList<String> FacebookarrayList = new ArrayList<>();
    public static int AdintercountAdmob = 0;
    public static int AdintercountFacebook = 0;
    public static int Adpriority = 1;
    public static int Counter = 1;
    public static int CounterRefral = 1;

    // true  = user (or app launch) is waiting for an ad → show AffiliateAd if Admob fails
    // false = background preload after impression → do NOT show AffiliateAd on failure
    private static boolean isUserTriggeredLoad = false;

    // One-shot guard — prevents AffiliateAd from showing twice for the same request
    // (blocks double-fire if both onAdFailedToLoad + onAdFailedToShowFullScreenContent trigger)
    private static boolean AffiliateAdShownForThisRequest = false;

    // Prevents overlapping AdMob load requests
    private static boolean isAdLoading = false;

    public InterstitialAd(Activity activity) {
        InterstitialAd.activity = activity;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Called from GetFirebasedata.displayPrice() on app launch.
    // Treated as user-triggered because the next ShowInterstitial() call
    // expects an ad to be ready. If it fails, AffiliateAd must show.
    // ─────────────────────────────────────────────────────────────────────────
    public static void LoadAdmobInterstitial(Activity activity) {
        // Mark as user-triggered so AffiliateAd fires if this load fails
        isUserTriggeredLoad = true;
        AffiliateAdShownForThisRequest = false;
        loadAdmobInternal(activity);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Called from onAdImpression — silent background preload, NO AffiliateAd fallback.
    // ─────────────────────────────────────────────────────────────────────────
    private static void preloadAdmobInterstitial(Activity activity) {
        isUserTriggeredLoad = false;
        AffiliateAdShownForThisRequest = false;
        loadAdmobInternal(activity);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Core loader — shared by both paths above. Reads flags at callback time.
    // ─────────────────────────────────────────────────────────────────────────
    private static void loadAdmobInternal(Activity activity) {
        if (AdmobInterstitial != null || isAdLoading) return;
        if (!CheckInternet(activity)) return;

        // Guard: AdmobarrayList is populated asynchronously from Firebase
        // (GetFirebasedata). If this is called before that fetch finishes —
        // or the list ends up empty for any other reason — bail out instead
        // of crashing with "Index 0 out of bounds for length 0".
        if (AdmobarrayList == null || AdmobarrayList.isEmpty()) {
            Log.w("TAG", "loadAdmobInternal: AdmobarrayList is empty, skipping load.");
            return;
        }
        // Keep the rotating index in range even if the list shrank.
        if (AdintercountAdmob >= AdmobarrayList.size()) {
            AdintercountAdmob = 0;
        }

        isAdLoading = true;
        AdRequest adRequest = new AdRequest.Builder().build();
        com.google.android.gms.ads.interstitial.InterstitialAd.load(
                activity,
                AdmobarrayList.get(AdintercountAdmob),
                adRequest,
                new InterstitialAdLoadCallback() {
                    @Override
                    public void onAdLoaded(@NonNull com.google.android.gms.ads.interstitial.InterstitialAd interstitialAd) {
                        isAdLoading = false;
                        AdmobInterstitial = interstitialAd;
                        AdmobInterstitial.setFullScreenContentCallback(new FullScreenContentCallback() {

                            @Override
                            public void onAdDismissedFullScreenContent() {
                                Log.d("TAG", "onAdDismissedFullScreenContent: " + interstitialAd);
                            }

                            @Override
                            public void onAdFailedToShowFullScreenContent(com.google.android.gms.ads.AdError adError) {
                                AdmobInterstitial = null;
                                Log.w("TAG", "onAdFailedToShowFullScreenContent: " + adError);
                            }

                            @Override
                            public void onAdShowedFullScreenContent() {
                                AdmobInterstitial = null;
                                isUserTriggeredLoad = false;
                                AffiliateAdShownForThisRequest = false;
                            }

                            @Override
                            public void onAdImpression() {
                                AdmobInterstitial = null;
                                // Background preload — failure must NOT open AffiliateAd
                                preloadAdmobInterstitial(activity);
                            }
                        });
                    }

                    @Override
                    public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
                        isAdLoading = false;
                        AdmobInterstitial = null;
                        Log.d("TAG", "onAdFailedToLoad: " + loadAdError.getMessage());
                    }
                });

        if (AdintercountAdmob == 4) {
            AdintercountAdmob = 0;
        } else {
            AdintercountAdmob++;
        }
    }

    public static void ShowAdmobIntersrtitial(Activity activity) {
        if (AdmobInterstitial == null) {
            // Ad not cached → user is waiting, load now and fallback to AffiliateAd if it fails
            isUserTriggeredLoad = true;
            AffiliateAdShownForThisRequest = false;
            loadAdmobInternal(activity);

            if (isUserTriggeredLoad && !AffiliateAdShownForThisRequest) {
                isUserTriggeredLoad = false;
                AffiliateAdShownForThisRequest = true;
                tryShowAffiliateAd(activity);
            }

            return;
        }
        // Ad is cached and ready → show directly, AffiliateAd not involved
        isUserTriggeredLoad = false;
        AffiliateAdShownForThisRequest = false;
        AdmobInterstitial.show(activity);
    }

    public static void ShowAdmobIntersrtitial2(Activity activity, Runnable onAdFinished) {

        if (AdmobInterstitial == null) {

            // Ad available nahi hai
            // Directly next action perform karo
            isUserTriggeredLoad = true;
            AffiliateAdShownForThisRequest = false;

            loadAdmobInternal(activity);

            // IMPORTANT:
            // loadAdmobInternal asynchronous hai, isliye yahan
            // AffiliateAd/next action immediately call nahi karna.
            //
            // Agar aap AffiliateAd fallback use karna chahte hain,
            // uska handling onAdFailedToLoad mein hoga.

            if (onAdFinished != null) {
                // Ad ready nahi hai, is request mein directly action
                // perform karna safest hai.
                onAdFinished.run();
            }

            return;
        }

        // Ad ready hai
        isUserTriggeredLoad = false;
        AffiliateAdShownForThisRequest = false;

        AdmobInterstitial.setFullScreenContentCallback(
                new FullScreenContentCallback() {

                    @Override
                    public void onAdShowedFullScreenContent() {
                        AdmobInterstitial = null;
                        isUserTriggeredLoad = false;
                        AffiliateAdShownForThisRequest = false;
                    }

                    @Override
                    public void onAdDismissedFullScreenContent() {
                        Log.d("TAG", "Interstitial dismissed");

                        AdmobInterstitial = null;

                        // Ad close hone ke baad next action
                        if (onAdFinished != null) {
                            onAdFinished.run();
                        }

                        // Next ad preload
                        preloadAdmobInterstitial(activity);
                    }

                    @Override
                    public void onAdFailedToShowFullScreenContent(
                            com.google.android.gms.ads.AdError adError) {

                        Log.d(
                                "TAG",
                                "onAdFailedToShowFullScreenContent: "
                                        + adError.getMessage()
                        );

                        AdmobInterstitial = null;

                        // Ad fail hua → next action
                        if (onAdFinished != null) {
                            onAdFinished.run();
                        }

                        preloadAdmobInterstitial(activity);
                    }
                }
        );

        AdmobInterstitial.show(activity);
    }

    public static void ShowFacebookinterstitial(Activity activity) {
        // Guard: FacebookarrayList is populated asynchronously from Firebase
        // (GetFirebasedata). If this is called before that fetch finishes —
        // or the list ends up empty for any other reason — bail out instead
        // of crashing with "Index 0 out of bounds for length 0".
        if (FacebookarrayList == null || FacebookarrayList.isEmpty()) {
            Log.w("TAG", "ShowFacebookinterstitial: FacebookarrayList is empty, skipping.");
            return;
        }
        // Keep the rotating index in range even if the list shrank.
        if (AdintercountFacebook >= FacebookarrayList.size()) {
            AdintercountFacebook = 0;
        }

        dialog = new ProgressDialog(activity, R.style.FbAdDialogStyle);
        dialog.setMessage("Loading Ads..");
        dialog.show();
        dialog.setCanceledOnTouchOutside(false);
        dialog.setCancelable(false);
        new android.os.Handler().postDelayed(new Runnable() {
            public void run() {
                dialog.dismiss();
            }
        }, 6000);
        FacebookinterstitialAd = new com.facebook.ads.InterstitialAd(activity, FacebookarrayList.get(AdintercountFacebook));
        InterstitialAdListener interstitialAdListener = new InterstitialAdListener() {
            @Override
            public void onInterstitialDisplayed(Ad ad) {
            }

            @Override
            public void onInterstitialDismissed(Ad ad) {
            }

            @Override
            public void onError(Ad ad, AdError adError) {
            }

            @Override
            public void onAdLoaded(Ad ad) {
                if (!CheckInternet(activity)) return;
                if (FacebookinterstitialAd == null || !FacebookinterstitialAd.isAdLoaded()) {
                } else {
                    dialog.dismiss();
                    if (FacebookinterstitialAd == null) {
                        return;
                    }
                    FacebookinterstitialAd.show();
                }
            }

            @Override
            public void onAdClicked(Ad ad) {
            }

            @Override
            public void onLoggingImpression(Ad ad) {
                FacebookinterstitialAd = null;
            }
        };
        FacebookinterstitialAd.loadAd(FacebookinterstitialAd.buildLoadAdConfig().withAdListener(interstitialAdListener).build());
        if (AdintercountFacebook == 4) {
            AdintercountFacebook = 0;
        } else {
            AdintercountFacebook++;
        }
    }

    public static void ShowInterstitial(Activity activity) {
        PreferencesHelper preferencesHelper = new PreferencesHelper(activity);
        if (preferencesHelper.IsOrganic()) {
            if (GetFirebasedata.InterorAppopen_reff == 1) {
                if (Counter % GetFirebasedata.InterCount == 0) {
                    if (GetFirebasedata.AdsType == 1) {
                        ShowAdmobIntersrtitial(activity);
                    } else if (GetFirebasedata.AdsType == 2) {
                        ShowFacebookinterstitial(activity);
                    } else if (GetFirebasedata.AdsType == 3) {
                        if (Adpriority % 2 == 0) {
                            ShowAdmobIntersrtitial(activity);
                        } else {
                            ShowFacebookinterstitial(activity);
                        }
                        Adpriority++;
                    } else if (GetFirebasedata.AdsType == 4) {
                        if (Adpriority % 2 == 0) {
                            ShowFacebookinterstitial(activity);
                        } else {
                            ShowAdmobIntersrtitial(activity);
                        }
                        Adpriority++;
                    } else if (GetFirebasedata.AdsType == 5) {
                        tryShowAffiliateAd(activity);
                    }
                }
                Counter++;
            } else if (GetFirebasedata.InterorAppopen_reff == 2) {
                AppOpenManager.showAdIfAvailable();
            } else if (GetFirebasedata.InterorAppopen_reff == 3) {
                if (Adpriority % 2 == 0) {
                    if (Counter % GetFirebasedata.InterCount == 0) {
                        if (GetFirebasedata.AdsType == 1) {
                            ShowAdmobIntersrtitial(activity);
                        } else if (GetFirebasedata.AdsType == 2) {
                            ShowFacebookinterstitial(activity);
                        } else if (GetFirebasedata.AdsType == 3) {
                            if (Adpriority % 2 == 0) {
                                ShowAdmobIntersrtitial(activity);
                            } else {
                                ShowFacebookinterstitial(activity);
                            }
                            Adpriority++;
                        } else if (GetFirebasedata.AdsType == 4) {
                            if (Adpriority % 2 == 0) {
                                ShowFacebookinterstitial(activity);
                            } else {
                                ShowAdmobIntersrtitial(activity);
                            }
                            Adpriority++;
                        } else if (GetFirebasedata.AdsType == 5) {
                            tryShowAffiliateAd(activity);
                        }
                    }
                    Counter++;
                } else {
                    AppOpenManager.showAdIfAvailable();
                }
                Adpriority++;
            }
        } else {
            if (GetFirebasedata.InterorAppopen == 1) {
                if (CounterRefral % GetFirebasedata.InterCountRefral == 0) {
                    if (GetFirebasedata.AdsType == 1) {
                        ShowAdmobIntersrtitial(activity);
                    } else if (GetFirebasedata.AdsType == 2) {
                        ShowFacebookinterstitial(activity);
                    } else if (GetFirebasedata.AdsType == 3) {
                        if (Adpriority % 2 == 0) {
                            ShowAdmobIntersrtitial(activity);
                        } else {
                            ShowFacebookinterstitial(activity);
                        }
                        Adpriority++;
                    } else if (GetFirebasedata.AdsType == 4) {
                        if (Adpriority % 2 == 0) {
                            ShowFacebookinterstitial(activity);
                        } else {
                            ShowAdmobIntersrtitial(activity);
                        }
                        Adpriority++;
                    } else if (GetFirebasedata.AdsType == 5) {
                        tryShowAffiliateAd(activity);
                    }
                }
                CounterRefral++;
            } else if (GetFirebasedata.InterorAppopen == 2) {
                AppOpenManager.showAdIfAvailable();
            } else if (GetFirebasedata.InterorAppopen == 3) {
                if (Adpriority % 2 == 0) {
                    if (CounterRefral % GetFirebasedata.InterCountRefral == 0) {
                        if (GetFirebasedata.AdsType == 1) {
                            ShowAdmobIntersrtitial(activity);
                        } else if (GetFirebasedata.AdsType == 2) {
                            ShowFacebookinterstitial(activity);
                        } else if (GetFirebasedata.AdsType == 3) {
                            if (Adpriority % 2 == 0) {
                                ShowAdmobIntersrtitial(activity);
                            } else {
                                ShowFacebookinterstitial(activity);
                            }
                            Adpriority++;
                        } else if (GetFirebasedata.AdsType == 4) {
                            if (Adpriority % 2 == 0) {
                                ShowFacebookinterstitial(activity);
                            } else {
                                ShowAdmobIntersrtitial(activity);
                            }
                            Adpriority++;
                        } else if (GetFirebasedata.AdsType == 5) {
                            tryShowAffiliateAd(activity);
                        }
                    }
                    CounterRefral++;
                } else {
                    AppOpenManager.showAdIfAvailable();
                }
                Adpriority++;
            }
        }
    }


    public static boolean CheckInternet(Activity activity) {
        ConnectivityManager cm = (ConnectivityManager) activity.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo networkInfo = cm.getActiveNetworkInfo();
        if (networkInfo != null && networkInfo.isConnectedOrConnecting()) {
            return true;
        } else {
            Toast.makeText(activity, "Please check your internet connection !!", Toast.LENGTH_SHORT).show();
        }
        return false;
    }

    public static void tryShowAffiliateAd(Activity activity) {
        if (GetFirebasedata.ShowAffiliateAd) {
            ShowAffiliateInterstitial(activity);
        }
    }

    @SuppressLint("WrongConstant")
    public static void ShowAffiliateInterstitial(Activity activity) {
        String url = GetFirebasedata.getNextQurekaUrl(activity);

        if (TextUtils.isEmpty(url)) {
            Log.w("TAG", "ShowAffiliateInterstitial: QurekaAppURL is empty, skipping.");
            return;
        }

        try {
            CustomTabsIntent.Builder builder = new CustomTabsIntent.Builder();
            builder.setToolbarColor(ContextCompat.getColor(activity, R.color.install_color));
            CustomTabsIntent customTabsIntent = builder.build();
            PackageManager pm = activity.getPackageManager();
            try {
                pm.getPackageInfo("com.android.chrome", PackageManager.GET_ACTIVITIES);
                customTabsIntent.intent.setPackage("com.android.chrome");
            } catch (PackageManager.NameNotFoundException e) {
                customTabsIntent.intent.setPackage(null);
            }

            customTabsIntent.launchUrl(activity, Uri.parse(url));
        } catch (Exception e) {
            e.printStackTrace();

            try {
                Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
                if (browserIntent.resolveActivity(activity.getPackageManager()) != null) {
                    activity.startActivity(browserIntent);
                } else {
                    Toast.makeText(activity, "No browser found to open the link", Toast.LENGTH_SHORT).show();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
}