package com.strongly.strongly.ui;

import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.text.InputType;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
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
import com.strongly.strongly.util.Session;

public class SignupActivity extends AppCompatActivity {
    private final EditText[] name = new EditText[1], email = new EditText[1], password = new EditText[1], confirm = new EditText[1];
    private AuthUi.LoadingButton button;
    private TextView check;
    private boolean agree = false;
    private View anchor;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        LinearLayout col = AuthUi.page(this);
        anchor = col;

        col.addView(AuthUi.brandHeader(this), Kit.lp(this, -2, -2, 0, 24, 0, 0));
        col.addView(AuthUi.title(this, "Create Account"), Kit.lp(this, -2, -2, 0, 36, 0, 0));
        col.addView(AuthUi.subtitle(this, "Sign up to get started with your dashboard"), Kit.lp(this, -2, -2, 0, 6, 0, 0));
        col.addView(AuthUi.pillInput(this, "Full name", Icons.PERSON_OUTLINE_ROUNDED, InputType.TYPE_CLASS_TEXT
                | InputType.TYPE_TEXT_FLAG_CAP_WORDS, false, name), Kit.lp(this, -1, -2, 0, 28, 0, 0));
        col.addView(AuthUi.pillInput(this, "Enter your email", Icons.MAIL_OUTLINE_ROUNDED,
                InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS, false, email), Kit.lp(this, -1, -2, 0, 14, 0, 0));
        col.addView(AuthUi.pillInput(this, "Enter your password", Icons.LOCK_OUTLINE_ROUNDED, 0, true, password), Kit.lp(this, -1, -2, 0, 14, 0, 0));
        col.addView(AuthUi.pillInput(this, "Confirm password", Icons.LOCK_OUTLINE_ROUNDED, 0, true, confirm), Kit.lp(this, -1, -2, 0, 14, 0, 0));

        // terms checkbox row
        LinearLayout terms = new LinearLayout(this);
        terms.setGravity(Gravity.CENTER_VERTICAL);
        check = Icons.view(this, Icons.CHECK_PLAIN, 14, 0xFF000000);
        terms.addView(check, new LinearLayout.LayoutParams(Kit.dp(this, 22), Kit.dp(this, 22)));
        TextView text = new TextView(this);
        text.setTextSize(13);
        text.setTextColor(0xB3FFFFFF);
        UiUtil.weight(text, 400);
        text.setText(buildTermsText());
        text.setMovementMethod(LinkMovementMethod.getInstance());
        text.setHighlightColor(0x00000000);
        terms.addView(text, Kit.lp(this, 0, -2, 10, 0, 0, 0));
        ((LinearLayout.LayoutParams) text.getLayoutParams()).weight = 1f;
        terms.setOnClickListener(v -> { agree = !agree; renderCheck(); });
        col.addView(terms, Kit.lp(this, -1, -2, 0, 18, 0, 0));
        renderCheck();

        button = new AuthUi.LoadingButton(this, "Create Account", v -> signup());
        col.addView(button.view, Kit.lp(this, -1, Kit.dp(this, 52), 0, 28, 0, 0));

        col.addView(AuthUi.footer(this, "Already have an account? ", "Log In", v -> {
            startActivity(new Intent(this, LoginActivity.class));
            finish();
        }), Kit.lp(this, -2, -2, 0, 32, 0, 16));
    }

    private CharSequence buildTermsText() {
        String a = "I agree to the ", b = "Terms of Service", c = " and ", d = "Privacy Policy";
        SpannableString s = new SpannableString(a + b + c + d);
        int bs = a.length(), be = bs + b.length(), ds = be + c.length(), de = ds + d.length();
        s.setSpan(link("https://strongly.greewebsolutions.com/terms"), bs, be, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        s.setSpan(link("https://strongly.greewebsolutions.com/privacy"), ds, de, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        for (int[] r : new int[][]{{bs, be}, {ds, de}}) {
            s.setSpan(new StyleSpan(android.graphics.Typeface.BOLD), r[0], r[1], Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            s.setSpan(new ForegroundColorSpan(0xFFFFFFFF), r[0], r[1], Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        }
        return s;
    }

    private ClickableSpan link(String url) {
        return new ClickableSpan() {
            @Override public void onClick(View v) {
                try { startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url))); } catch (Exception ignored) { }
            }

            @Override public void updateDrawState(android.text.TextPaint ds) { ds.setUnderlineText(false); }
        };
    }

    private void renderCheck() {
        GradientDrawable g = new GradientDrawable();
        g.setShape(GradientDrawable.OVAL);
        g.setColor(agree ? 0xFFFFFFFF : 0x00000000);
        g.setStroke(Math.max(1, Kit.dp(this, 1.5f)), agree ? 0xFFFFFFFF : 0x61FFFFFF);
        check.setBackground(g);
        check.setVisibility(View.VISIBLE);
        check.setTextColor(agree ? 0xFF000000 : 0x00000000);
    }

    private void signup() {
        String n = name[0].getText().toString().trim(), em = email[0].getText().toString().trim();
        String pw = password[0].getText().toString(), cf = confirm[0].getText().toString();
        if (n.isEmpty() || em.isEmpty() || pw.isEmpty() || cf.isEmpty()) { AuthUi.error(anchor, "Please fill in all fields"); return; }
        if (!pw.equals(cf)) { AuthUi.error(anchor, "Passwords do not match"); return; }
        if (pw.length() < 6) { AuthUi.error(anchor, "Password must be at least 6 characters"); return; }
        if (!agree) { AuthUi.error(anchor, "Please agree to the Terms of Service & Privacy Policy"); return; }
        AuthUi.hideKeyboard(this);
        button.setLoading(true);

        JsonObject body = new JsonObject();
        body.addProperty("name", n);
        body.addProperty("email", em);
        body.addProperty("password", pw);
        // a guest session becomes the real user under the same _id
        String uid = Session.userId();
        if (Session.isGuest() && uid != null && !uid.isEmpty()) body.addProperty("guestId", uid);

        ApiClient.get().post(ApiConstants.SIGNUP, body, r -> {
            if (isFinishing() || isDestroyed()) return;
            button.setLoading(false);
            if (r.isOk() && r.data != null && r.data.isJsonObject()) {
                JsonObject d = r.data.getAsJsonObject();
                JsonObject inner = d.has("data") && d.get("data").isJsonObject() ? d.getAsJsonObject("data") : d;
                String token = UiUtil.str(inner, "token");
                JsonObject user = inner.has("user") && inner.get("user").isJsonObject() ? inner.getAsJsonObject("user") : null;
                if (token != null && !token.isEmpty()) {
                    Session.save(token, user != null && UiUtil.str(user, "_id") != null ? UiUtil.str(user, "_id") : "", false, n, em, null);
                    android.widget.Toast.makeText(this, "Account created successfully! Welcome, " + n,
                            android.widget.Toast.LENGTH_SHORT).show();
                    Intent home = new Intent(this, HomeActivity.class);
                    home.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                    startActivity(home);
                } else {
                    String m = UiUtil.str(d, "message");
                    AuthUi.error(anchor, m != null ? m : "Registration failed. Please try again.");
                }
            } else {
                AuthUi.error(anchor, r.message != null ? r.message : "Failed to create account");
            }
        });
    }
}
