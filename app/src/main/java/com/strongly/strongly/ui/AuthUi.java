package com.strongly.strongly.ui;

import android.app.Activity;
import android.content.Context;
import android.text.InputType;
import android.text.method.PasswordTransformationMethod;
import android.view.Gravity;
import android.view.View;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;

/** Shared building blocks for the login, signup, OTP and password screens. */
public final class AuthUi {
    public static final int LIME = Kit.LIME;
    private static final int INK = 0xFF111113;

    private AuthUi() {}

    /** Black page with the circular back button; returns the centered content column. */
    public static LinearLayout page(Activity a) {
        ScrollView sv = new ScrollView(a);
        sv.setBackgroundColor(0xFF000000);
        sv.setVerticalScrollBarEnabled(false);
        sv.setFillViewport(true);
        LinearLayout col = new LinearLayout(a);
        col.setOrientation(LinearLayout.VERTICAL);
        col.setGravity(Gravity.CENTER_HORIZONTAL);
        col.setPadding(Kit.dp(a, 24), Kit.dp(a, 16), Kit.dp(a, 24), Kit.dp(a, 16));
        sv.addView(col, new FrameLayout.LayoutParams(-1, -2));
        UiUtil.padForInsets(col, true, true);
        UiUtil.edgeToEdge(a);
        a.setContentView(sv);

        TextView back = Icons.view(a, Icons.ARROW_BACK_ROUNDED, 20, 0xFFFFFFFF);
        back.setBackground(Kit.rounded(a, 0x0DFFFFFF, 20));
        back.setOnClickListener(v -> a.finish());
        LinearLayout.LayoutParams bp = new LinearLayout.LayoutParams(Kit.dp(a, 40), Kit.dp(a, 40));
        bp.gravity = Gravity.START;
        col.addView(back, bp);
        return col;
    }

    public static View brandHeader(Context c) {
        LinearLayout row = new LinearLayout(c);
        row.setGravity(Gravity.CENTER_VERTICAL);
        TextView icon = Icons.view(c, Icons.DIRECTIONS_RUN_ROUNDED, 38, 0xFF000000);
        icon.setBackground(Kit.rounded(c, LIME, 18));
        row.addView(icon, new LinearLayout.LayoutParams(Kit.dp(c, 64), Kit.dp(c, 64)));
        LinearLayout col = new LinearLayout(c);
        col.setOrientation(LinearLayout.VERTICAL);
        LinearLayout title = new LinearLayout(c);
        title.setGravity(Gravity.CENTER_VERTICAL);
        TextView name = Kit.text(c, "STRONGLY", 26, 900, LIME);
        name.setLetterSpacing(0.038f);
        title.addView(name);
        title.addView(Kit.text(c, "✦", 16, 400, LIME), Kit.lp(c, -2, -2, 4, 0, 0, 0));
        col.addView(title, new LinearLayout.LayoutParams(-2, -2));
        col.addView(Kit.text(c, "Become Your Strongest.", 13, 500, 0xFFFFFFFF), Kit.lp(c, -2, -2, 0, 2, 0, 0));
        row.addView(col, Kit.lp(c, -2, -2, 16, 0, 0, 0));
        return row;
    }

    public static TextView title(Context c, String s) {
        TextView t = Kit.text(c, s, 26, 800, 0xFFFFFFFF);
        t.setGravity(Gravity.CENTER);
        return t;
    }

    public static TextView subtitle(Context c, String s) {
        TextView t = Kit.text(c, s, 14, 400, 0x99FFFFFF);
        t.setGravity(Gravity.CENTER);
        t.setLineSpacing(0, 1.15f);
        return t;
    }

    public interface Toggle { void onToggle(boolean visible); }

    /** Pill-shaped input with a leading icon and an optional visibility toggle. */
    public static LinearLayout pillInput(Context c, String hint, int icon, int inputType, boolean password, EditText[] out) {
        LinearLayout box = new LinearLayout(c);
        box.setGravity(Gravity.CENTER_VERTICAL);
        box.setBackground(Kit.rounded(c, 0xFF161619, 30, 1, 0x2EFFFFFF));
        box.setPadding(Kit.dp(c, 14), 0, Kit.dp(c, 8), 0);
        box.addView(Icons.view(c, icon, 20, 0x8AFFFFFF), new LinearLayout.LayoutParams(Kit.dp(c, 24), Kit.dp(c, 24)));

        EditText et = new EditText(c);
        et.setBackground(null);
        et.setSingleLine();
        et.setHint(hint);
        et.setHintTextColor(0x61FFFFFF);
        et.setTextColor(0xFFFFFFFF);
        et.setTextSize(14);
        et.setPadding(Kit.dp(c, 12), Kit.dp(c, 14), Kit.dp(c, 8), Kit.dp(c, 14));
        et.setInputType(password ? (InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD) : inputType);
        if (password) et.setTransformationMethod(PasswordTransformationMethod.getInstance());
        UiUtil.weight(et, 400); // after setInputType, which resets the typeface for password fields
        box.addView(et, new LinearLayout.LayoutParams(0, -2, 1f));
        out[0] = et;

        if (password) {
            TextView eye = Icons.view(c, Icons.VISIBILITY_OUTLINED, 20, 0x8AFFFFFF);
            eye.setOnClickListener(v -> {
                boolean hidden = et.getTransformationMethod() != null;
                et.setTransformationMethod(hidden ? null : PasswordTransformationMethod.getInstance());
                eye.setText(new String(Character.toChars(hidden ? Icons.VISIBILITY_OFF_OUTLINED : Icons.VISIBILITY_OUTLINED)));
                et.setSelection(et.getText().length());
            });
            box.addView(eye, new LinearLayout.LayoutParams(Kit.dp(c, 40), Kit.dp(c, 40)));
        }
        return box;
    }

    /** Lime 52dp pill button that swaps its label for a spinner while loading. */
    public static final class LoadingButton {
        public final FrameLayout view;
        private final TextView label;
        private final ProgressBar spinner;
        private boolean loading;

        public LoadingButton(Context c, String text, View.OnClickListener click) {
            view = new FrameLayout(c);
            view.setBackground(Kit.rounded(c, LIME, 30));
            label = Kit.text(c, text, 16, 800, INK);
            view.addView(label, new FrameLayout.LayoutParams(-2, -2, Gravity.CENTER));
            spinner = new ProgressBar(c);
            spinner.setIndeterminateTintList(android.content.res.ColorStateList.valueOf(INK));
            spinner.setVisibility(View.GONE);
            view.addView(spinner, new FrameLayout.LayoutParams(Kit.dp(c, 22), Kit.dp(c, 22), Gravity.CENTER));
            view.setOnClickListener(v -> { if (!loading) click.onClick(v); });
        }

        public void setLoading(boolean l) {
            loading = l;
            label.setVisibility(l ? View.GONE : View.VISIBLE);
            spinner.setVisibility(l ? View.VISIBLE : View.GONE);
        }
    }

    public static void error(View anchor, String message) {
        com.google.android.material.snackbar.Snackbar sb =
                com.google.android.material.snackbar.Snackbar.make(anchor, message, 3000);
        sb.setBackgroundTint(0xFF2C1414);
        sb.setTextColor(0xFFFF5B5B);
        sb.show();
    }

    public static void success(View anchor, String message) {
        com.google.android.material.snackbar.Snackbar sb =
                com.google.android.material.snackbar.Snackbar.make(anchor, message, 3000);
        sb.setBackgroundTint(0xFF1B1B1D);
        sb.setTextColor(LIME);
        sb.show();
    }

    /** "<muted text> <lime link>" footer row. */
    public static View footer(Context c, String muted, String link, View.OnClickListener click) {
        LinearLayout row = new LinearLayout(c);
        row.setGravity(Gravity.CENTER);
        row.addView(Kit.text(c, muted, 14, 400, 0x99FFFFFF));
        TextView l = Kit.text(c, link, 14, 700, LIME);
        l.setOnClickListener(click);
        row.addView(l);
        return row;
    }

    public static View image(Context c, String drawableName, int heightDp) {
        android.widget.ImageView img = new android.widget.ImageView(c);
        img.setScaleType(android.widget.ImageView.ScaleType.FIT_CENTER);
        img.setAdjustViewBounds(true);
        int id = c.getResources().getIdentifier(drawableName, "drawable", c.getPackageName());
        if (id != 0) img.setImageResource(id);
        img.setLayoutParams(new LinearLayout.LayoutParams(-2, Kit.dp(c, heightDp)));
        return img;
    }

    /** Dismisses the keyboard before starting a request. */
    public static void hideKeyboard(Activity a) {
        View f = a.getCurrentFocus();
        if (f != null) {
            ((android.view.inputmethod.InputMethodManager) a.getSystemService(Context.INPUT_METHOD_SERVICE))
                    .hideSoftInputFromWindow(f.getWindowToken(), 0);
        }
    }
}
