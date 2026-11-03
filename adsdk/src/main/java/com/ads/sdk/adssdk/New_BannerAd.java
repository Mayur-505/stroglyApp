package com.ads.sdk.adssdk;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

import androidx.browser.customtabs.CustomTabsIntent;
import androidx.core.content.ContextCompat;
import androidx.core.view.ViewCompat;

import com.facebook.ads.Ad;
import com.facebook.ads.AdError;
import com.google.ads.mediation.admob.AdMobAdapter;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.LoadAdError;

import java.util.ArrayList;
import java.util.Random;

public class New_BannerAd {

    public static Activity activity;
    public static int AdintercountAdmob = 0;
    public static int AdintercountFacebook = 0;
    public static int Adpriority = 1;
    public static int Bannerandcollepsiblebannerpriority = 1;
    public static ArrayList<String> AdmobarrayList = new ArrayList<>();
    public static ArrayList<String> FacebookarrayList = new ArrayList<>();
    public static AdView Admobbannerview;
    public static com.facebook.ads.AdView Facebookbannerview;
    public static int Counter = 1;
    public static int CounterRefral = 1;

    public New_BannerAd(Activity activity) {
        New_BannerAd.activity = activity;
    }

    public static void ShowAdmobBanner(Activity activity, ViewGroup viewGroup) {
        if (activity == null || viewGroup == null) return;
        if (!CheckInternet(activity)) {
            ShimmerAdHelper.onAdFailed(viewGroup);
            return;
        }

        ShimmerAdHelper.showBannerShimmer(activity, viewGroup);

        if (Admobbannerview != null) {
            Admobbannerview.destroy();
        }
        Admobbannerview = new AdView(activity);
        Admobbannerview.setAdUnitId(AdmobarrayList.get(AdintercountAdmob));
        PreferencesHelper preferencesHelper = new PreferencesHelper(activity);
        if (preferencesHelper.IsOrganic()) {
            AdSize adSize = getAdSize(activity);
            Admobbannerview.setAdSize(adSize);
            AdRequest adRequest = new AdRequest.Builder().setRequestAgent(AdRequest.DEVICE_ID_EMULATOR).build();
            Admobbannerview.setAdListener(new AdListener() {

                @Override
                public void onAdLoaded() {
                    if (!CheckInternet(activity))
                        return;
                    if (Admobbannerview == null) {
                        ShimmerAdHelper.onAdFailed(viewGroup);
                        return;
                    }
                    ShimmerAdHelper.onAdLoaded(viewGroup, Admobbannerview);
                }

                @Override
                public void onAdFailedToLoad(LoadAdError adError) {
                    Admobbannerview = null;
                    if (GetFirebasedata.ShowLoanTypesButton == 1) {
                        AffiliateAdBanner(activity, viewGroup);
                    } else {
                        ShowFacebookBanner(activity, viewGroup);
                    }
                }

                @Override
                public void onAdOpened() {
                }

                @Override
                public void onAdClicked() {
                }

                @Override
                public void onAdClosed() {
                }

                @Override
                public void onAdImpression() {
                    Admobbannerview = null;
                }

            });
            Admobbannerview.loadAd(adRequest);
            if (AdintercountAdmob == 4) {
                AdintercountAdmob = 0;
            } else {
                AdintercountAdmob++;
            }
        } else {
            if (GetFirebasedata.NewBannerorCollepsiblebanner == 1) {
                AdSize adSize = getAdSize(activity);
                Admobbannerview.setAdSize(adSize);
                AdRequest adRequest = new AdRequest.Builder().setRequestAgent(AdRequest.DEVICE_ID_EMULATOR).build();
                Admobbannerview.setAdListener(new AdListener() {

                    @Override
                    public void onAdLoaded() {
                        if (!CheckInternet(activity))
                            return;
                        if (Admobbannerview == null) {
                            ShimmerAdHelper.onAdFailed(viewGroup);
                            return;
                        }
                        ShimmerAdHelper.onAdLoaded(viewGroup, Admobbannerview);
                    }

                    @Override
                    public void onAdFailedToLoad(LoadAdError adError) {
                        Admobbannerview = null;
                        if (GetFirebasedata.ShowLoanTypesButton == 1) {
                            AffiliateAdBanner(activity, viewGroup);
                        } else {
                            ShowFacebookBanner(activity, viewGroup);
                        }
                    }

                    @Override
                    public void onAdOpened() {
                    }

                    @Override
                    public void onAdClicked() {
                    }

                    @Override
                    public void onAdClosed() {
                    }

                    @Override
                    public void onAdImpression() {
                        Admobbannerview = null;
                    }

                });
                Admobbannerview.loadAd(adRequest);
                if (AdintercountAdmob == 4) {
                    AdintercountAdmob = 0;
                } else {
                    AdintercountAdmob++;
                }
            } else if (GetFirebasedata.NewBannerorCollepsiblebanner == 2) {
                AdSize adSize = getAdSizeCollapsible(activity, viewGroup);
                Admobbannerview.setAdSize(adSize);
                Bundle extras = new Bundle();
                extras.putString("collapsible", "bottom");
                AdRequest adRequest = new AdRequest.Builder().setRequestAgent(AdRequest.DEVICE_ID_EMULATOR).addNetworkExtrasBundle(AdMobAdapter.class, extras).build();
                Admobbannerview.setAdListener(new AdListener() {

                    @Override
                    public void onAdLoaded() {
                        if (!CheckInternet(activity))
                            return;
                        if (Admobbannerview == null) {
                            ShimmerAdHelper.onAdFailed(viewGroup);
                            return;
                        }
                        ShimmerAdHelper.onAdLoaded(viewGroup, Admobbannerview);
                    }

                    @Override
                    public void onAdFailedToLoad(LoadAdError adError) {
                        Admobbannerview = null;
                        if (GetFirebasedata.ShowLoanTypesButton == 1) {
                            AffiliateAdBanner(activity, viewGroup);
                        } else {
                            ShowFacebookBanner(activity, viewGroup);
                        }
                    }

                    @Override
                    public void onAdOpened() {
                    }

                    @Override
                    public void onAdClicked() {
                    }

                    @Override
                    public void onAdClosed() {
                    }

                    @Override
                    public void onAdImpression() {
                        Admobbannerview = null;
                    }

                });
                Admobbannerview.loadAd(adRequest);
                if (AdintercountAdmob == 4) {
                    AdintercountAdmob = 0;
                } else {
                    AdintercountAdmob++;
                }
            } else if (GetFirebasedata.NewBannerorCollepsiblebanner == 3) {
                if (Bannerandcollepsiblebannerpriority % 2 == 0) {
                    AdSize adSize = getAdSize(activity);
                    Admobbannerview.setAdSize(adSize);
                    AdRequest adRequest = new AdRequest.Builder().setRequestAgent(AdRequest.DEVICE_ID_EMULATOR).build();
                    Admobbannerview.setAdListener(new AdListener() {

                        @Override
                        public void onAdLoaded() {
                            if (!CheckInternet(activity))
                                return;
                            if (Admobbannerview == null) {
                                ShimmerAdHelper.onAdFailed(viewGroup);
                                return;
                            }
                            ShimmerAdHelper.onAdLoaded(viewGroup, Admobbannerview);
                        }

                        @Override
                        public void onAdFailedToLoad(LoadAdError adError) {
                            Admobbannerview = null;
                            if (GetFirebasedata.ShowLoanTypesButton == 1) {
                                AffiliateAdBanner(activity, viewGroup);
                            } else {
                                ShowFacebookBanner(activity, viewGroup);
                            }
                        }

                        @Override
                        public void onAdOpened() {
                        }

                        @Override
                        public void onAdClicked() {
                        }

                        @Override
                        public void onAdClosed() {
                        }

                        @Override
                        public void onAdImpression() {
                            Admobbannerview = null;
                        }

                    });
                    Admobbannerview.loadAd(adRequest);
                    if (AdintercountAdmob == 4) {
                        AdintercountAdmob = 0;
                    } else {
                        AdintercountAdmob++;
                    }
                } else {
                    AdSize adSize = getAdSizeCollapsible(activity, viewGroup);
                    Admobbannerview.setAdSize(adSize);
                    Bundle extras = new Bundle();
                    extras.putString("collapsible", "bottom");
                    AdRequest adRequest = new AdRequest.Builder().setRequestAgent(AdRequest.DEVICE_ID_EMULATOR).addNetworkExtrasBundle(AdMobAdapter.class, extras).build();
                    Admobbannerview.setAdListener(new AdListener() {

                        @Override
                        public void onAdLoaded() {
                            if (!CheckInternet(activity))
                                return;
                            if (Admobbannerview == null) {
                                ShimmerAdHelper.onAdFailed(viewGroup);
                                return;
                            }
                            ShimmerAdHelper.onAdLoaded(viewGroup, Admobbannerview);
                        }

                        @Override
                        public void onAdFailedToLoad(LoadAdError adError) {
                            Admobbannerview = null;
                            if (GetFirebasedata.ShowLoanTypesButton == 1) {
                                AffiliateAdBanner(activity, viewGroup);
                            } else {
                                ShowFacebookBanner(activity, viewGroup);
                            }
                        }

                        @Override
                        public void onAdOpened() {
                        }

                        @Override
                        public void onAdClicked() {
                        }

                        @Override
                        public void onAdClosed() {
                        }

                        @Override
                        public void onAdImpression() {
                            Admobbannerview = null;
                        }

                    });
                    Admobbannerview.loadAd(adRequest);
                    if (AdintercountAdmob == 4) {
                        AdintercountAdmob = 0;
                    } else {
                        AdintercountAdmob++;
                    }
                }
            }
        }
    }

    public static AdSize getAdSize(Context context) {
        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Display display = wm.getDefaultDisplay();
        DisplayMetrics outMetrics = new DisplayMetrics();
        display.getMetrics(outMetrics);

        float widthPixels = outMetrics.widthPixels;
        float density = outMetrics.density;

        int adWidth = (int) (widthPixels / density);

        return AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(context, adWidth);
    }

    private static AdSize getAdSizeCollapsible(Activity activity, ViewGroup viewGroup) {
        Display display = activity.getWindowManager().getDefaultDisplay();
        DisplayMetrics outMetrics = new DisplayMetrics();
        display.getMetrics(outMetrics);

        float density = outMetrics.density;

        float adWidthPixels = viewGroup.getWidth();

        if (adWidthPixels == 0) {
            adWidthPixels = outMetrics.widthPixels;
        }

        int adWidth = (int) (adWidthPixels / density);
        return AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(activity, adWidth);
    }

    public static void ShowFacebookBanner(Activity activity, ViewGroup viewGroup) {
        if (activity == null || viewGroup == null) return;
        if (!CheckInternet(activity)) {
            ShimmerAdHelper.onAdFailed(viewGroup);
            return;
        }

        ShimmerAdHelper.showBannerShimmer(activity, viewGroup);
        Facebookbannerview = new com.facebook.ads.AdView(activity, FacebookarrayList.get(AdintercountFacebook), com.facebook.ads.AdSize.BANNER_HEIGHT_50);
        com.facebook.ads.AdListener adListener = new com.facebook.ads.AdListener() {
            @Override
            public void onError(Ad ad, AdError adError) {
                Facebookbannerview = null;
                if (GetFirebasedata.ShowLoanTypesButton == 1) {
                    AffiliateAdBanner(activity, viewGroup);
                } else {
                    ShimmerAdHelper.onAdFailed(viewGroup);
                }
            }

            @Override
            public void onAdLoaded(Ad ad) {
                if (Facebookbannerview != null && viewGroup != null) {
                    ShimmerAdHelper.onAdLoaded(viewGroup, Facebookbannerview);
                }
            }

            @Override
            public void onAdClicked(Ad ad) {

            }

            @Override
            public void onLoggingImpression(Ad ad) {
                Facebookbannerview = null;
            }
        };
        Facebookbannerview.loadAd(Facebookbannerview.buildLoadAdConfig().withAdListener(adListener).build());
        if (AdintercountFacebook == 4) {
            AdintercountFacebook = 0;
        } else {
            AdintercountFacebook++;
        }
    }

    public static void ShowBannerAd(Activity activity, ViewGroup viewGroup) {
        if (activity == null || viewGroup == null) return;
        if (!CheckInternet(activity)) {
            ShimmerAdHelper.onAdFailed(viewGroup);
            return;
        }

        PreferencesHelper preferencesHelper = new PreferencesHelper(activity);
        if (preferencesHelper.IsOrganic()) {
            if (Counter % GetFirebasedata.BannerCount == 0) {
                ShimmerAdHelper.showBannerShimmer(activity, viewGroup);

                if (GetFirebasedata.AdsType == 1) {
                    ShowAdmobBanner(activity, viewGroup);
                } else if (GetFirebasedata.AdsType == 2) {
                    ShowFacebookBanner(activity, viewGroup);
                } else if (GetFirebasedata.AdsType == 3) {
                    if (Adpriority % 2 == 0) {
                        ShowAdmobBanner(activity, viewGroup);
                    } else {
                        ShowFacebookBanner(activity, viewGroup);
                    }
                    Adpriority++;
                } else if (GetFirebasedata.AdsType == 4) {
                    if (Adpriority % 2 == 0) {
                        ShowFacebookBanner(activity, viewGroup);
                    } else {
                        ShowAdmobBanner(activity, viewGroup);
                    }
                    Adpriority++;
                } else if (GetFirebasedata.AdsType == 5) {
                    AffiliateAdBanner(activity, viewGroup);
                }else{
                    ShimmerAdHelper.onAdFailed(viewGroup);
                }
            } else {
                ShimmerAdHelper.onAdFailed(viewGroup);
            }
            Counter++;
        } else {
            if (CounterRefral % GetFirebasedata.BannerCountRefral == 0) {
                ShimmerAdHelper.showBannerShimmer(activity, viewGroup);

                if (GetFirebasedata.AdsType == 1) {
                    ShowAdmobBanner(activity, viewGroup);
                } else if (GetFirebasedata.AdsType == 2) {
                    ShowFacebookBanner(activity, viewGroup);
                } else if (GetFirebasedata.AdsType == 3) {
                    if (Adpriority % 2 == 0) {
                        ShowAdmobBanner(activity, viewGroup);
                    } else {
                        ShowFacebookBanner(activity, viewGroup);
                    }
                    Adpriority++;
                } else if (GetFirebasedata.AdsType == 4) {
                    if (Adpriority % 2 == 0) {
                        ShowFacebookBanner(activity, viewGroup);
                    } else {
                        ShowAdmobBanner(activity, viewGroup);
                    }
                    Adpriority++;
                } else if (GetFirebasedata.AdsType == 5) {
                    AffiliateAdBanner(activity, viewGroup);
                }else{
                    ShimmerAdHelper.onAdFailed(viewGroup);
                }
            } else {
                ShimmerAdHelper.onAdFailed(viewGroup);
            }
            CounterRefral++;
        }
    }

    public static boolean CheckInternet(Context activity) {
        ConnectivityManager cm = (ConnectivityManager) activity.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo networkInfo = cm.getActiveNetworkInfo();
        if (networkInfo != null && networkInfo.isConnectedOrConnecting()) {
            return true;
        } else {
            Toast.makeText(activity, "Please check your internet connection !!", Toast.LENGTH_SHORT).show();
        }
        return false;
    }

    public static void AffiliateAdBanner(final Context activity, ViewGroup viewGroup) {
        if (activity == null || viewGroup == null) return;
        LayoutInflater inflater = LayoutInflater.from(activity);
        LinearLayout linearLayout = (LinearLayout) inflater.inflate(R.layout.affiliate_banner_dialog, viewGroup, false);
        ShimmerAdHelper.onAdLoaded(viewGroup, linearLayout);

        if (AffiliateAdHelper.bindBanner(activity, linearLayout)) {
            return;
        }

        ImageView iv_logo = linearLayout.findViewById(R.id.iv_logo);
        LinearLayout ll_atmeclick = linearLayout.findViewById(R.id.ll_atmeclick);
        Button btn_playnow = linearLayout.findViewById(R.id.btn_playnow);
        if (btn_playnow != null) {
            btn_playnow.setBackgroundResource(R.drawable.bg_loading_subtitles_accent_yllw);
            ViewCompat.setBackgroundTintList(btn_playnow, null);
        }
        iv_logo.setImageResource(new int[]{R.drawable.qlogo, R.drawable.qlogo}[new Random().nextInt(2)]);

        View.OnClickListener openQureka = v -> AffiliateAdHelper.openPlaystore(activity, GetFirebasedata.getNextQurekaUrl(activity));
        if (btn_playnow != null) btn_playnow.setOnClickListener(openQureka);
        ll_atmeclick.setOnClickListener(openQureka);
    }
}
