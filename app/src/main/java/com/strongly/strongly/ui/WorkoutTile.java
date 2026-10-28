package com.strongly.strongly.ui;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.view.Gravity;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.strongly.strongly.model.CategoryWorkoutItem;

/** One row in the category / search workout lists (Flutter's CategoryWorkoutTile). */
public final class WorkoutTile {
    private WorkoutTile() {}

    public static View build(Context c, CategoryWorkoutItem item, View.OnClickListener onTap) {
        LinearLayout row = new LinearLayout(c);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setBackground(Kit.rounded(c, 0xFF161619, 18));
        row.setPadding(Kit.dp(c, 14), Kit.dp(c, 12), Kit.dp(c, 14), Kit.dp(c, 12));
        row.setOnClickListener(onTap);

        ImageView img = new ImageView(c);
        img.setScaleType(ImageView.ScaleType.CENTER_CROP);
        img.setBackground(Kit.rounded(c, 0xFF1B1B1D, 16));
        img.setClipToOutline(true);
        ImageLoader.load(img, item.imagePath, 0xFF1B1B1D);
        row.addView(img, new LinearLayout.LayoutParams(Kit.dp(c, 66), Kit.dp(c, 66)));

        LinearLayout col = new LinearLayout(c);
        col.setOrientation(LinearLayout.VERTICAL);
        col.addView(Kit.text(c, item.title, 16, 700, 0xFFFFFFFF));
        LinearLayout meta = new LinearLayout(c);
        meta.setGravity(Gravity.CENTER_VERTICAL);
        meta.addView(Kit.text(c, item.levels + " levels", 13, 500, 0x8AFFFFFF));
        meta.addView(Kit.text(c, "|", 13, 400, 0x4DFFFFFF), Kit.lp(c, -2, -2, 8, 0, 8, 0));
        meta.addView(Icons.view(c, Icons.ACCESS_TIME_ROUNDED, 13, 0x8AFFFFFF));
        meta.addView(Kit.text(c, item.duration, 13, 500, 0x8AFFFFFF), Kit.lp(c, -2, -2, 4, 0, 0, 0));
        col.addView(meta, Kit.lp(c, -2, -2, 0, 6, 0, 0));
        LinearLayout.LayoutParams cp = Kit.lp(c, 0, -2, 16, 0, 12, 0);
        cp.weight = 1f;
        row.addView(col, cp);

        if (item.isFree) {
            TextView pill = Kit.text(c, "Free", 12, 700, 0xFF141416);
            pill.setBackground(Kit.rounded(c, Kit.LIME, 20));
            pill.setPadding(Kit.dp(c, 16), Kit.dp(c, 6), Kit.dp(c, 16), Kit.dp(c, 6));
            row.addView(pill);
        } else {
            row.addView(new Crown(c, 20), Kit.lp(c, Kit.dp(c, 20), Kit.dp(c, 16), 6, 0, 6, 0));
        }
        return row;
    }

    /** The crown badge Flutter paints with a CustomPainter. */
    static final class Crown extends View {
        private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);

        Crown(Context c, float sizeDp) {
            super(c);
            paint.setColor(Kit.LIME);
        }

        @Override
        protected void onDraw(Canvas canvas) {
            float w = getWidth(), h = getHeight();
            Path p = new Path();
            p.moveTo(w * 0.14f, h * 0.95f);
            p.lineTo(w * 0.86f, h * 0.95f);
            p.lineTo(w * 0.98f, h * 0.32f);
            p.lineTo(w * 0.68f, h * 0.62f);
            p.lineTo(w * 0.50f, h * 0.18f);
            p.lineTo(w * 0.32f, h * 0.62f);
            p.lineTo(w * 0.02f, h * 0.32f);
            p.close();
            canvas.drawPath(p, paint);
            float r = w * 0.075f;
            canvas.drawCircle(w * 0.04f, h * 0.28f, r, paint);
            canvas.drawCircle(w * 0.50f, h * 0.14f, r, paint);
            canvas.drawCircle(w * 0.96f, h * 0.28f, r, paint);
        }
    }
}
