package com.strongly.strongly.ui;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.view.animation.AlphaAnimation;

import androidx.appcompat.app.AppCompatActivity;

import com.google.gson.JsonObject;
import com.strongly.strongly.R;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.net.ApiConstants;
import com.strongly.strongly.util.Prefs;
import com.strongly.strongly.util.Session;

public class SplashActivity extends AppCompatActivity {
    private final Handler handler = new Handler(Looper.getMainLooper());
    private final Runnable navigate = this::navigate;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);
        UiUtil.edgeToEdge(this);

        View content = findViewById(R.id.splash_content);
        AlphaAnimation fade = new AlphaAnimation(0f, 1f);
        fade.setDuration(900);
        fade.setFillAfter(true);
        content.startAnimation(fade);

        if (!Session.isAuthenticated()) {
            JsonObject body = new JsonObject();
            body.addProperty("language", Session.language());
            ApiClient.get().post(ApiConstants.GUEST_LOGIN, body, r -> {
                if (!r.isOk()) return;
                JsonObject d = r.dataObject();
                if (d.has("token") && d.has("user") && d.get("user").isJsonObject()) {
                    JsonObject u = d.getAsJsonObject("user");
                    Session.save(d.get("token").getAsString(), UiUtil.str(u, "_id"), true,
                            UiUtil.str(u, "name"), null, null);
                }
            });
        }
        handler.postDelayed(navigate, 2800);
    }

    private void navigate() {
        boolean done = Prefs.getBool("onboarding_completed", false);
        Intent i = new Intent(this, done ? HomeActivity.class : OnboardingActivity.class);
        startActivity(i);
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
        finish();
    }

    @Override
    protected void onDestroy() {
        handler.removeCallbacks(navigate);
        super.onDestroy();
    }
}
