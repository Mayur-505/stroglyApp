package com.strongly.strongly.ui;

import android.content.Context;
import android.graphics.Matrix;
import android.graphics.drawable.Drawable;
import android.widget.ImageView;

/** Like centerCrop but keeps the top edge (Flutter's BoxFit.cover + Alignment.topCenter). */
public class TopCropImageView extends ImageView {
    public TopCropImageView(Context c) {
        super(c);
        setScaleType(ScaleType.MATRIX);
    }

    @Override
    protected boolean setFrame(int l, int t, int r, int b) {
        boolean changed = super.setFrame(l, t, r, b);
        Drawable d = getDrawable();
        if (d != null && d.getIntrinsicWidth() > 0 && d.getIntrinsicHeight() > 0) {
            float vw = getWidth() - getPaddingLeft() - getPaddingRight();
            float vh = getHeight() - getPaddingTop() - getPaddingBottom();
            float s = Math.max(vw / d.getIntrinsicWidth(), vh / d.getIntrinsicHeight());
            Matrix m = new Matrix();
            m.setScale(s, s);
            m.postTranslate((vw - d.getIntrinsicWidth() * s) / 2f, 0);
            setImageMatrix(m);
        }
        return changed;
    }
}
