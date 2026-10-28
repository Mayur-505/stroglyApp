package com.strongly.strongly.ui;

import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.view.Window;

import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;

import com.google.gson.JsonObject;

public final class UiUtil {
    private UiUtil() {}

    public static int dp(Context c, float v) {
        return Math.round(v * c.getResources().getDisplayMetrics().density);
    }

    /** Transparent system bars with light icons; content pads itself to the insets. */
    public static void edgeToEdge(Activity a) {
        Window w = a.getWindow();
        WindowCompat.setDecorFitsSystemWindows(w, false);
        WindowCompat.getInsetsController(w, w.getDecorView()).setAppearanceLightStatusBars(false);
        WindowCompat.getInsetsController(w, w.getDecorView()).setAppearanceLightNavigationBars(false);
    }

    /** Adds the system bar insets as padding to the given view. */
    public static void padForInsets(View v, boolean top, boolean bottom) {
        final int pl = v.getPaddingLeft(), pt = v.getPaddingTop(), pr = v.getPaddingRight(), pb = v.getPaddingBottom();
        ViewCompat.setOnApplyWindowInsetsListener(v, (view, insets) -> {
            Insets i = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            view.setPadding(pl, top ? pt + i.top : pt, pr, bottom ? pb + i.bottom : pb);
            return insets;
        });
        // Views built after the first insets pass (screens that render once data arrives) must ask again.
        if (v.isAttachedToWindow()) {
            ViewCompat.requestApplyInsets(v);
        } else {
            v.addOnAttachStateChangeListener(new View.OnAttachStateChangeListener() {
                @Override public void onViewAttachedToWindow(View view) { ViewCompat.requestApplyInsets(view); }
                @Override public void onViewDetachedFromWindow(View view) { }
            });
        }
    }

    private static final android.util.SparseArray<android.graphics.Typeface> WEIGHTS = new android.util.SparseArray<>();

    /** Sets Outfit at the given variable-font weight using a cached typeface with the weight baked in. */
    public static void weight(android.widget.TextView t, int w) {
        android.graphics.Typeface tf = WEIGHTS.get(w);
        if (tf == null) {
            try {
                tf = new android.graphics.Typeface.Builder(t.getContext().getAssets(), "fonts/outfit_variable.ttf")
                        .setFontVariationSettings("'wght' " + w).build();
            } catch (Exception ignored) { }
            if (tf == null) tf = androidx.core.content.res.ResourcesCompat.getFont(t.getContext(), com.strongly.strongly.R.font.outfit_variable);
            WEIGHTS.put(w, tf);
        }
        t.setTypeface(tf);
    }

    public static String str(JsonObject o, String key) {
        return o != null && o.has(key) && !o.get(key).isJsonNull() ? o.get(key).getAsString() : null;
    }
}
