package com.ads.sdk.adssdk;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Typeface;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RatingBar;
import android.widget.TextView;

import androidx.annotation.RequiresApi;

import com.google.android.gms.ads.nativead.MediaView;
import com.google.android.gms.ads.nativead.NativeAd;
import com.google.android.gms.ads.nativead.NativeAdView;

public class TemplateView extends FrameLayout {
    private TextView callToActionView;
    private ImageView iconView;
    private MediaView mediaView;
    private NativeAd nativeAd;
    private NativeAdView nativeAdView;
    private TextView primaryView;
    private RatingBar ratingBar;
    private TextView secondaryView;
    private NativeTemplateStyle styles;
    private int templateMinHeight = 120;
    private int templateType = R.layout.ad_unit_admob_med;
    private TextView tertiaryView;

    public TemplateView(Context context) {
        super(context);
    }

    public TemplateView(Context context, AttributeSet attributeSet) {
        super(context, attributeSet);
        initView(context, attributeSet);
    }

    public TemplateView(Context context, AttributeSet attributeSet, int i) {
        super(context, attributeSet, i);
        initView(context, attributeSet);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public TemplateView(Context context, AttributeSet attributeSet, int i, int i2) {
        super(context, attributeSet, i, i2);
        initView(context, attributeSet);
    }

    public void setStyles(NativeTemplateStyle nativeTemplateStyle) {
        this.styles = nativeTemplateStyle;
        applyStyles();
    }

    public NativeAdView getNativeAdView() {
        return this.nativeAdView;
    }

    private void applyStyles() {
        TextView textView;
        TextView textView2;
        TextView textView3;
        TextView appCompatButton;
        TextView textView4;
        TextView textView5;
        TextView textView6;
        TextView appCompatButton2;
        TextView appCompatButton3;
        TextView textView7;
        TextView textView8;
        TextView textView9;
        TextView appCompatButton4;
        TextView textView10;
        TextView textView11;
        TextView textView12;
        ColorDrawable mainBackgroundColor = this.styles.getMainBackgroundColor();
        if (mainBackgroundColor != null) {
            TextView textView13 = this.primaryView;
            if (textView13 != null) {
                textView13.setBackground(mainBackgroundColor);
            }
            TextView textView14 = this.secondaryView;
            if (textView14 != null) {
                textView14.setBackground(mainBackgroundColor);
            }
            TextView textView15 = this.tertiaryView;
            if (textView15 != null) {
                textView15.setBackground(mainBackgroundColor);
            }
        }
        Typeface primaryTextTypeface = this.styles.getPrimaryTextTypeface();
        if (!(primaryTextTypeface == null || (textView12 = this.primaryView) == null)) {
            textView12.setTypeface(primaryTextTypeface);
        }
        Typeface secondaryTextTypeface = this.styles.getSecondaryTextTypeface();
        if (!(secondaryTextTypeface == null || (textView11 = this.secondaryView) == null)) {
            textView11.setTypeface(secondaryTextTypeface);
        }
        Typeface tertiaryTextTypeface = this.styles.getTertiaryTextTypeface();
        if (!(tertiaryTextTypeface == null || (textView10 = this.tertiaryView) == null)) {
            textView10.setTypeface(tertiaryTextTypeface);
        }
        Typeface callToActionTextTypeface = this.styles.getCallToActionTextTypeface();
        if (!(callToActionTextTypeface == null || (appCompatButton4 = this.callToActionView) == null)) {
            appCompatButton4.setTypeface(callToActionTextTypeface);
        }
        int primaryTextTypefaceColor = this.styles.getPrimaryTextTypefaceColor();
        if (primaryTextTypefaceColor > 0 && (textView9 = this.primaryView) != null) {
            textView9.setTextColor(primaryTextTypefaceColor);
        }
        int secondaryTextTypefaceColor = this.styles.getSecondaryTextTypefaceColor();
        if (secondaryTextTypefaceColor > 0 && (textView8 = this.secondaryView) != null) {
            textView8.setTextColor(secondaryTextTypefaceColor);
        }
        int tertiaryTextTypefaceColor = this.styles.getTertiaryTextTypefaceColor();
        if (tertiaryTextTypefaceColor > 0 && (textView7 = this.tertiaryView) != null) {
            textView7.setTextColor(tertiaryTextTypefaceColor);
        }
        int callToActionTypefaceColor = this.styles.getCallToActionTypefaceColor();
        if (callToActionTypefaceColor > 0 && (appCompatButton3 = this.callToActionView) != null) {
            appCompatButton3.setTextColor(callToActionTypefaceColor);
        }
        float callToActionTextSize = this.styles.getCallToActionTextSize();
        if (callToActionTextSize > 0.0f && (appCompatButton2 = this.callToActionView) != null) {
            appCompatButton2.setTextSize(callToActionTextSize);
        }
        float primaryTextSize = this.styles.getPrimaryTextSize();
        if (primaryTextSize > 0.0f && (textView6 = this.primaryView) != null) {
            textView6.setTextSize(primaryTextSize);
        }
        float secondaryTextSize = this.styles.getSecondaryTextSize();
        if (secondaryTextSize > 0.0f && (textView5 = this.secondaryView) != null) {
            textView5.setTextSize(secondaryTextSize);
        }
        float tertiaryTextSize = this.styles.getTertiaryTextSize();
        if (tertiaryTextSize > 0.0f && (textView4 = this.tertiaryView) != null) {
            textView4.setTextSize(tertiaryTextSize);
        }
        ColorDrawable callToActionBackgroundColor = this.styles.getCallToActionBackgroundColor();
        if (!(callToActionBackgroundColor == null || (appCompatButton = this.callToActionView) == null)) {
            appCompatButton.setBackground(callToActionBackgroundColor);
        }
        ColorDrawable primaryTextBackgroundColor = this.styles.getPrimaryTextBackgroundColor();
        if (!(primaryTextBackgroundColor == null || (textView3 = this.primaryView) == null)) {
            textView3.setBackground(primaryTextBackgroundColor);
        }
        ColorDrawable secondaryTextBackgroundColor = this.styles.getSecondaryTextBackgroundColor();
        if (!(secondaryTextBackgroundColor == null || (textView2 = this.secondaryView) == null)) {
            textView2.setBackground(secondaryTextBackgroundColor);
        }
        ColorDrawable tertiaryTextBackgroundColor = this.styles.getTertiaryTextBackgroundColor();
        if (!(tertiaryTextBackgroundColor == null || (textView = this.tertiaryView) == null)) {
            textView.setBackground(tertiaryTextBackgroundColor);
        }
        invalidate();
        requestLayout();
    }

    private boolean adHasOnlyStore(NativeAd nativeAd2) {
        return !TextUtils.isEmpty(nativeAd2.getStore()) && TextUtils.isEmpty(nativeAd2.getAdvertiser());
    }

    @SuppressLint("WrongConstant")
    public void setNativeAd(NativeAd nativeAd2) {
        this.nativeAd = nativeAd2;
        String store = nativeAd2.getStore();
        String advertiser = nativeAd2.getAdvertiser();
        String headline = nativeAd2.getHeadline();
        String body = nativeAd2.getBody();
        String callToAction = nativeAd2.getCallToAction();
        Double starRating = nativeAd2.getStarRating();
        NativeAd.Image icon = nativeAd2.getIcon();
        this.nativeAdView.setCallToActionView(this.callToActionView);
        this.nativeAdView.setHeadlineView(this.primaryView);
        this.nativeAdView.setMediaView(this.mediaView);
        if (adHasOnlyStore(nativeAd2)) {
            this.nativeAdView.setStoreView(this.secondaryView);
        } else if (!TextUtils.isEmpty(advertiser)) {
            this.nativeAdView.setAdvertiserView(this.secondaryView);
            store = advertiser;
        } else {
            store = "";
        }
        this.primaryView.setText(headline);
        this.callToActionView.setText(callToAction);
        if (icon != null) {
            this.iconView.setVisibility(0);
            this.iconView.setImageDrawable(icon.getDrawable());
        } else {
            this.iconView.setVisibility(4);
        }
        TextView textView = this.tertiaryView;
        if (textView != null) {
            textView.setText(body);
            this.nativeAdView.setBodyView(this.tertiaryView);
            this.nativeAdView.setSelected(true);
        }
        this.nativeAdView.setNativeAd(nativeAd2);
    }

    public void destroyNativeAd() {
        this.nativeAd.destroy();
    }

    private void initView(Context context, AttributeSet attributeSet) {
        TypedArray obtainStyledAttributes = context.getTheme().obtainStyledAttributes(attributeSet, R.styleable.TemplateView, 0, 0);
        try {
            this.templateType = obtainStyledAttributes.getResourceId(R.styleable.TemplateView_gnt_template_type, this.templateType);
            this.templateMinHeight = obtainStyledAttributes.getResourceId(R.styleable.TemplateView_gnt_template_min_height, this.templateMinHeight);
            obtainStyledAttributes.recycle();
            ((LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE)).inflate(this.templateType, this);
        } catch (Throwable th) {
            obtainStyledAttributes.recycle();
            throw th;
        }
    }

    public void onFinishInflate() {
        super.onFinishInflate();
        this.nativeAdView = (NativeAdView) findViewById(R.id.native_ad_view);
        this.primaryView = (TextView) findViewById(R.id.primary);
        this.secondaryView = (TextView) findViewById(R.id.secondary);
        this.tertiaryView = (TextView) findViewById(R.id.body);
        RatingBar ratingBar2 = (RatingBar) findViewById(R.id.rating_bar);
        this.ratingBar = ratingBar2;
        this.callToActionView = (TextView) findViewById(R.id.cta);
        this.iconView = (ImageView) findViewById(R.id.icon);
        this.mediaView = (MediaView) findViewById(R.id.media_view);
    }
}
