package com.strongly.strongly.ui;

import android.content.Intent;
import android.os.Bundle;
import android.widget.EditText;
import android.widget.LinearLayout;

import androidx.appcompat.app.AppCompatActivity;

import com.google.gson.JsonObject;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.net.ApiConstants;

public class ResetPasswordActivity extends AppCompatActivity {
    public static final String EXTRA_TOKEN = "resetToken", EXTRA_EMAIL = "email";
    private final EditText[] password = new EditText[1], confirm = new EditText[1];
    private AuthUi.LoadingButton button;
    private String token;
    private android.view.View anchor;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        token = getIntent().getStringExtra(EXTRA_TOKEN);
        LinearLayout col = AuthUi.page(this);
        anchor = col;

        col.addView(AuthUi.image(this, "reset_password", 150), Kit.lp(this, -2, Kit.dp(this, 150), 0, 24, 0, 0));
        col.addView(AuthUi.title(this, "Create New Password"), Kit.lp(this, -2, -2, 0, 28, 0, 0));
        col.addView(AuthUi.subtitle(this, "Your new password must be unique from those previously used."), Kit.lp(this, -2, -2, 0, 10, 0, 0));
        col.addView(AuthUi.pillInput(this, "Enter new password", Icons.LOCK_OUTLINE_ROUNDED, 0, true, password), Kit.lp(this, -1, -2, 0, 32, 0, 0));
        col.addView(AuthUi.pillInput(this, "Confirm new password", Icons.LOCK_OUTLINE_ROUNDED, 0, true, confirm), Kit.lp(this, -1, -2, 0, 16, 0, 0));
        button = new AuthUi.LoadingButton(this, "Reset Password", v -> reset());
        col.addView(button.view, Kit.lp(this, -1, Kit.dp(this, 52), 0, 32, 0, 0));
        col.addView(AuthUi.footer(this, "Remember your password? ", "Sign In", v -> backToLogin()), Kit.lp(this, -2, -2, 0, 36, 0, 16));
    }

    /** Flutter's pushAndRemoveUntil(Login, route.isFirst): drop the reset flow, land on a fresh Login. */
    private void backToLogin() {
        Intent i = new Intent(this, LoginActivity.class);
        i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        startActivity(i);
        finish();
    }

    private void reset() {
        String pw = password[0].getText().toString(), cf = confirm[0].getText().toString();
        if (pw.isEmpty() || cf.isEmpty()) { AuthUi.error(anchor, "Please fill in both password fields"); return; }
        if (!pw.equals(cf)) { AuthUi.error(anchor, "Passwords do not match"); return; }
        if (pw.length() < 6) { AuthUi.error(anchor, "Password must be at least 6 characters"); return; }
        AuthUi.hideKeyboard(this);
        button.setLoading(true);
        JsonObject body = new JsonObject();
        body.addProperty("resetToken", token);
        body.addProperty("newPassword", pw);
        ApiClient.get().post(ApiConstants.RESET_PASSWORD, body, r -> {
            if (isFinishing() || isDestroyed()) return;
            button.setLoading(false);
            if (r.isOk()) {
                android.widget.Toast.makeText(this, "Password reset successfully! Please log in with your new password.",
                        android.widget.Toast.LENGTH_LONG).show();
                backToLogin();
            } else {
                AuthUi.error(anchor, r.message != null ? r.message : "Password reset failed");
            }
        });
    }
}
