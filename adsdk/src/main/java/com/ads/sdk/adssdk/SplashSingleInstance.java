package com.ads.sdk.adssdk;

import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.Window;

import androidx.appcompat.app.AppCompatActivity;


public class SplashSingleInstance extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            getWindow().setStatusBarColor(Window.DECOR_CAPTION_SHADE_AUTO);
        }
        setContentView(R.layout.ad_unit_admob_button);
    }

    @Override
    public void onBackPressed() {
    }

    public interface SingleInstanceCallback {
        void completed();
    }
}