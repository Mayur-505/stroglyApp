package com.strongly.strongly;

import android.app.Application;

import com.strongly.strongly.util.Prefs;
import com.strongly.strongly.util.Tr;

public class StronglyApp extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        Prefs.init(this);
        Tr.init(this);
        com.strongly.strongly.billing.PremiumService.get().init(this);
        // Arabic reads right-to-left: set the direction for every screen as it is created
        registerActivityLifecycleCallbacks(new ActivityLifecycleCallbacks() {
            @Override public void onActivityCreated(android.app.Activity a, android.os.Bundle b) {
                boolean rtl = "ar".equals(com.strongly.strongly.util.Session.language());
                a.getWindow().getDecorView().setLayoutDirection(rtl ? android.view.View.LAYOUT_DIRECTION_RTL : android.view.View.LAYOUT_DIRECTION_LTR);
            }
            @Override public void onActivityStarted(android.app.Activity a) { }
            @Override public void onActivityResumed(android.app.Activity a) { }
            @Override public void onActivityPaused(android.app.Activity a) { }
            @Override public void onActivityStopped(android.app.Activity a) { }
            @Override public void onActivitySaveInstanceState(android.app.Activity a, android.os.Bundle b) { }
            @Override public void onActivityDestroyed(android.app.Activity a) { }
        });
    }
}
