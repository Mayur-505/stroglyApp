package com.ads.sdk.adssdk;

import android.app.Activity;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.view.ViewGroup;
import android.widget.Toast;

import com.facebook.ads.Ad;
import com.facebook.ads.AdError;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.LoadAdError;

import java.util.ArrayList;

public class RectangleBannerAd {

    public static Activity activity;
    public static int AdintercountAdmob = 0;
    public static int AdintercountFacebook = 0;
    public static int Adpriority = 1;
    public static ArrayList<String> AdmobarrayList = new ArrayList<>();
    public static ArrayList<String> FacebookarrayList = new ArrayList<>();
    public static AdView Admobbannerview;
    public static com.facebook.ads.AdView Facebookbannerview;

    public RectangleBannerAd(Activity activity) {
        RectangleBannerAd.activity = activity;
    }

    public static void ShowRectangleAdmobBanner(Activity activity, ViewGroup viewGroup) {
        if (activity == null || viewGroup == null) return;
        if (!CheckInternet(activity)) {
            ShimmerAdHelper.onAdFailed(viewGroup);
            return;
        }

        ShimmerAdHelper.showRectangleShimmer(activity, viewGroup);

        if (Admobbannerview != null) {
            Admobbannerview.destroy();
        }
        Admobbannerview = new AdView(activity);
        Admobbannerview.setAdUnitId(AdmobarrayList.get(AdintercountAdmob));
        Admobbannerview.setAdSize(AdSize.MEDIUM_RECTANGLE);
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
                ShowRectangleFacebookBanner(activity, viewGroup);
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

    public static void ShowRectangleFacebookBanner(Activity activity, ViewGroup viewGroup) {
        if (activity == null || viewGroup == null) return;
        if (!CheckInternet(activity)) {
            ShimmerAdHelper.onAdFailed(viewGroup);
            return;
        }

        ShimmerAdHelper.showRectangleShimmer(activity, viewGroup);

        Facebookbannerview = new com.facebook.ads.AdView(activity, FacebookarrayList.get(AdintercountFacebook), com.facebook.ads.AdSize.RECTANGLE_HEIGHT_250);
        com.facebook.ads.AdListener adListener = new com.facebook.ads.AdListener() {
            @Override
            public void onError(Ad ad, AdError adError) {
                Facebookbannerview = null;
                ShimmerAdHelper.onAdFailed(viewGroup);
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

    public static void ShowRectangleBannerAd(Activity activity, ViewGroup viewGroup) {
        if (activity == null || viewGroup == null) return;
        if (!CheckInternet(activity)) {
            ShimmerAdHelper.onAdFailed(viewGroup);
            return;
        }

        ShimmerAdHelper.showRectangleShimmer(activity, viewGroup);

        if (GetFirebasedata.AdsType == 1) {
            ShowRectangleAdmobBanner(activity, viewGroup);
        } else if (GetFirebasedata.AdsType == 2) {
            ShowRectangleFacebookBanner(activity, viewGroup);
        } else if (GetFirebasedata.AdsType == 3) {
            if (Adpriority % 2 == 0) {
                ShowRectangleAdmobBanner(activity, viewGroup);
            } else {
                ShowRectangleFacebookBanner(activity, viewGroup);
            }
            Adpriority++;
        } else if (GetFirebasedata.AdsType == 4) {
            if (Adpriority % 2 == 0) {
                ShowRectangleFacebookBanner(activity, viewGroup);
            } else {
                ShowRectangleAdmobBanner(activity, viewGroup);
            }
            Adpriority++;
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
}
