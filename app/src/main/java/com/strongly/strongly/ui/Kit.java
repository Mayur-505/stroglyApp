package com.strongly.strongly.ui;

import android.content.Context;
import android.graphics.drawable.GradientDrawable;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

/** Small view-building helpers shared by code-built screens. */
public final class Kit {
    public static final int LIME = 0xFFA3D223;

    private Kit() {}

    public static int dp(Context c, float v) { return UiUtil.dp(c, v); }

    public static TextView text(Context c, String s, float sp, int weight, int color) {
        TextView t = new TextView(c);
        t.setText(s);
        t.setTextSize(sp);
        t.setTextColor(color);
        UiUtil.weight(t, weight);
        // default to wrap-content: a LinearLayout would otherwise give it match-parent width and a
        // wrap-content column would squeeze it to its narrowest sibling
        t.setLayoutParams(new LinearLayout.LayoutParams(-2, -2));
        return t;
    }

    public static LinearLayout.LayoutParams lp(Context c, int w, int h, float l, float t, float r, float b) {
        LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(w, h);
        p.topMargin = dp(c, t);
        p.bottomMargin = dp(c, b);
        p.setMarginStart(dp(c, l));
        p.setMarginEnd(dp(c, r));
        return p;
    }

    /** Size in dp for width/height, or MATCH (-1) / WRAP (-2) passed through. */
    public static int sz(Context c, int v) { return v < 0 ? v : dp(c, v); }

    public static GradientDrawable rounded(Context c, int color, float radiusDp) {
        GradientDrawable g = new GradientDrawable();
        g.setColor(color);
        g.setCornerRadius(dp(c, radiusDp));
        return g;
    }

    public static GradientDrawable rounded(Context c, int color, float radiusDp, float strokeDp, int strokeColor) {
        GradientDrawable g = rounded(c, color, radiusDp);
        g.setStroke(Math.max(1, dp(c, strokeDp)), strokeColor);
        return g;
    }

    /** Lime-to-transparent 1dp gradient border wrapper (Flutter's gradient card). */
    public static FrameLayout gradientBorder(Context c, float radiusDp, View inner, ViewGroup.LayoutParams innerLp) {
        FrameLayout outer = new FrameLayout(c);
        int one = dp(c, 1);
        outer.setPadding(one, one, one, one);
        GradientDrawable g = new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, new int[]{0xFFA3D223, 0x00A3D223});
        g.setCornerRadius(dp(c, radiusDp));
        outer.setBackground(g);
        outer.addView(inner, innerLp);
        return outer;
    }

    /** Gradient with explicit color stops; vertical (top to bottom) or horizontal (left to right). */
    public static android.graphics.drawable.Drawable stops(final int[] colors, final float[] positions, final boolean vertical) {
        android.graphics.drawable.PaintDrawable d = new android.graphics.drawable.PaintDrawable();
        d.setShape(new android.graphics.drawable.shapes.RectShape());
        d.setShaderFactory(new android.graphics.drawable.ShapeDrawable.ShaderFactory() {
            @Override public android.graphics.Shader resize(int w, int h) {
                return new android.graphics.LinearGradient(0, 0, vertical ? 0 : w, vertical ? h : 0,
                        colors, positions, android.graphics.Shader.TileMode.CLAMP);
            }
        });
        return d;
    }

    /** Dark snackbar like Flutter's SnackBar(backgroundColor: 0xFF1B1B1D). */
    public static void snack(View anchor, String message, int textColor, int durationMs) {
        com.google.android.material.snackbar.Snackbar sb =
                com.google.android.material.snackbar.Snackbar.make(anchor, message, durationMs);
        sb.setBackgroundTint(0xFF1B1B1D);
        sb.setTextColor(textColor);
        sb.show();
    }

    public static android.widget.TextView circleIcon(Context c, int codePoint, float iconDp, int sizeDp, int fill, int stroke) {
        android.widget.TextView t = Icons.view(c, codePoint, iconDp, 0xFFFFFFFF);
        GradientDrawable g = new GradientDrawable();
        g.setShape(GradientDrawable.OVAL);
        g.setColor(fill);
        g.setStroke(Math.max(1, dp(c, 1)), stroke);
        t.setBackground(g);
        t.setLayoutParams(new LinearLayout.LayoutParams(dp(c, sizeDp), dp(c, sizeDp)));
        return t;
    }

    public static FrameLayout centered(Context c, View v, int wDp, int hDp) {
        FrameLayout f = new FrameLayout(c);
        f.addView(v, new FrameLayout.LayoutParams(dp(c, wDp), dp(c, hDp), Gravity.CENTER));
        return f;
    }
}
