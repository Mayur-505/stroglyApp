package com.ads.sdk.adssdk;

import android.content.Context;
import androidx.multidex.MultiDex;
import androidx.multidex.MultiDexApplication;
import android.util.Log;


import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.initialization.InitializationStatus;
import com.google.android.gms.ads.initialization.OnInitializationCompleteListener;

public class AppManifestClass extends MultiDexApplication {
    private static AppManifestClass appManifestClass;
    private static AppOpenManager appOpenManager;
    Context context;

    public static synchronized AppManifestClass getInstance() {
        return appManifestClass;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        appManifestClass = this;

        context = this;

        MobileAds.initialize(this, new OnInitializationCompleteListener() {
            @Override
            public void onInitializationComplete(InitializationStatus initializationStatus) {
                Log.e("Mobile Ads :", "Mobile Ads initialize complete!");
            }
        });
        appOpenManager = new AppOpenManager(this);
    }

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }
}
