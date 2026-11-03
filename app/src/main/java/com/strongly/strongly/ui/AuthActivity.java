package com.strongly.strongly.ui;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.text.InputType;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.method.PasswordTransformationMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.text.style.StyleSpan;
import android.view.Gravity;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.res.ResourcesCompat;

import com.google.gson.JsonObject;
import com.strongly.strongly.R;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.net.ApiConstants;
import com.strongly.strongly.util.Session;

/**
 * Modern all-in-one Auth screen inspired by SlimTrack:
 * Segmented Tab ("Log In" / "Create Account"), full validation,
 * eye-toggle passwords, error banners, and live API integration.
 */
public class AuthActivity extends AppCompatActivity {
    public static final String EXTRA_INITIAL_IS_LOGIN = "extra_is_login";
    private static final int LIME = 0xFFA3D223;
    private static final int BG_DARK = 0xFF0A0D12;
    private static final int CARD_BG = 0xFF161619;
    private static final int CARD_BORDER = 0x1AFFFFFF;

    private boolean isLogin = true;
    private boolean obscurePassword = true;
    private boolean obscureConfirm = true;
    private boolean agreeTerms = false;
    private boolean isLoading = false;

    private TextView tabLogin;
    private TextView tabSignup;
    private LinearLayout nameGroup;
    private LinearLayout confirmGroup;
    private LinearLayout termsGroup;
    private LinearLayout forgotGroup;
    private LinearLayout errorBox;
    private TextView errorText;
    private TextView actionBtnText;
    private ProgressBar actionProgress;
    private TextView termsCheck;

    private Field nameField;
    private Field emailField;
    private Field passwordField;
    private Field confirmField;
    private TextView eyePass;
    private TextView eyeConfirm;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (getIntent() != null) {
            isLogin = getIntent().getBooleanExtra(EXTRA_INITIAL_IS_LOGIN, true);
        }

        FrameLayout root = new FrameLayout(this);
        root.setBackgroundColor(BG_DARK);

        ScrollView scroll = new ScrollView(this);
        scroll.setVerticalScrollBarEnabled(false);
        scroll.setFillViewport(true);

        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        col.setPadding(dp(24), dp(16), dp(24), dp(32));
        scroll.addView(col, new FrameLayout.LayoutParams(-1, -2));
        root.addView(scroll, new FrameLayout.LayoutParams(-1, -1));

        // Top Bar (Close/Back)
        LinearLayout topBar = new LinearLayout(this);
        topBar.setGravity(Gravity.CENTER_VERTICAL);
        TextView back = Icons.view(this, Icons.CLOSE_ROUNDED, 20, 0xFFFFFFFF);
        back.setGravity(Gravity.CENTER);
        back.setBackground(Kit.rounded(this, 0x1FFFFFFF, 12));
        back.setOnClickListener(v -> finish());
        topBar.addView(back, new LinearLayout.LayoutParams(dp(38), dp(38)));
        col.addView(topBar);

        // Logo
        LinearLayout logoBox = new LinearLayout(this);
        logoBox.setOrientation(LinearLayout.VERTICAL);
        logoBox.setGravity(Gravity.CENTER_HORIZONTAL);
        logoBox.setPadding(0, dp(12), 0, dp(24));

        TextView logoIcon = Icons.view(this, Icons.DIRECTIONS_RUN_ROUNDED, 36, 0xFF000000);
        logoIcon.setGravity(Gravity.CENTER);
        logoIcon.setBackground(Kit.rounded(this, LIME, 16));
        logoBox.addView(logoIcon, new LinearLayout.LayoutParams(dp(54), dp(54)));

        TextView logoText = new TextView(this);
        logoText.setText("STRONGLY");
        logoText.setTypeface(ResourcesCompat.getFont(this, R.font.lozange_no_commercial));
        logoText.setTextColor(LIME);
        logoText.setTextSize(26);
        logoText.setLetterSpacing(-0.04f);
        logoBox.addView(logoText, lp(-2, -2, 0, 8, 0, 0));

        col.addView(logoBox);

        // Segmented Tab (SlimTrack style)
        col.addView(buildSegmentedTab(), lp(-1, dp(48), 0, 0, 0, 20));

        // Error Box
        errorBox = new LinearLayout(this);
        errorBox.setOrientation(LinearLayout.HORIZONTAL);
        errorBox.setGravity(Gravity.CENTER_VERTICAL);
        errorBox.setBackground(Kit.rounded(this, 0x24FF5252, 12, 1, 0x59FF5252));
        errorBox.setPadding(dp(14), dp(10), dp(14), dp(10));
        TextView errIcon = Icons.view(this, Icons.CLEAR_ROUNDED, 16, 0xFFFF5252);
        errorBox.addView(errIcon);
        errorText = text("", 13, 600, 0xFFFF8A80);
        errorText.setPadding(dp(10), 0, 0, 0);
        errorBox.addView(errorText, new LinearLayout.LayoutParams(0, -2, 1f));
        errorBox.setVisibility(View.GONE);
        col.addView(errorBox, lp(-1, -2, 0, 0, 0, 16));

        // Name Group
        nameGroup = new LinearLayout(this);
        nameGroup.setOrientation(LinearLayout.VERTICAL);
        nameGroup.addView(fieldLabel("YOUR NAME"));
        nameField = new Field(this, "e.g. Alex Morgan", Icons.PERSON_OUTLINE_ROUNDED,
                InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_CAP_WORDS);
        nameGroup.addView(nameField, lp(-1, -2, 0, 6, 0, 14));
        col.addView(nameGroup);

        // Email Group
        col.addView(fieldLabel("EMAIL ADDRESS"));
        emailField = new Field(this, "name@example.com", Icons.MAIL_OUTLINE_ROUNDED,
                InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
        col.addView(emailField, lp(-1, -2, 0, 6, 0, 14));

        // Password Group
        col.addView(fieldLabel("PASSWORD"));
        passwordField = new Field(this, "At least 6 characters", Icons.LOCK_OUTLINE_ROUNDED,
                InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        eyePass = Icons.view(this, Icons.VISIBILITY_OFF_OUTLINED, 18, 0x8AFFFFFF);
        eyePass.setGravity(Gravity.CENTER);
        eyePass.setOnClickListener(v -> {
            obscurePassword = !obscurePassword;
            updatePasswordVisibility();
        });
        passwordField.setSuffix(eyePass);
        col.addView(passwordField, lp(-1, -2, 0, 6, 0, 14));

        // Confirm Password Group
        confirmGroup = new LinearLayout(this);
        confirmGroup.setOrientation(LinearLayout.VERTICAL);
        confirmGroup.addView(fieldLabel("CONFIRM PASSWORD"));
        confirmField = new Field(this, "Re-enter your password", Icons.LOCK_OUTLINE_ROUNDED,
                InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        eyeConfirm = Icons.view(this, Icons.VISIBILITY_OFF_OUTLINED, 18, 0x8AFFFFFF);
        eyeConfirm.setGravity(Gravity.CENTER);
        eyeConfirm.setOnClickListener(v -> {
            obscureConfirm = !obscureConfirm;
            updateConfirmVisibility();
        });
        confirmField.setSuffix(eyeConfirm);
        confirmGroup.addView(confirmField, lp(-1, -2, 0, 6, 0, 14));
        col.addView(confirmGroup);

        // Forgot Password (Login mode)
        forgotGroup = new LinearLayout(this);
        forgotGroup.setGravity(Gravity.END);
        TextView forgot = text("Forgot Password?", 13, 600, LIME);
        forgot.setOnClickListener(v -> startActivity(new Intent(this, ForgotPasswordActivity.class)));
        forgotGroup.addView(forgot);
        col.addView(forgotGroup, lp(-1, -2, 0, 0, 0, 18));

        // Terms Checkbox (Signup mode)
        termsGroup = new LinearLayout(this);
        termsGroup.setGravity(Gravity.CENTER_VERTICAL);
        termsCheck = Icons.view(this, Icons.CHECK_PLAIN, 12, 0xFF000000);
        updateTermsCheckbox();
        termsGroup.addView(termsCheck, new LinearLayout.LayoutParams(dp(22), dp(22)));

        TextView termsTv = new TextView(this);
        termsTv.setTextSize(12.5f);
        termsTv.setTextColor(0xB3FFFFFF);
        termsTv.setText(buildTermsSpan());
        termsTv.setMovementMethod(LinkMovementMethod.getInstance());
        termsTv.setHighlightColor(0x00000000);
        termsTv.setPadding(dp(10), 0, 0, 0);
        termsGroup.addView(termsTv, new LinearLayout.LayoutParams(0, -2, 1f));

        termsGroup.setOnClickListener(v -> {
            agreeTerms = !agreeTerms;
            updateTermsCheckbox();
        });
        col.addView(termsGroup, lp(-1, -2, 0, 0, 0, 20));

        // Primary Action Button
        col.addView(buildActionButton(), lp(-1, dp(52), 0, 8, 0, 18));

        setContentView(root);
        applyMode();
    }

    private View buildSegmentedTab() {
        LinearLayout bar = new LinearLayout(this);
        bar.setOrientation(LinearLayout.HORIZONTAL);
        bar.setBackground(Kit.rounded(this, 0xFF141417, 24, 1, 0x1AFFFFFF));
        bar.setPadding(dp(4), dp(4), dp(4), dp(4));

        tabLogin = text("Log In", 14, 700, 0xFF000000);
        tabLogin.setGravity(Gravity.CENTER);
        tabLogin.setOnClickListener(v -> setMode(true));

        tabSignup = text("Create Account", 14, 700, 0x8AFFFFFF);
        tabSignup.setGravity(Gravity.CENTER);
        tabSignup.setOnClickListener(v -> setMode(false));

        bar.addView(tabLogin, new LinearLayout.LayoutParams(0, -1, 1f));
        bar.addView(tabSignup, new LinearLayout.LayoutParams(0, -1, 1f));
        return bar;
    }

    private void setMode(boolean login) {
        if (isLogin == login) return;
        isLogin = login;
        hideError();
        applyMode();
    }

    private void applyMode() {
        if (isLogin) {
            tabLogin.setBackground(Kit.rounded(this, LIME, 20));
            tabLogin.setTextColor(0xFF000000);
            tabSignup.setBackground(null);
            tabSignup.setTextColor(0x8AFFFFFF);

            nameGroup.setVisibility(View.GONE);
            confirmGroup.setVisibility(View.GONE);
            termsGroup.setVisibility(View.GONE);
            forgotGroup.setVisibility(View.VISIBLE);
            actionBtnText.setText("Log In");
        } else {
            tabSignup.setBackground(Kit.rounded(this, LIME, 20));
            tabSignup.setTextColor(0xFF000000);
            tabLogin.setBackground(null);
            tabLogin.setTextColor(0x8AFFFFFF);

            nameGroup.setVisibility(View.VISIBLE);
            confirmGroup.setVisibility(View.VISIBLE);
            termsGroup.setVisibility(View.VISIBLE);
            forgotGroup.setVisibility(View.GONE);
            actionBtnText.setText("Create Account");
        }
    }

    private View fieldLabel(String label) {
        TextView t = text(label, 11, 700, 0x8AFFFFFF);
        t.setLetterSpacing(0.06f);
        return t;
    }

    private View buildActionButton() {
        FrameLayout btn = new FrameLayout(this);
        btn.setBackground(Kit.rounded(this, LIME, 24));

        actionBtnText = text("Log In", 15, 800, 0xFF000000);
        actionBtnText.setGravity(Gravity.CENTER);
        btn.addView(actionBtnText, new FrameLayout.LayoutParams(-1, -1, Gravity.CENTER));

        actionProgress = new ProgressBar(this);
        actionProgress.setIndeterminateTintList(android.content.res.ColorStateList.valueOf(0xFF000000));
        actionProgress.setVisibility(View.GONE);
        btn.addView(actionProgress, new FrameLayout.LayoutParams(dp(24), dp(24), Gravity.CENTER));

        btn.setOnClickListener(v -> submit());
        return btn;
    }

    private void updatePasswordVisibility() {
        EditText et = passwordField.edit;
        int sel = et.getSelectionEnd();
        et.setTransformationMethod(obscurePassword ? PasswordTransformationMethod.getInstance() : null);
        if (sel >= 0) et.setSelection(Math.min(sel, et.length()));
        eyePass.setText(new String(Character.toChars(obscurePassword ? Icons.VISIBILITY_OFF_OUTLINED : Icons.VISIBILITY_OUTLINED)));
    }

    private void updateConfirmVisibility() {
        EditText et = confirmField.edit;
        int sel = et.getSelectionEnd();
        et.setTransformationMethod(obscureConfirm ? PasswordTransformationMethod.getInstance() : null);
        if (sel >= 0) et.setSelection(Math.min(sel, et.length()));
        eyeConfirm.setText(new String(Character.toChars(obscureConfirm ? Icons.VISIBILITY_OFF_OUTLINED : Icons.VISIBILITY_OUTLINED)));
    }

    private void updateTermsCheckbox() {
        GradientDrawable g = new GradientDrawable();
        g.setShape(GradientDrawable.OVAL);
        g.setColor(agreeTerms ? LIME : 0x00000000);
        g.setStroke(dp(1.5f), agreeTerms ? LIME : 0x61FFFFFF);
        termsCheck.setBackground(g);
        termsCheck.setTextColor(agreeTerms ? 0xFF000000 : 0x00000000);
    }

    private CharSequence buildTermsSpan() {
        String a = "I agree to Strongly's ", b = "Terms of Service", c = " and ", d = "Privacy Policy";
        SpannableString ss = new SpannableString(a + b + c + d);
        int bs = a.length(), be = bs + b.length(), ds = be + c.length(), de = ds + d.length();

        ss.setSpan(new ClickableSpan() {
            @Override public void onClick(View v) {
                startActivity(new Intent(AuthActivity.this, TermsConditionsActivity.class));
            }
        }, bs, be, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        ss.setSpan(new ForegroundColorSpan(LIME), bs, be, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        ss.setSpan(new StyleSpan(android.graphics.Typeface.BOLD), bs, be, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

        ss.setSpan(new ClickableSpan() {
            @Override public void onClick(View v) {
                startActivity(new Intent(AuthActivity.this, PrivacyPolicyActivity.class));
            }
        }, ds, de, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        ss.setSpan(new ForegroundColorSpan(LIME), ds, de, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        ss.setSpan(new StyleSpan(android.graphics.Typeface.BOLD), ds, de, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

        return ss;
    }

    private void showError(String msg) {
        errorText.setText(msg);
        errorBox.setVisibility(View.VISIBLE);
    }

    private void hideError() {
        errorBox.setVisibility(View.GONE);
    }

    private void setLoading(boolean loading) {
        isLoading = loading;
        actionBtnText.setVisibility(loading ? View.INVISIBLE : View.VISIBLE);
        actionProgress.setVisibility(loading ? View.VISIBLE : View.GONE);
    }

    private void hideKeyboard() {
        View v = getCurrentFocus();
        if (v != null) {
            InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
            if (imm != null) imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
        }
    }

    private void submit() {
        if (isLoading) return;
        hideError();
        hideKeyboard();

        final String email = emailField.text().trim();
        final String password = passwordField.text();

        if (email.isEmpty()) {
            showError("Please enter your email address.");
            return;
        }
        if (!email.contains("@") || !email.contains(".")) {
            showError("Please enter a valid email address.");
            return;
        }
        if (password.isEmpty()) {
            showError("Please enter your password.");
            return;
        }

        if (isLogin) {
            doLogin(email, password);
        } else {
            final String name = nameField.text().trim();
            final String confirm = confirmField.text();

            if (name.isEmpty()) {
                showError("Please enter your full name.");
                return;
            }
            if (password.length() < 6) {
                showError("Password must be at least 6 characters.");
                return;
            }
            if (!password.equals(confirm)) {
                showError("Passwords do not match.");
                return;
            }
            if (!agreeTerms) {
                showError("Please accept the Terms of Service & Privacy Policy.");
                return;
            }
            doSignup(name, email, password);
        }
    }

    private void doLogin(String email, String password) {
        setLoading(true);
        JsonObject body = new JsonObject();
        body.addProperty("email", email);
        body.addProperty("password", password);

        ApiClient.get().post(ApiConstants.LOGIN, body, r -> {
            if (isFinishing() || isDestroyed()) return;
            setLoading(false);
            if (r.isOk() && r.data != null && r.data.isJsonObject()) {
                JsonObject d = r.data.getAsJsonObject();
                JsonObject inner = d.has("data") && d.get("data").isJsonObject() ? d.getAsJsonObject("data") : d;
                String token = UiUtil.str(inner, "token");
                JsonObject user = inner.has("user") && inner.get("user").isJsonObject() ? inner.getAsJsonObject("user") : null;

                if (token != null && !token.isEmpty()) {
                    String name = user != null ? UiUtil.str(user, "name") : "Athlete";
                    String userEmail = user != null ? UiUtil.str(user, "email") : email;
                    String uid = user != null ? UiUtil.str(user, "_id") : "";
                    String avatar = user != null ? UiUtil.str(user, "avatar") : null;

                    Session.save(token, uid != null ? uid : "", false, name, userEmail, avatar);
                    Toast.makeText(this, "Welcome back, " + name + "! 👋", Toast.LENGTH_SHORT).show();

                    setResult(RESULT_OK);
                    finish();
                } else {
                    String msg = UiUtil.str(d, "message");
                    showError(msg != null ? msg : "Login failed. Please check credentials.");
                }
            } else {
                showError(r.message != null ? r.message : "Invalid email or password.");
            }
        });
    }

    private void doSignup(String name, String email, String password) {
        setLoading(true);
        JsonObject body = new JsonObject();
        body.addProperty("name", name);
        body.addProperty("email", email);
        body.addProperty("password", password);
        body.addProperty("language", Session.language());

        String uid = Session.userId();
        if (Session.isGuest() && uid != null && !uid.isEmpty()) {
            body.addProperty("guestId", uid);
        }

        ApiClient.get().post(ApiConstants.SIGNUP, body, r -> {
            if (isFinishing() || isDestroyed()) return;
            setLoading(false);
            if (r.isOk() && r.data != null && r.data.isJsonObject()) {
                JsonObject d = r.data.getAsJsonObject();
                JsonObject inner = d.has("data") && d.get("data").isJsonObject() ? d.getAsJsonObject("data") : d;
                String token = UiUtil.str(inner, "token");
                JsonObject user = inner.has("user") && inner.get("user").isJsonObject() ? inner.getAsJsonObject("user") : null;

                if (token != null && !token.isEmpty()) {
                    String uidOut = user != null ? UiUtil.str(user, "_id") : "";
                    Session.save(token, uidOut != null ? uidOut : "", false, name, email, null);
                    Toast.makeText(this, "Account created successfully! Welcome, " + name + " 🎉", Toast.LENGTH_SHORT).show();

                    setResult(RESULT_OK);
                    finish();
                } else {
                    String msg = UiUtil.str(d, "message");
                    showError(msg != null ? msg : "Registration failed. Try a different email.");
                }
            } else {
                showError(r.message != null ? r.message : "Failed to create account.");
            }
        });
    }

    // SlimTrack style Field component
    public static class Field extends LinearLayout {
        public final EditText edit;
        private final FrameLayout box;

        public Field(Context c, String hint, int leadIcon, int inputType) {
            super(c);
            setOrientation(VERTICAL);

            box = new FrameLayout(c);
            box.setBackground(Kit.rounded(c, CARD_BG, 14, 1, CARD_BORDER));

            edit = new EditText(c);
            edit.setBackground(null);
            edit.setHint(hint);
            edit.setHintTextColor(0x3DFFFFFF);
            edit.setTextColor(0xFFFFFFFF);
            edit.setTextSize(14.5f);
            UiUtil.weight(edit, 500);
            edit.setInputType(inputType);
            edit.setSingleLine(true);
            edit.setMinimumHeight(Kit.dp(c, 48));

            int padStart = leadIcon != 0 ? Kit.dp(c, 48) : Kit.dp(c, 16);
            int padEnd = Kit.dp(c, 16);
            edit.setPaddingRelative(padStart, Kit.dp(c, 12), padEnd, Kit.dp(c, 12));

            edit.setOnFocusChangeListener((v, hasFocus) -> {
                box.setBackground(Kit.rounded(c, CARD_BG, 14, hasFocus ? 1.5f : 1, hasFocus ? LIME : CARD_BORDER));
            });

            box.addView(edit, new FrameLayout.LayoutParams(-1, -1));

            if (leadIcon != 0) {
                TextView ic = Icons.view(c, leadIcon, 18, LIME);
                ic.setGravity(Gravity.CENTER);
                box.addView(ic, new FrameLayout.LayoutParams(Kit.dp(c, 48), -1, Gravity.START | Gravity.CENTER_VERTICAL));
            }

            addView(box, new LayoutParams(-1, Kit.dp(c, 50)));
        }

        public void setSuffix(View suffix) {
            box.addView(suffix, new FrameLayout.LayoutParams(Kit.dp(getContext(), 48), -1, Gravity.END | Gravity.CENTER_VERTICAL));
            edit.setPaddingRelative(edit.getPaddingStart(), edit.getPaddingTop(), Kit.dp(getContext(), 48), edit.getPaddingBottom());
        }

        public String text() {
            return edit.getText() == null ? "" : edit.getText().toString();
        }
    }

    private int dp(float v) { return Kit.dp(this, v); }
    private TextView text(String s, float sp, int weight, int color) { return Kit.text(this, s, sp, weight, color); }
    private LinearLayout.LayoutParams lp(int w, int h, float l, float t, float r, float b) { return Kit.lp(this, w, h, l, t, r, b); }
}
