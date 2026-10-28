package com.strongly.strongly.ui;

import android.content.Context;
import android.graphics.drawable.GradientDrawable;
import android.view.View;
import android.widget.FrameLayout;

/** Gradient-bordered selectable card used across the app (Flutter's _GradientBorderCard). */
public final class Cards {
    private Cards() {}

    public static FrameLayout gradientCard(Context c, boolean selected, float radiusDp, int padLeft, int padTop,
                                           int padRight, int padBottom, View content, View.OnClickListener click) {
        FrameLayout outer = new FrameLayout(c);
        int one = UiUtil.dp(c, 1);
        outer.setPadding(one, one, one, one);
        GradientDrawable border = new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM,
                new int[]{0xFFA3D223, selected ? 0x66A3D223 : 0x00A3D223});
        border.setCornerRadius(UiUtil.dp(c, radiusDp));
        outer.setBackground(border);

        FrameLayout inner = new FrameLayout(c);
        GradientDrawable fill = selected
                ? new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, new int[]{0xFF1B1B1D, 0xFF384F14})
                : new GradientDrawable();
        if (!selected) fill.setColor(0xFF1B1B1D);
        fill.setCornerRadius(UiUtil.dp(c, radiusDp - 1));
        inner.setBackground(fill);
        inner.setPadding(padLeft, padTop, padRight, padBottom);
        inner.addView(content);
        outer.addView(inner);
        if (click != null) outer.setOnClickListener(click);
        return outer;
    }
}
