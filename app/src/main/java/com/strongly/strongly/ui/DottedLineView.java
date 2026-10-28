package com.strongly.strongly.ui;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.view.View;

/** 1dp dashed horizontal guideline (Flutter's _DottedLinePainter variants). */
public class DottedLineView extends View {
    private final Paint paint = new Paint();
    private final float dash, gap;

    public DottedLineView(Context c, int color, float dashDp, float gapDp) {
        super(c);
        float d = c.getResources().getDisplayMetrics().density;
        dash = dashDp * d;
        gap = gapDp * d;
        paint.setColor(color);
        paint.setStrokeWidth(Math.max(1f, d));
    }

    @Override
    protected void onDraw(Canvas canvas) {
        float x = 0;
        float y = paint.getStrokeWidth() / 2f;
        while (x < getWidth()) {
            canvas.drawLine(x, y, Math.min(x + dash, getWidth()), y, paint);
            x += dash + gap;
        }
    }
}
