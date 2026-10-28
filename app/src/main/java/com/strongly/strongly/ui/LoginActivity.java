package com.strongly.strongly.ui;

import android.content.Intent;
import android.os.Bundle;
import android.text.InputType;
import android.view.Gravity;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;

import androidx.appcompat.app.AppCompatActivity;

import com.google.gson.JsonObject;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.net.ApiConstants;
import com.strongly.strongly.util.Session;

public class LoginActivity extends AppCompatActivity {
    private final EditText[] email = new EditText[1], password = new EditText[1];
    private AuthUi.LoadingButton button;
    private View anchor;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        LinearLayout col = AuthUi.page(this);
        anchor = col;

        col.addView(AuthUi.brandHeader(this), Kit.lp(this, -2, -2, 0, 24, 0, 0));
        col.addView(AuthUi.title(this, "Welcome Back!"), Kit.lp(this, -2, -2, 0, 44, 0, 0));
        col.addView(AuthUi.subtitle(this, "Log in to continue to Strongly"), Kit.lp(this, -2, -2, 0, 6, 0, 0));
        col.addView(AuthUi.pillInput(this, "Enter your email", Icons.MAIL_OUTLINE_ROUNDED,
                InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS, false, email), Kit.lp(this, -1, -2, 0, 32, 0, 0));
        col.addView(AuthUi.pillInput(this, "Enter your password", Icons.LOCK_OUTLINE_ROUNDED, 0, true, password), Kit.lp(this, -1, -2, 0, 16, 0, 0));

        android.widget.TextView forgot = Kit.text(this, "Forgot Password", 13, 600, 0xB3FFFFFF);
        forgot.setOnClickListener(v -> startActivity(new Intent(this, ForgotPasswordActivity.class)));
        LinearLayout.LayoutParams fp = Kit.lp(this, -2, -2, 0, 12, 0, 0);
        fp.gravity = Gravity.END;
        col.addView(forgot, fp);

        button = new AuthUi.LoadingButton(this, "Login", v -> login());
        col.addView(button.view, Kit.lp(this, -1, Kit.dp(this, 52), 0, 28, 0, 0));

        col.addView(AuthUi.footer(this, "Don't have an account? ", "Sign up", v -> {
            startActivity(new Intent(this, SignupActivity.class));
            finish();
        }), Kit.lp(this, -2, -2, 0, 28, 0, 16));
    }

    /** Re-entered after a password reset: Flutter shows a fresh, empty login screen. */
    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        email[0].setText("");
        password[0].setText("");
        button.setLoading(false);
    }

    private void login() {
        String em = email[0].getText().toString().trim();
        String pw = password[0].getText().toString();
        if (em.isEmpty() || pw.isEmpty()) { AuthUi.error(anchor, "Please fill in all fields"); return; }
        AuthUi.hideKeyboard(this);
        button.setLoading(true);

        JsonObject body = new JsonObject();
        body.addProperty("email", em);
        body.addProperty("password", pw);
        ApiClient.get().post(ApiConstants.LOGIN, body, r -> {
            if (isFinishing() || isDestroyed()) return;
            button.setLoading(false);
            if (r.isOk() && r.data != null && r.data.isJsonObject()) {
                JsonObject d = r.data.getAsJsonObject();
                JsonObject inner = d.has("data") && d.get("data").isJsonObject() ? d.getAsJsonObject("data") : d;
                String token = UiUtil.str(inner, "token");
                JsonObject user = inner.has("user") && inner.get("user").isJsonObject() ? inner.getAsJsonObject("user") : null;
                if (token != null && !token.isEmpty()) {
                    String name = user != null ? UiUtil.str(user, "name") : null;
                    String userEmail = user != null ? UiUtil.str(user, "email") : em;
                    Session.save(token, user != null && UiUtil.str(user, "_id") != null ? UiUtil.str(user, "_id") : "",
                            false, name, userEmail, null);
                    android.widget.Toast.makeText(this, "Welcome back, " + (name != null ? name : "Athlete") + "!",
                            android.widget.Toast.LENGTH_SHORT).show();
                    Intent home = new Intent(this, HomeActivity.class);
                    home.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                    startActivity(home);
                } else {
                    String m = UiUtil.str(d, "message");
                    AuthUi.error(anchor, m != null ? m : "Login failed. Please try again.");
                }
            } else {
                AuthUi.error(anchor, r.message != null ? r.message : "Invalid email or password");
            }
        });
    }
}
