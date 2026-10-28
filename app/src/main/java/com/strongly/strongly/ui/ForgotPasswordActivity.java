package com.strongly.strongly.ui;

import android.content.Intent;
import android.os.Bundle;
import android.text.InputType;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.google.gson.JsonObject;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.net.ApiConstants;

import java.util.regex.Pattern;

public class ForgotPasswordActivity extends AppCompatActivity {
    private static final Pattern EMAIL = Pattern.compile("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$");
    private final EditText[] email = new EditText[1];
    private AuthUi.LoadingButton button;
    private View anchor;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        LinearLayout col = AuthUi.page(this);
        anchor = col;

        col.addView(AuthUi.image(this, "forgot_password", 160), Kit.lp(this, -2, Kit.dp(this, 160), 0, 24, 0, 0));
        col.addView(AuthUi.title(this, "Forgot Password?"), Kit.lp(this, -2, -2, 0, 28, 0, 0));
        TextView sub = AuthUi.subtitle(this, "No worries! Enter your registered email address and we’ll send you a verification code to reset your password.");
        col.addView(sub, Kit.lp(this, -1, -2, 10, 12, 10, 0));
        col.addView(AuthUi.pillInput(this, "Enter your email", Icons.MAIL_OUTLINE_ROUNDED,
                InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS, false, email), Kit.lp(this, -1, -2, 0, 36, 0, 0));
        button = new AuthUi.LoadingButton(this, "Send Verification Code", v -> send());
        col.addView(button.view, Kit.lp(this, -1, Kit.dp(this, 52), 0, 28, 0, 0));
        col.addView(AuthUi.footer(this, "Remember your password? ", "Sign In", v -> {
            startActivity(new Intent(this, LoginActivity.class));
            finish();
        }), Kit.lp(this, -2, -2, 0, 36, 0, 16));
    }

    private void send() {
        String em = email[0].getText().toString().trim();
        if (em.isEmpty()) { AuthUi.error(anchor, "Please enter your email address"); return; }
        if (!EMAIL.matcher(em).matches()) { AuthUi.error(anchor, "Please enter a valid email address"); return; }
        AuthUi.hideKeyboard(this);
        button.setLoading(true);
        JsonObject body = new JsonObject();
        body.addProperty("email", em);
        ApiClient.get().post(ApiConstants.FORGOT_PASSWORD, body, r -> {
            if (isFinishing() || isDestroyed()) return;
            button.setLoading(false);
            if (r.isOk()) {
                email[0].setText("");
                android.widget.Toast.makeText(this, "Verification code sent to your email!", android.widget.Toast.LENGTH_SHORT).show();
                Intent i = new Intent(this, OtpActivity.class);
                i.putExtra(OtpActivity.EXTRA_EMAIL, em);
                startActivity(i);
            } else {
                AuthUi.error(anchor, r.message != null ? r.message : "Failed to send verification code");
            }
        });
    }
}
