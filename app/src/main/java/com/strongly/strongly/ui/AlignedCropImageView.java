package com.strongly.strongly.ui;

import android.content.Context;
import android.graphics.Matrix;
import android.graphics.drawable.Drawable;
import android.widget.ImageView;

/** BoxFit.cover with a chosen alignment (0 = start, 0.5 = center, 1 = end on each axis). */
public class AlignedCropImageView extends ImageView {
    private final float hAlign, vAlign;

    public AlignedCropImageView(Context c, float hAlign, float vAlign) {
        super(c);
        this.hAlign = hAlign;
        this.vAlign = vAlign;
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
            m.postTranslate((vw - d.getIntrinsicWidth() * s) * hAlign, (vh - d.getIntrinsicHeight() * s) * vAlign);
            setImageMatrix(m);
        }
        return changed;
    }
}
