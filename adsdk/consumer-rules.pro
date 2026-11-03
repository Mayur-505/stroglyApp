# Proguard Consumer Rules for :adsdk library

# Keep all public classes, methods, and fields in adsdk to avoid reflection/ad loading crashes
-keep class com.ads.sdk.adssdk.** { *; }
-keep interface com.ads.sdk.adssdk.** { *; }

# Keep Custom Views and their constructors for XML inflation
-keep class com.ads.sdk.adssdk.TemplateView {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public <init>(android.content.Context, android.util.AttributeSet, int, int);
    public void set*(...);
}

# Keep Data Models and JSON mapped fields
-keep class com.ads.sdk.adssdk.AffiliateAdItem { *; }
-keepclassmembers class com.ads.sdk.adssdk.AffiliateAdItem { <fields>; }

# Keep ViewBinding classes
-keep class com.ads.sdk.adssdk.databinding.** { *; }

# Keep Facebook Shimmer FrameLayout
-keep class com.facebook.shimmer.ShimmerFrameLayout {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public <init>(android.content.Context, android.util.AttributeSet, int, int);
    public void set*(...);
}
-keep class com.facebook.shimmer.** { *; }
-dontwarn com.facebook.shimmer.**
