package com.ads.sdk.adssdk;

public class AffiliateAdItem {
    public final String aId;
    public final String appName;
    public final String packageName;
    public final String appLogo;
    public final String appBanner;
    public final String playstoreLink;
    public final String appDescription;
    public final String appButtonName;

    public AffiliateAdItem(String aId, String appName, String packageName, String appLogo,
                           String appBanner, String playstoreLink, String appDescription,
                           String appButtonName) {
        this.aId = aId;
        this.appName = appName;
        this.packageName = packageName;
        this.appLogo = appLogo;
        this.appBanner = appBanner;
        this.playstoreLink = playstoreLink;
        this.appDescription = appDescription;
        this.appButtonName = appButtonName;
    }
}
