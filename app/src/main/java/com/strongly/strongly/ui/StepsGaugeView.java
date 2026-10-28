package com.strongly.strongly.ui;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Shader;
import android.graphics.BlurMaskFilter;
import android.view.View;

/** Semicircular steps gauge (Flutter's _StepsArcGaugePainter, 120x75). */
public class StepsGaugeView extends View {
    private final Paint track = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint prog = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint glow = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint thumb = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final float density;
    private final float progress;

    public StepsGaugeView(Context c, float progress) {
        super(c);
        density = c.getResources().getDisplayMetrics().density;
        this.progress = progress;
        setLayerType(LAYER_TYPE_SOFTWARE, null); // needed for the blur glow
        track.setStyle(Paint.Style.STROKE);
        track.setStrokeWidth(9 * density);
        track.setStrokeCap(Paint.Cap.ROUND);
        track.setColor(0xFF28282D);
        prog.setStyle(Paint.Style.STROKE);
        prog.setStrokeWidth(9 * density);
        prog.setStrokeCap(Paint.Cap.ROUND);
        glow.setColor(0x59A3D223);
        glow.setMaskFilter(new BlurMaskFilter(6 * density, BlurMaskFilter.Blur.NORMAL));
        thumb.setColor(0xFFA3D223);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        float w = getWidth(), h = getHeight();
        float cx = w / 2f, cy = h * 0.95f, r = w * 0.44f;
        RectF oval = new RectF(cx - r, cy - r, cx + r, cy + r);
        canvas.drawArc(oval, 180f, 180f, false, track);
        float sweep = 180f * progress;
        prog.setShader(new LinearGradient(oval.left, 0, oval.right, 0, 0xFF6B8B18, 0xFFA3D223, Shader.TileMode.CLAMP));
        if (sweep > 0) canvas.drawArc(oval, 180f, sweep, false, prog);
        double ang = Math.toRadians(180f + sweep);
        float tx = (float) (cx + r * Math.cos(ang)), ty = (float) (cy + r * Math.sin(ang));
        canvas.drawCircle(tx, ty, 8 * density, glow);
        canvas.drawCircle(tx, ty, 5 * density, thumb);
    }
}
