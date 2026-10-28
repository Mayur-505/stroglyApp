package com.strongly.strongly.ui;

import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.InputFilter;
import android.text.InputType;
import android.text.TextWatcher;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.style.ForegroundColorSpan;
import android.text.style.StyleSpan;
import android.view.Gravity;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.google.gson.JsonObject;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.net.ApiConstants;

import java.util.Locale;

/** 6-digit email verification (Flutter's OTPVerificationScreen). */
public class OtpActivity extends AppCompatActivity {
    public static final String EXTRA_EMAIL = "email";
    private static final int LIME = Kit.LIME;

    private final EditText[] boxes = new EditText[6];
    private final Handler handler = new Handler(Looper.getMainLooper());
    private int seconds = 600;
    private boolean resending = false;
    private String email;
    private TextView timerText, resend;
    private AuthUi.LoadingButton button;
    private View anchor;

    private final Runnable tick = new Runnable() {
        @Override public void run() {
            if (seconds > 0) { seconds--; render(); handler.postDelayed(this, 1000); }
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        email = getIntent().getStringExtra(EXTRA_EMAIL);
        if (email == null) email = "";
        LinearLayout col = AuthUi.page(this);
        anchor = col;

        col.addView(AuthUi.image(this, "otp_verify", 150), Kit.lp(this, -2, Kit.dp(this, 150), 0, 24, 0, 0));
        col.addView(AuthUi.title(this, "Verify Your Email"), Kit.lp(this, -2, -2, 0, 28, 0, 0));

        String lead = "We've sent a 6-digit verification code to\n";
        SpannableString s = new SpannableString(lead + email);
        s.setSpan(new StyleSpan(android.graphics.Typeface.BOLD), lead.length(), s.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        s.setSpan(new ForegroundColorSpan(LIME), lead.length(), s.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        TextView sub = AuthUi.subtitle(this, "");
        sub.setText(s);
        col.addView(sub, Kit.lp(this, -2, -2, 0, 10, 0, 0));

        LinearLayout row = new LinearLayout(this);
        for (int i = 0; i < 6; i++) {
            EditText et = new EditText(this);
            boxes[i] = et;
            et.setInputType(InputType.TYPE_CLASS_NUMBER);
            et.setFilters(new InputFilter[]{new InputFilter.LengthFilter(1)});
            et.setGravity(Gravity.CENTER);
            et.setTextSize(22);
            et.setTextColor(0xFFFFFFFF);
            UiUtil.weight(et, 800);
            et.setSingleLine();
            et.setPadding(0, Kit.dp(this, 10), 0, Kit.dp(this, 10));
            et.setBackground(box(false));
            final int idx = i;
            et.setOnFocusChangeListener((v, focus) -> v.setBackground(box(focus)));
            et.addTextChangedListener(new TextWatcher() {
                @Override public void beforeTextChanged(CharSequence a, int b, int c, int d) {}
                @Override public void onTextChanged(CharSequence a, int b, int c, int d) {}
                @Override public void afterTextChanged(Editable e) {
                    if (e.length() > 0) {
                        if (idx < 5) boxes[idx + 1].requestFocus(); else boxes[idx].clearFocus();
                    } else if (idx > 0) {
                        boxes[idx - 1].requestFocus();
                    }
                }
            });
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(Kit.dp(this, 48), Kit.dp(this, 54));
            row.addView(et, lp);
            if (i < 5) row.addView(new View(this), new LinearLayout.LayoutParams(0, 1, 1f));
        }
        col.addView(row, Kit.lp(this, -1, -2, 0, 36, 0, 0));

        LinearLayout timer = new LinearLayout(this);
        timer.setGravity(Gravity.CENTER);
        timer.addView(Kit.text(this, "Resend code in ", 14, 400, 0x99FFFFFF));
        timerText = Kit.text(this, "", 14, 700, LIME);
        timer.addView(timerText);
        col.addView(timer, Kit.lp(this, -2, -2, 0, 28, 0, 0));

        button = new AuthUi.LoadingButton(this, "Verify & Continue", v -> verify());
        col.addView(button.view, Kit.lp(this, -1, Kit.dp(this, 52), 0, 32, 0, 0));

        LinearLayout foot = new LinearLayout(this);
        foot.setGravity(Gravity.CENTER);
        foot.addView(Kit.text(this, "Didn't receive the code? ", 14, 400, 0x99FFFFFF));
        resend = Kit.text(this, "Resend Code", 14, 700, 0x61FFFFFF);
        resend.setOnClickListener(v -> resendCode());
        foot.addView(resend);
        col.addView(foot, Kit.lp(this, -2, -2, 0, 28, 0, 16));

        render();
        handler.postDelayed(tick, 1000);
    }

    private GradientDrawable box(boolean focused) {
        GradientDrawable g = new GradientDrawable();
        g.setColor(0xFF1B1B1E);
        g.setCornerRadius(Kit.dp(this, 14));
        g.setStroke(Math.max(1, Kit.dp(this, focused ? 1.8f : 1f)), focused ? LIME : 0x1FFFFFFF);
        return g;
    }

    private void render() {
        timerText.setText(String.format(Locale.US, "%02d:%02d", seconds / 60, seconds % 60));
        resend.setTextColor(seconds > 0 ? 0x61FFFFFF : LIME);
    }

    private String code() {
        StringBuilder sb = new StringBuilder();
        for (EditText e : boxes) sb.append(e.getText().toString().trim());
        return sb.toString();
    }

    private void verify() {
        String code = code();
        if (code.length() < 6) { AuthUi.error(anchor, "Please enter all 6 digits of the OTP code"); return; }
        AuthUi.hideKeyboard(this);
        button.setLoading(true);
        JsonObject body = new JsonObject();
        body.addProperty("email", email);
        body.addProperty("otp", code);
        ApiClient.get().post(ApiConstants.OTP_VERIFY, body, r -> {
            if (isFinishing() || isDestroyed()) return;
            button.setLoading(false);
            if (r.isOk()) {
                String token = null;
                if (r.data != null && r.data.isJsonObject()) {
                    JsonObject d = r.data.getAsJsonObject();
                    token = UiUtil.str(d, "resetToken");
                    if (token == null && d.has("data") && d.get("data").isJsonObject()) token = UiUtil.str(d.getAsJsonObject("data"), "resetToken");
                }
                if (token != null && !token.isEmpty()) {
                    for (EditText e : boxes) e.setText("");
                    android.widget.Toast.makeText(this, "OTP verified successfully!", android.widget.Toast.LENGTH_SHORT).show();
                    Intent i = new Intent(this, ResetPasswordActivity.class);
                    i.putExtra(ResetPasswordActivity.EXTRA_TOKEN, token);
                    i.putExtra(ResetPasswordActivity.EXTRA_EMAIL, email);
                    startActivity(i);
                    finish(); // pushReplacement
                } else {
                    AuthUi.error(anchor, "Invalid verification token");
                }
            } else {
                AuthUi.error(anchor, r.message != null ? r.message : "Invalid OTP code");
            }
        });
    }

    private void resendCode() {
        if (seconds > 0 || resending) return;
        resending = true;
        JsonObject body = new JsonObject();
        body.addProperty("email", email);
        ApiClient.get().post(ApiConstants.RESEND_OTP, body, r -> {
            if (isFinishing() || isDestroyed()) return;
            resending = false;
            if (r.isOk()) {
                seconds = 600;
                render();
                handler.removeCallbacks(tick);
                handler.postDelayed(tick, 1000);
                AuthUi.success(anchor, "A fresh OTP code has been sent to " + email);
            } else {
                AuthUi.error(anchor, r.message != null ? r.message : "Failed to resend code");
            }
        });
    }

    @Override
    protected void onDestroy() {
        handler.removeCallbacksAndMessages(null);
        super.onDestroy();
    }
}
