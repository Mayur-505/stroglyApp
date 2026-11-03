package com.ads.sdk.adssdk;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListPopupWindow;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.browser.customtabs.CustomTabsIntent;
import androidx.core.content.ContextCompat;
import androidx.core.view.ViewCompat;

import com.ads.sdk.adssdk.databinding.AdsAmActivityNativeAdsTempBinding;
import com.facebook.ads.Ad;
import com.facebook.ads.AdError;
import com.facebook.ads.AdOptionsView;
import com.facebook.ads.NativeAd;
import com.facebook.ads.NativeAdLayout;
import com.facebook.ads.NativeAdListener;
import com.facebook.ads.NativeAdView;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdLoader;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.LoadAdError;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class AdvanceNativeAd {

    static Activity activity;
    public static int AdintercountAdmob = 0;
    public static int AdintercountAdmobSmall = 0;
    public static int AdintercountFacebook = 0;
    public static int Adpriority = 1;
    public static int SmallnativeorBignative = 1;
    public static com.google.android.gms.ads.nativead.NativeAd Admobnativead;
    public static com.google.android.gms.ads.nativead.NativeAd AdmobSmallnativead;
    public static NativeAd FacebooknativeAd;
    public static NativeAd FBNativeAds;
    public static ArrayList<String> AdmobarrayList = new ArrayList<>();
    public static ArrayList<String> AdmobSmallarrayList = new ArrayList<>();
    public static ArrayList<String> FacebookarrayList = new ArrayList<>();
    public static int Counter = 1;
    public static int CounterRefral = 1;

    public AdvanceNativeAd(Activity activity) {
        AdvanceNativeAd.activity = activity;
    }

    public static void ShowAdmobnative(Activity activity, ViewGroup viewGroup) {
        if (activity == null || viewGroup == null) return;
        if (!CheckInternet(activity)) {
            ShimmerAdHelper.onAdFailed(viewGroup);
            return;
        }

        // Guard: AdmobarrayList is populated asynchronously from Firebase
        // (GetFirebasedata). If this runs before that fetch finishes — or
        // the list ends up empty for any other reason — fall back instead
        // of crashing with "Index 0 out of bounds for length 0".
        if (AdmobarrayList == null || AdmobarrayList.isEmpty()) {
            Log.w("TAG", "ShowAdmobnative: AdmobarrayList is empty, falling back.");
            if (GetFirebasedata.ShowLoanTypesButton == 1) {
                AffiliateAdNative(activity, viewGroup);
            } else {
                ShowFBNativeAd(activity, viewGroup);
            }
            return;
        }
        // Keep the rotating index in range even if the list shrank.
        if (AdintercountAdmob >= AdmobarrayList.size()) {
            AdintercountAdmob = 0;
        }

        ShimmerAdHelper.showNativeShimmer(activity, viewGroup, false);

        AdLoader.Builder adLoader = new AdLoader.Builder(activity, AdmobarrayList.get(AdintercountAdmob)).forNativeAd(new com.google.android.gms.ads.nativead.NativeAd.OnNativeAdLoadedListener() {
            @Override
            public void onNativeAdLoaded(com.google.android.gms.ads.nativead.NativeAd nativeAd) {

                Admobnativead = nativeAd;
                if (Admobnativead == null) {
                    ShimmerAdHelper.onAdFailed(viewGroup);
                    return;
                }
                LoadAdmobnative(activity, viewGroup, Admobnativead);
            }

        });
        // Rotate to the next ad unit id, wrapping by the list's actual size
        // (not a hardcoded "4") so this stays safe no matter how many ad
        // unit ids are configured.
        AdintercountAdmob = (AdintercountAdmob + 1) % AdmobarrayList.size();
        adLoader.withAdListener(new AdListener() {

            @Override
            public void onAdFailedToLoad(LoadAdError loadAdError) {
                Admobnativead = null;
                if (GetFirebasedata.ShowLoanTypesButton == 1) {
                    AffiliateAdNative(activity, viewGroup);
                } else {
                    ShowFBNativeAd(activity, viewGroup);
                }
            }
        }).build().loadAd(new AdRequest.Builder().build());
    }

    public static void ShowAdmobSmallnative(Activity activity, ViewGroup viewGroup) {
        if (activity == null || viewGroup == null) return;
        if (!CheckInternet(activity)) {
            ShimmerAdHelper.onAdFailed(viewGroup);
            return;
        }

        // Guard: same empty-list crash as ShowAdmobnative, for the small
        // native ad unit list.
        if (AdmobSmallarrayList == null || AdmobSmallarrayList.isEmpty()) {
            Log.w("TAG", "ShowAdmobSmallnative: AdmobSmallarrayList is empty, falling back.");
            if (GetFirebasedata.ShowLoanTypesButton == 1) {
                AffiliateAdNative(activity, viewGroup);
            } else {
                ShowFBNativeAd(activity, viewGroup);
            }
            return;
        }
        if (AdintercountAdmobSmall >= AdmobSmallarrayList.size()) {
            AdintercountAdmobSmall = 0;
        }

        ShimmerAdHelper.showNativeShimmer(activity, viewGroup, true);

        AdLoader.Builder adLoader = new AdLoader.Builder(activity, AdmobSmallarrayList.get(AdintercountAdmobSmall)).forNativeAd(new com.google.android.gms.ads.nativead.NativeAd.OnNativeAdLoadedListener() {
            @Override
            public void onNativeAdLoaded(com.google.android.gms.ads.nativead.NativeAd nativeAd) {
                AdmobSmallnativead = nativeAd;
                if (AdmobSmallnativead == null) {
                    ShimmerAdHelper.onAdFailed(viewGroup);
                    return;
                }
                LoadAdmobSmallnative(activity, viewGroup, AdmobSmallnativead);
            }

        });
        AdintercountAdmobSmall = (AdintercountAdmobSmall + 1) % AdmobSmallarrayList.size();
        adLoader.withAdListener(new AdListener() {
            @Override
            public void onAdFailedToLoad(LoadAdError loadAdError) {
                AdmobSmallnativead = null;
                if (GetFirebasedata.ShowLoanTypesButton == 1) {
                    AffiliateAdNative(activity, viewGroup);
                } else {
                    ShowFBNativeAd(activity, viewGroup);
                }
            }
        }).build().loadAd(new AdRequest.Builder().build());
    }


    public static void LoadAdmobnative(Activity activity, ViewGroup viewGroup, com.google.android.gms.ads.nativead.NativeAd AdmobNative) {
        if (activity == null || activity.isFinishing() || activity.isDestroyed() || viewGroup == null) {
            return;
        }

        LayoutInflater from = LayoutInflater.from(activity);
        AdsAmActivityNativeAdsTempBinding adsAmActivityNativeAdsTempBinding = AdsAmActivityNativeAdsTempBinding.inflate(from, viewGroup, false);
        NativeTemplateStyle build = new NativeTemplateStyle.Builder().build();
        adsAmActivityNativeAdsTempBinding.cardLargeTemplate.setVisibility(View.VISIBLE);
        adsAmActivityNativeAdsTempBinding.cardSmallTemplate.setVisibility(View.GONE);
        adsAmActivityNativeAdsTempBinding.cardbuttonTemplate.setVisibility(View.GONE);
        adsAmActivityNativeAdsTempBinding.myTemplateLarge.setStyles(build);
        adsAmActivityNativeAdsTempBinding.myTemplateLarge.setNativeAd(AdmobNative);

        ShimmerAdHelper.onAdLoaded(viewGroup, adsAmActivityNativeAdsTempBinding.getRoot());
    }

    public static void LoadAdmobSmallnative(Activity activity, ViewGroup viewGroup, com.google.android.gms.ads.nativead.NativeAd AdmobNative) {
        if (activity == null || activity.isFinishing() || activity.isDestroyed() || viewGroup == null) {
            return;
        }

        LayoutInflater from = LayoutInflater.from(activity);
        AdsAmActivityNativeAdsTempBinding adsAmActivityNativeAdsTempBinding = AdsAmActivityNativeAdsTempBinding.inflate(from, viewGroup, false);
        NativeTemplateStyle build = new NativeTemplateStyle.Builder().build();
        adsAmActivityNativeAdsTempBinding.cardLargeTemplate.setVisibility(View.GONE);
        adsAmActivityNativeAdsTempBinding.cardSmallTemplate.setVisibility(View.VISIBLE);
        adsAmActivityNativeAdsTempBinding.cardbuttonTemplate.setVisibility(View.GONE);
        adsAmActivityNativeAdsTempBinding.myTemplateSmall.setStyles(build);
        adsAmActivityNativeAdsTempBinding.myTemplateSmall.setNativeAd(AdmobNative);

        ShimmerAdHelper.onAdLoaded(viewGroup, adsAmActivityNativeAdsTempBinding.getRoot());
    }

    public static void ShowFBNativeAd(Activity activity, ViewGroup viewGroup) {
        if (activity == null || viewGroup == null) return;

        // Guard: FacebookarrayList is populated asynchronously from Firebase.
        // If it's empty (fetch not finished yet, or misconfigured), there's
        // no further fallback chain to try here — just fail gracefully
        // instead of crashing with "Index 0 out of bounds for length 0".
        if (FacebookarrayList == null || FacebookarrayList.isEmpty()) {
            Log.w("TAG", "ShowFBNativeAd: FacebookarrayList is empty, skipping.");
            ShimmerAdHelper.onAdFailed(viewGroup);
            return;
        }
        if (AdintercountFacebook >= FacebookarrayList.size()) {
            AdintercountFacebook = 0;
        }

        FacebooknativeAd = new NativeAd(activity, FacebookarrayList.get(AdintercountFacebook));
        NativeAdListener nativeAdListener = new NativeAdListener() {

            @Override
            public void onMediaDownloaded(Ad ad) {
                Log.e("ok", " Native ad finished downloading all assets.");
            }

            @Override
            public void onError(Ad ad, AdError adError) {
                Log.e("ok", " Native ad failed to load: " + adError.getErrorMessage());
                FacebooknativeAd = null;
                if (GetFirebasedata.SmallnativeorBignative == 1) {
                    ShowAdmobnative(activity, viewGroup);
                } else if (GetFirebasedata.SmallnativeorBignative == 2) {
                    ShowAdmobSmallnative(activity, viewGroup);
                } else if (GetFirebasedata.SmallnativeorBignative == 3) {
                    if (SmallnativeorBignative % 2 == 0) {
                        ShowAdmobnative(activity, viewGroup);
                    } else {
                        ShowAdmobSmallnative(activity, viewGroup);
                    }
                    SmallnativeorBignative++;
                }
            }

            @Override
            public void onAdLoaded(Ad ad) {
                if (FacebooknativeAd == null || activity == null || viewGroup == null) {
                    ShimmerAdHelper.onAdFailed(viewGroup);
                    return;
                }
                View adView = NativeAdView.render(activity, FacebooknativeAd);
                DisplayMetrics metrics = activity.getResources().getDisplayMetrics();
                float dp = 250f;
                float fpixels = metrics.density * dp;
                int pixels = (int) (fpixels + 0.5f);
                adView.setLayoutParams(new RelativeLayout.LayoutParams(ListPopupWindow.MATCH_PARENT, pixels));
                ShimmerAdHelper.onAdLoaded(viewGroup, adView);

                Log.d("ok", "Native ad is loaded and ready to be displayed!");
            }

            @Override
            public void onAdClicked(Ad ad) {
                Log.e("ok", "Native ad clicked!");
            }

            @Override
            public void onLoggingImpression(Ad ad) {
                FacebooknativeAd = null;
                Log.e("ok", "Native ad impression logged!");
            }
        };
        if (!CheckInternet(activity)) {
            ShimmerAdHelper.onAdFailed(viewGroup);
            return;
        }
        FacebooknativeAd.loadAd(
                FacebooknativeAd.buildLoadAdConfig()
                        .withAdListener(nativeAdListener)
                        .build());

        // Rotate to the next ad unit id, wrapping by the list's actual size
        // (not a hardcoded "4") so this stays safe no matter how many ad
        // unit ids are configured.
        AdintercountFacebook = (AdintercountFacebook + 1) % FacebookarrayList.size();
    }

    public static void LoadFbNative(Activity activity, ViewGroup viewGroup) {
        if (activity == null || viewGroup == null) return;

        // Guard: same empty-list crash as ShowFBNativeAd.
        if (FacebookarrayList == null || FacebookarrayList.isEmpty()) {
            Log.w("TAG", "LoadFbNative: FacebookarrayList is empty, skipping.");
            ShimmerAdHelper.onAdFailed(viewGroup);
            return;
        }
        if (AdintercountFacebook >= FacebookarrayList.size()) {
            AdintercountFacebook = 0;
        }

        FBNativeAds = new NativeAd(activity, FacebookarrayList.get(AdintercountFacebook));

        NativeAdListener nativeAdListener = new NativeAdListener() {
            @Override
            public void onMediaDownloaded(Ad ad) {

            }

            @Override
            public void onError(Ad ad, AdError adError) {
                FBNativeAds = null;
                if (GetFirebasedata.SmallnativeorBignative == 1) {
                    ShowAdmobnative(activity, viewGroup);
                } else if (GetFirebasedata.SmallnativeorBignative == 2) {
                    ShowAdmobSmallnative(activity, viewGroup);
                } else if (GetFirebasedata.SmallnativeorBignative == 3) {
                    if (SmallnativeorBignative % 2 == 0) {
                        ShowAdmobnative(activity, viewGroup);
                    } else {
                        ShowAdmobSmallnative(activity, viewGroup);
                    }
                    SmallnativeorBignative++;
                } else {
                    ShimmerAdHelper.onAdFailed(viewGroup);
                }
            }

            @Override
            public void onAdLoaded(Ad ad) {
                if (FBNativeAds == null) {
                    ShimmerAdHelper.onAdFailed(viewGroup);
                    return;
                }
                ShowFbNative(activity, viewGroup);
            }

            @Override
            public void onAdClicked(Ad ad) {

            }

            @Override
            public void onLoggingImpression(Ad ad) {
                FBNativeAds = null;

            }
        };
        if (!CheckInternet(activity)) {
            ShimmerAdHelper.onAdFailed(viewGroup);
            return;
        }
        FBNativeAds.loadAd(
                FBNativeAds.buildLoadAdConfig()
                        .withAdListener(nativeAdListener)
                        .build());

        AdintercountFacebook = (AdintercountFacebook + 1) % FacebookarrayList.size();
    }

    public static void ShowFbNative(Activity activity, ViewGroup viewGroup) {
        if (activity == null || viewGroup == null) return;
        LayoutInflater inflater = LayoutInflater.from(activity);
        LinearLayout linearLayout;
        linearLayout = (LinearLayout) inflater.inflate(R.layout.native_ad_layout, viewGroup, false);
        ShimmerAdHelper.onAdLoaded(viewGroup, linearLayout);
        LoadFBnativeAd(activity, viewGroup);
    }

    public static void LoadFBnativeAd(Activity activity, ViewGroup viewGroup) {

        NativeAdLayout FB_NativeADLayout = null;

        FBNativeAds.unregisterView();

        // Add the AdOptionsView
        LinearLayout adChoicesContainer = viewGroup.findViewById(R.id.ad_choices_container);
        AdOptionsView adOptionsView = new AdOptionsView(activity, FBNativeAds, FB_NativeADLayout);
        adChoicesContainer.removeAllViews();
        adChoicesContainer.addView(adOptionsView, 0);

        // Create native UI using the ad metadata.
        com.facebook.ads.MediaView nativeAdIcon = viewGroup.findViewById(R.id.native_ad_icon);
        TextView nativeAdTitle = viewGroup.findViewById(R.id.native_ad_title);
        com.facebook.ads.MediaView nativeAdMedia = viewGroup.findViewById(R.id.native_ad_media);
        TextView nativeAdSocialContext = viewGroup.findViewById(R.id.native_ad_social_context);
        TextView nativeAdBody = viewGroup.findViewById(R.id.native_ad_body);
        nativeAdBody.setSelected(true);
        TextView sponsoredLabel = viewGroup.findViewById(R.id.native_ad_sponsored_label);
        TextView nativeAdCallToAction = viewGroup.findViewById(R.id.native_ad_call_to_action);

        // Set the Text.
        nativeAdTitle.setText(FBNativeAds.getAdvertiserName());
        nativeAdBody.setText(FBNativeAds.getAdBodyText());
        nativeAdBody.setSelected(true);
        nativeAdSocialContext.setText(FBNativeAds.getAdSocialContext());
        nativeAdSocialContext.setSelected(true);
        nativeAdCallToAction.setVisibility(FBNativeAds.hasCallToAction() ? View.VISIBLE : View.INVISIBLE);
        nativeAdCallToAction.setText(FBNativeAds.getAdCallToAction());
        sponsoredLabel.setText(FBNativeAds.getSponsoredTranslation());

        // Create a list of clickable views
        List<View> clickableViews = new ArrayList<>();
        clickableViews.add(nativeAdTitle);
        clickableViews.add(nativeAdCallToAction);

        // Register the Title and CTA button to listen for clicks.
        FBNativeAds.registerViewForInteraction(
                viewGroup, nativeAdMedia, nativeAdIcon, clickableViews);

    }

    public static void ShowNativeAd(Activity activity, ViewGroup viewGroup) {
        if (activity == null || viewGroup == null){
            ShimmerAdHelper.onAdFailed(viewGroup);
            return;
        }
        if (!CheckInternet(activity)) {
            ShimmerAdHelper.onAdFailed(viewGroup);
            return;
        }

        PreferencesHelper preferencesHelper = new PreferencesHelper(activity);
        if (preferencesHelper.IsOrganic()) {
            if (Counter % GetFirebasedata.NativeCount == 0) {
                boolean isSmall = (GetFirebasedata.SmallnativeorBignative == 2);
                ShimmerAdHelper.showNativeShimmer(activity, viewGroup, isSmall);

                if (GetFirebasedata.AdsType == 1) {
                    if (GetFirebasedata.SmallnativeorBignative == 1) {
                        ShowAdmobnative(activity, viewGroup);
                    } else if (GetFirebasedata.SmallnativeorBignative == 2) {
                        ShowAdmobSmallnative(activity, viewGroup);
                    } else if (GetFirebasedata.SmallnativeorBignative == 3) {
                        if (SmallnativeorBignative % 2 == 0) {
                            ShowAdmobnative(activity, viewGroup);
                        } else {
                            ShowAdmobSmallnative(activity, viewGroup);
                        }
                        SmallnativeorBignative++;
                    }
                } else if (GetFirebasedata.AdsType == 2) {
                    if (GetFirebasedata.FacebookCustom == 1) {
                        LoadFbNative(activity, viewGroup);
                    } else if (GetFirebasedata.FacebookCustom == 2) {
                        ShowFBNativeAd(activity, viewGroup);
                    }
                } else if (GetFirebasedata.AdsType == 3) {
                    if (Adpriority % 2 == 0) {
                        if (GetFirebasedata.FacebookCustom == 1) {
                            LoadFbNative(activity, viewGroup);
                        } else if (GetFirebasedata.FacebookCustom == 2) {
                            ShowFBNativeAd(activity, viewGroup);
                        }
                    } else {
                        if (GetFirebasedata.SmallnativeorBignative == 1) {
                            ShowAdmobnative(activity, viewGroup);
                        } else if (GetFirebasedata.SmallnativeorBignative == 2) {
                            ShowAdmobSmallnative(activity, viewGroup);
                        } else if (GetFirebasedata.SmallnativeorBignative == 3) {
                            if (SmallnativeorBignative % 2 == 0) {
                                ShowAdmobnative(activity, viewGroup);
                            } else {
                                ShowAdmobSmallnative(activity, viewGroup);
                            }
                            SmallnativeorBignative++;
                        }
                    }
                    Adpriority++;
                } else if (GetFirebasedata.AdsType == 4) {
                    if (Adpriority % 2 == 0) {
                        if (GetFirebasedata.FacebookCustom == 1) {
                            LoadFbNative(activity, viewGroup);
                        } else if (GetFirebasedata.FacebookCustom == 2) {
                            ShowFBNativeAd(activity, viewGroup);
                        }
                    } else {
                        if (GetFirebasedata.SmallnativeorBignative == 1) {
                            ShowAdmobnative(activity, viewGroup);
                        } else if (GetFirebasedata.SmallnativeorBignative == 2) {
                            ShowAdmobSmallnative(activity, viewGroup);
                        } else if (GetFirebasedata.SmallnativeorBignative == 3) {
                            if (SmallnativeorBignative % 2 == 0) {
                                ShowAdmobnative(activity, viewGroup);
                            } else {
                                ShowAdmobSmallnative(activity, viewGroup);
                            }
                            SmallnativeorBignative++;
                        }
                    }
                    Adpriority++;
                } else if (GetFirebasedata.AdsType == 5) {
                    AffiliateAdNative(activity, viewGroup);
                }else{
                    ShimmerAdHelper.onAdFailed(viewGroup);
                }
            } else {
                ShimmerAdHelper.onAdFailed(viewGroup);
            }
            Counter++;
        } else {
            if (CounterRefral % GetFirebasedata.NativeCountRefral == 0) {
                boolean isSmall = (GetFirebasedata.SmallnativeorBignative == 2);
                ShimmerAdHelper.showNativeShimmer(activity, viewGroup, isSmall);

                if (GetFirebasedata.AdsType == 1) {
                    if (GetFirebasedata.SmallnativeorBignative == 1) {
                        ShowAdmobnative(activity, viewGroup);
                    } else if (GetFirebasedata.SmallnativeorBignative == 2) {
                        ShowAdmobSmallnative(activity, viewGroup);
                    } else if (GetFirebasedata.SmallnativeorBignative == 3) {
                        if (SmallnativeorBignative % 2 == 0) {
                            ShowAdmobnative(activity, viewGroup);
                        } else {
                            ShowAdmobSmallnative(activity, viewGroup);
                        }
                        SmallnativeorBignative++;
                    }
                } else if (GetFirebasedata.AdsType == 2) {
                    if (GetFirebasedata.FacebookCustom == 1) {
                        LoadFbNative(activity, viewGroup);
                    } else if (GetFirebasedata.FacebookCustom == 2) {
                        ShowFBNativeAd(activity, viewGroup);
                    }
                } else if (GetFirebasedata.AdsType == 3) {
                    if (Adpriority % 2 == 0) {
                        if (GetFirebasedata.FacebookCustom == 1) {
                            LoadFbNative(activity, viewGroup);
                        } else if (GetFirebasedata.FacebookCustom == 2) {
                            ShowFBNativeAd(activity, viewGroup);
                        }
                    } else {
                        if (GetFirebasedata.SmallnativeorBignative == 1) {
                            ShowAdmobnative(activity, viewGroup);
                        } else if (GetFirebasedata.SmallnativeorBignative == 2) {
                            ShowAdmobSmallnative(activity, viewGroup);
                        } else if (GetFirebasedata.SmallnativeorBignative == 3) {
                            if (SmallnativeorBignative % 2 == 0) {
                                ShowAdmobnative(activity, viewGroup);
                            } else {
                                ShowAdmobSmallnative(activity, viewGroup);
                            }
                            SmallnativeorBignative++;
                        }
                    }
                    Adpriority++;
                } else if (GetFirebasedata.AdsType == 4) {
                    if (Adpriority % 2 == 0) {
                        if (GetFirebasedata.FacebookCustom == 1) {
                            LoadFbNative(activity, viewGroup);
                        } else if (GetFirebasedata.FacebookCustom == 2) {
                            ShowFBNativeAd(activity, viewGroup);
                        }
                    } else {
                        if (GetFirebasedata.SmallnativeorBignative == 1) {
                            ShowAdmobnative(activity, viewGroup);
                        } else if (GetFirebasedata.SmallnativeorBignative == 2) {
                            ShowAdmobSmallnative(activity, viewGroup);
                        } else if (GetFirebasedata.SmallnativeorBignative == 3) {
                            if (SmallnativeorBignative % 2 == 0) {
                                ShowAdmobnative(activity, viewGroup);
                            } else {
                                ShowAdmobSmallnative(activity, viewGroup);
                            }
                            SmallnativeorBignative++;
                        }
                    }
                    Adpriority++;
                } else if (GetFirebasedata.AdsType == 5) {
                    AffiliateAdNative(activity, viewGroup);
                }else{
                    ShimmerAdHelper.onAdFailed(viewGroup);
                }
            } else {
                ShimmerAdHelper.onAdFailed(viewGroup);
            }
            CounterRefral++;
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

    public static void AffiliateAdNative(final Activity activity, ViewGroup viewGroup) {
        if (activity == null || viewGroup == null) return;
        LayoutInflater inflater = LayoutInflater.from(activity);
        LinearLayout linearLayout = (LinearLayout) inflater.inflate(R.layout.affiliate_native_dialog, viewGroup, false);
        ShimmerAdHelper.onAdLoaded(viewGroup, linearLayout);

//        if (AffiliateAdHelper.bindNative(activity, linearLayout)) {
//            return;
//        }

        ImageView media_view = linearLayout.findViewById(R.id.media_view);
        ImageView imgLogo = linearLayout.findViewById(R.id.iv_logo);
        LinearLayout ll_atmeclick = linearLayout.findViewById(R.id.ll_atmeclick);
        Button btn_playnow = linearLayout.findViewById(R.id.btn_playnow);
        TextView txt_title = linearLayout.findViewById(R.id.tv_title);
        TextView txt_desc = linearLayout.findViewById(R.id.tv_description);
//        int[] imglogo = new int[]{R.drawable.rbxlogo, R.drawable.qlogo};
        String[] btnText = new String[]{"Install Now", "Tap to Play", "Download Now", "Play Now"};
        String[] titles = new String[]{"Create your Own Skin", "Tap For Skins", "Design: Your Dream Skin", "Custom Skins Made Easy"};
        String[] description = new String[]{
                "\uD83C\uDFA8 Draw your own Roblox skin exactly how you want! Download the app and start creating.",
                "Customize your own skin or tap to pick ready outfits! Download Clothes Skin Maker for Roblox now! \u2728",
                "\uD83C\uDFA8 Design your dream Roblox skin from scratch! Customize every detail and make it yours. Download now!",
                "Design Your Roblox Avatar! Download Clothes Skin Maker for Roblox now! \u2728"
        };

        int randomtitleIndex = new Random().nextInt(titles.length);
        int randomdescIndex = new Random().nextInt(description.length);
        int randombtnIndex = new Random().nextInt(btnText.length);

        txt_title.setText(titles[randomtitleIndex]);
        txt_desc.setText(description[randomdescIndex]);
        btn_playnow.setText(btnText[randombtnIndex]);
//        btn_playnow.setText(btnText[new Random().nextInt(btnText.length)]);
//        imgLogo.setImageResource(new Random().nextInt(imglogo.length));
        if (btn_playnow != null) {
            btn_playnow.setBackgroundResource(R.drawable.bg_loading_subtitles_accent_yllw);
            ViewCompat.setBackgroundTintList(btn_playnow, null);
        }
        media_view.setImageResource(new int[]{R.drawable.bigbanner1, R.drawable.bigbanner2, R.drawable.bigbanner3, R.drawable.bigbanner4, R.drawable.bigbanner5}[new Random().nextInt(5)]);

        View.OnClickListener openQureka = v -> AffiliateAdHelper.openPlaystore(activity, GetFirebasedata.getNextQurekaUrl(activity));
        if (btn_playnow != null) btn_playnow.setOnClickListener(openQureka);
        ll_atmeclick.setOnClickListener(openQureka);
    }

    public static void AffiliateAdNativeSmall(final Context activity, ViewGroup viewGroup) {
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
