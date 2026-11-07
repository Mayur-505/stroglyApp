package com.strongly.strongly.ui;

import android.content.Context;
import android.view.Gravity;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;

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

        return row;
    }
}
