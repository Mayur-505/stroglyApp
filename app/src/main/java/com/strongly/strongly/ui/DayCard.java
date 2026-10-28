package com.strongly.strongly.ui;

import android.content.Context;
import android.graphics.drawable.GradientDrawable;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.strongly.strongly.model.PlanModels;

/** One day row in the plan lists (Flutter's WorkoutDayCard). */
public final class DayCard {
    private static final int LIME = Kit.LIME;

    private DayCard() {}

    public static View build(Context c, PlanModels.Day d, View.OnClickListener onTap) {
        LinearLayout card = new LinearLayout(c);
        card.setGravity(Gravity.CENTER_VERTICAL);
        card.setBackground(Kit.rounded(c, 0xFF161619, 18, 1, 0x14FFFFFF));
        card.setPadding(Kit.dp(c, 20), 0, Kit.dp(c, 20), 0);
        card.setMinimumHeight(Kit.dp(c, 74));

        LinearLayout dayCol = new LinearLayout(c);
        dayCol.setOrientation(LinearLayout.VERTICAL);
        dayCol.setGravity(Gravity.CENTER_VERTICAL);
        TextView day = Kit.text(c, "DAY", 10, 700, 0x8AFFFFFF);
        day.setLetterSpacing(0.08f);
        dayCol.addView(day);
        dayCol.addView(Kit.text(c, String.valueOf(d.dayNumber), 22, 800, 0xFFFFFFFF), Kit.lp(c, -2, -2, 0, 1, 0, 0));
        card.addView(dayCol, new LinearLayout.LayoutParams(Kit.dp(c, 44), -2));

        LinearLayout mid = new LinearLayout(c);
        mid.setOrientation(LinearLayout.VERTICAL);
        mid.setGravity(Gravity.CENTER_VERTICAL);
        LinearLayout dur = new LinearLayout(c);
        dur.setGravity(Gravity.CENTER_VERTICAL);
        dur.addView(Icons.view(c, Icons.ACCESS_TIME_ROUNDED, 13, 0x99FFFFFF));
        dur.addView(Kit.text(c, d.duration, 13, 500, 0xB3FFFFFF), Kit.lp(c, -2, -2, 5, 0, 0, 0));
        mid.addView(dur);

        final double eff = d.isCompleted ? 1.0 : Math.max(0, Math.min(1, d.progress));
        int fillColor = (d.isCompleted || d.isInProgress()) ? LIME : (d.isUnlocked ? 0x4DFFFFFF : 0xFF28282D);
        FrameLayout track = new FrameLayout(c);
        track.setBackground(Kit.rounded(c, 0xFF28282D, 3));
        View fill = new View(c);
        fill.setBackground(Kit.rounded(c, fillColor, 3));
        track.addView(fill, new FrameLayout.LayoutParams(0, -1));
        mid.addView(track, Kit.lp(c, -1, Kit.dp(c, 5), 0, 9, 0, 0));
        // the track is 82% of the column width, as in Flutter
        mid.post(() -> {
            int w = (int) (mid.getWidth() * 0.82f);
            track.getLayoutParams().width = w;
            fill.getLayoutParams().width = (int) (w * eff);
            track.requestLayout();
        });
        LinearLayout.LayoutParams mp = Kit.lp(c, 0, -2, 12, 0, 0, 0);
        mp.weight = 1f;
        card.addView(mid, mp);

        if (d.isCompleted) {
            TextView ok = Icons.view(c, Icons.CHECK_ROUNDED, 20, LIME);
            GradientDrawable g = new GradientDrawable();
            g.setShape(GradientDrawable.OVAL);
            g.setColor(0x29A3D223);
            g.setStroke(Math.max(1, Kit.dp(c, 1.5f)), LIME);
            ok.setBackground(g);
            card.addView(ok, new LinearLayout.LayoutParams(Kit.dp(c, 38), Kit.dp(c, 38)));
        } else if (d.isInProgress()) {
            TextView cont = Kit.text(c, "Continue", 13, 800, 0xFF141416);
            cont.setGravity(Gravity.CENTER);
            cont.setBackground(Kit.rounded(c, LIME, 17));
            cont.setPadding(Kit.dp(c, 14), 0, Kit.dp(c, 14), 0);
            card.addView(cont, new LinearLayout.LayoutParams(-2, Kit.dp(c, 34)));
        } else if (d.isUnlocked) {
            TextView go = Icons.view(c, Icons.ARROW_FORWARD_ROUNDED, 18, 0xFFFFFFFF);
            GradientDrawable g = new GradientDrawable();
            g.setShape(GradientDrawable.OVAL);
            g.setColor(0xFF242428);
            g.setStroke(Math.max(1, Kit.dp(c, 1)), 0x14FFFFFF);
            go.setBackground(g);
            card.addView(go, new LinearLayout.LayoutParams(Kit.dp(c, 38), Kit.dp(c, 38)));
        } else {
            card.addView(Icons.view(c, Icons.LOCK_ROUNDED, 20, 0x4DFFFFFF));
        }
        // Flutter's WorkoutDayCard only reacts to taps when the day is unlocked
        if (d.isUnlocked) card.setOnClickListener(onTap);
        return card;
    }

    /** Variant that always reports taps (the schedule screen shows a hint for locked days). */
    public static View buildAlwaysTappable(Context c, PlanModels.Day d, View.OnClickListener onTap) {
        View v = build(c, d, onTap);
        v.setOnClickListener(onTap);
        return v;
    }
}
