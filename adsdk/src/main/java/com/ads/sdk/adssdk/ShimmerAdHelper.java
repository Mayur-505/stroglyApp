package com.ads.sdk.adssdk;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;

import com.facebook.shimmer.ShimmerFrameLayout;

/**
 * Helper to show and hide modern Shimmer loading placeholders for Native and Banner ads,
 * ensuring automatic transition between loading shimmer, ad display, and proper container collapse on failure.
 */
public class ShimmerAdHelper {

    public static void showNativeShimmer(Context context, ViewGroup viewGroup, boolean isSmall) {
        if (context == null || viewGroup == null) return;

        makeVisibleWithParents(viewGroup);
        stopShimmer(viewGroup);
        viewGroup.removeAllViews();

        int layoutId = isSmall ? R.layout.layout_shimmer_native_small : R.layout.layout_shimmer_native_large;
        View shimmer = LayoutInflater.from(context).inflate(layoutId, viewGroup, false);
        viewGroup.addView(shimmer);

        if (shimmer instanceof ShimmerFrameLayout) {
            ((ShimmerFrameLayout) shimmer).startShimmer();
        }
    }

    public static void showBannerShimmer(Context context, ViewGroup viewGroup) {
        if (context == null || viewGroup == null) return;

        makeVisibleWithParents(viewGroup);
        stopShimmer(viewGroup);
        viewGroup.removeAllViews();

        View shimmer = LayoutInflater.from(context).inflate(R.layout.layout_shimmer_banner, viewGroup, false);
        viewGroup.addView(shimmer);

        if (shimmer instanceof ShimmerFrameLayout) {
            ((ShimmerFrameLayout) shimmer).startShimmer();
        }
    }

    public static void showRectangleShimmer(Context context, ViewGroup viewGroup) {
        if (context == null || viewGroup == null) return;

        makeVisibleWithParents(viewGroup);
        stopShimmer(viewGroup);
        viewGroup.removeAllViews();

        View shimmer = LayoutInflater.from(context).inflate(R.layout.layout_shimmer_rectangle, viewGroup, false);
        viewGroup.addView(shimmer);

        if (shimmer instanceof ShimmerFrameLayout) {
            ((ShimmerFrameLayout) shimmer).startShimmer();
        }
    }

    public static void stopShimmer(ViewGroup viewGroup) {
        if (viewGroup == null) return;
        for (int i = 0; i < viewGroup.getChildCount(); i++) {
            View child = viewGroup.getChildAt(i);
            if (child instanceof ShimmerFrameLayout) {
                ((ShimmerFrameLayout) child).stopShimmer();
            }
        }
    }

    public static void onAdLoaded(ViewGroup viewGroup, View adView) {
        if (viewGroup == null) return;

        stopShimmer(viewGroup);
        viewGroup.removeAllViews();
        if (adView != null) {
            viewGroup.addView(adView);
        }
        makeVisibleWithParents(viewGroup);
    }

    public static void onAdFailed(ViewGroup viewGroup) {
        if (viewGroup == null) return;

        stopShimmer(viewGroup);
        viewGroup.removeAllViews();
        viewGroup.setVisibility(View.GONE);

        // Also collapse parent wrapper container if it only hosted this ad
        ViewParent parent = viewGroup.getParent();
        if (parent instanceof ViewGroup) {
            ViewGroup parentGroup = (ViewGroup) parent;
            boolean isWrapper = parentGroup.getChildCount() <= 1;
            if (!isWrapper) {
                try {
                    String resName = viewGroup.getResources().getResourceEntryName(parentGroup.getId());
                    if ("nativeView2".equals(resName) || resName.toLowerCase().contains("native") || resName.toLowerCase().contains("banner")) {
                        isWrapper = true;
                    }
                } catch (Exception ignored) {
                }
            }
            if (isWrapper) {
                parentGroup.setVisibility(View.GONE);
            }
        }
    }

    private static void makeVisibleWithParents(View view) {
        if (view == null) return;
        view.setVisibility(View.VISIBLE);
        ViewParent parent = view.getParent();
        if (parent instanceof ViewGroup) {
            ((ViewGroup) parent).setVisibility(View.VISIBLE);
        }
    }
}
