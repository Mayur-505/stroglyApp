package com.strongly.strongly.ui;

import android.content.Context;
import android.graphics.drawable.GradientDrawable;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.strongly.strongly.model.ProgressModels;
import com.strongly.strongly.util.Tr;

import java.util.Calendar;
import java.util.List;
import java.util.Set;

/** Card builders for the Progress tab and its detail screen (Flutter's progress/widgets). */
public final class ProgressCards {
    private static final int LIME = Kit.LIME;

    private ProgressCards() {}

    public interface DayTap { void onTap(int dayNumber, boolean currentMonth); }

    private static LinearLayout card(Context c, float padDp) {
        LinearLayout l = new LinearLayout(c);
        l.setOrientation(LinearLayout.VERTICAL);
        l.setBackground(Kit.rounded(c, 0xFF161619, 18, 1, 0x0FFFFFFF));
        int p = Kit.dp(c, padDp);
        l.setPadding(p, p, p, p);
        return l;
    }

    private static LinearLayout.LayoutParams wrap() { return new LinearLayout.LayoutParams(-2, -2); }

    // ------------------------------------------------------------------ weekly day calendar

    public static View weeklyCalendar(Context c, List<ProgressModels.DayStatus> days, View.OnClickListener onTap) {
        LinearLayout card = new LinearLayout(c);
        card.setBackground(Kit.rounded(c, 0xFF161619, 18, 1, 0x0FFFFFFF));
        card.setPadding(Kit.dp(c, 14), Kit.dp(c, 16), Kit.dp(c, 14), Kit.dp(c, 16));
        for (ProgressModels.DayStatus d : days) {
            LinearLayout col = new LinearLayout(c);
            col.setOrientation(LinearLayout.VERTICAL);
            col.setGravity(Gravity.CENTER_HORIZONTAL);
            col.addView(Kit.text(c, d.dayName, 12, 600, 0x8AFFFFFF), wrap());
            if (d.isCompleted) {
                TextView ok = Icons.view(c, Icons.CHECK_ROUNDED, 18, 0xFF141416);
                GradientDrawable g = new GradientDrawable();
                g.setShape(GradientDrawable.OVAL);
                g.setColor(LIME);
                ok.setBackground(g);
                col.addView(ok, Kit.lp(c, Kit.dp(c, 28), Kit.dp(c, 28), 0, 12, 0, 0));
            } else {
                TextView t = Kit.text(c, d.dateText, 15, 800, 0xFFFFFFFF);
                t.setGravity(Gravity.CENTER);
                col.addView(t, Kit.lp(c, Kit.dp(c, 28), Kit.dp(c, 28), 0, 12, 0, 0));
            }
            // spaceAround: equal weight columns keep the same visual rhythm
            card.addView(col, new LinearLayout.LayoutParams(0, -2, 1f));
        }
        card.setOnClickListener(onTap);
        return card;
    }

    // ------------------------------------------------------------------ stat card

    public static View statCard(Context c, ProgressModels.Stat s, View.OnClickListener onTap) {
        LinearLayout card = card(c, 16);
        LinearLayout top = new LinearLayout(c);
        top.setGravity(Gravity.CENTER_VERTICAL);
        top.addView(Kit.text(c, s.title + " (" + s.unit + ")", 13, 600, 0xB3FFFFFF), new LinearLayout.LayoutParams(0, -2, 1f));
        top.addView(Icons.view(c, Icons.CHEVRON_RIGHT_ROUNDED, 18, 0x61FFFFFF));
        card.addView(top, new LinearLayout.LayoutParams(-1, -2));

        LinearLayout mid = new LinearLayout(c);
        mid.setOrientation(LinearLayout.VERTICAL);
        TextView value = Kit.text(c, s.totalValue, 28, 800, 0xFFFFFFFF);
        value.setIncludeFontPadding(false);
        mid.addView(value);
        mid.addView(Kit.text(c, "In total", 11, 500, 0x61FFFFFF), Kit.lp(c, -2, -2, 0, 4, 0, 0));
        card.addView(mid, Kit.lp(c, -1, -2, 0, 10, 0, 0));

        LinearLayout bottom = new LinearLayout(c);
        bottom.setGravity(Gravity.CENTER_VERTICAL);
        bottom.addView(Kit.text(c, "This week", 12, 500, 0x99FFFFFF), new LinearLayout.LayoutParams(0, -2, 1f));
        bottom.addView(Kit.text(c, s.weekValue, 13, 700, 0xFFFFFFFF));
        card.addView(bottom, Kit.lp(c, -1, -2, 0, 14, 0, 0));
        card.setOnClickListener(onTap);
        return card;
    }

    // ------------------------------------------------------------------ steps gauge card

    public static View stepsCard(Context c, int current, int target, View.OnClickListener onTap) {
        float progress = target > 0 ? Math.max(0f, Math.min(1f, (float) current / target)) : 0.25f;
        LinearLayout card = card(c, 16);
        LinearLayout top = new LinearLayout(c);
        top.setGravity(Gravity.CENTER_VERTICAL);
        top.addView(Icons.view(c, Icons.DIRECTIONS_WALK_ROUNDED, 18, LIME));
        top.addView(Kit.text(c, "Steps", 13, 600, 0xB3FFFFFF), Kit.lp(c, 0, -2, 6, 0, 0, 0));
        ((LinearLayout.LayoutParams) top.getChildAt(1).getLayoutParams()).weight = 1f;
        top.addView(Icons.view(c, Icons.CHEVRON_RIGHT_ROUNDED, 18, 0x61FFFFFF));
        card.addView(top, new LinearLayout.LayoutParams(-1, -2));

        FrameLayout gauge = new FrameLayout(c);
        gauge.addView(new StepsGaugeView(c, progress), new FrameLayout.LayoutParams(Kit.dp(c, 120), Kit.dp(c, 75), Gravity.CENTER));
        LinearLayout label = new LinearLayout(c);
        label.setGravity(Gravity.BOTTOM);
        label.addView(Kit.text(c, String.valueOf(current), 18, 800, 0xFFFFFFFF));
        label.addView(Kit.text(c, "stp", 10, 600, 0x99FFFFFF), Kit.lp(c, -2, -2, 2, 0, 0, 3));
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(-2, -2, Gravity.CENTER_HORIZONTAL | Gravity.BOTTOM);
        lp.bottomMargin = Kit.dp(c, 4);
        gauge.addView(label, lp);
        card.addView(gauge, Kit.lp(c, -1, Kit.dp(c, 76), 0, 8, 0, 0));
        card.setOnClickListener(onTap);
        return card;
    }

    // ------------------------------------------------------------------ weekly bar chart card

    public static View barChart(Context c, ProgressModels.Chart chart, View.OnClickListener onTap) {
        LinearLayout card = card(c, 16);
        card.setPadding(Kit.dp(c, 18), Kit.dp(c, 16), Kit.dp(c, 18), Kit.dp(c, 16));

        LinearLayout top = new LinearLayout(c);
        top.addView(Kit.text(c, chart.metricTitle, 15, 700, 0xFFFFFFFF), new LinearLayout.LayoutParams(0, -2, 1f));
        LinearLayout avg = new LinearLayout(c);
        avg.setOrientation(LinearLayout.VERTICAL);
        avg.setGravity(Gravity.END);
        avg.addView(Kit.text(c, "Weekly Average", 11, 500, 0x8AFFFFFF), wrap());
        avg.addView(Kit.text(c, chart.weeklyAverageText, 12, 700, 0xFFFFFFFF), Kit.lp(c, -2, -2, 0, 2, 0, 0));
        top.addView(avg);
        card.addView(top, new LinearLayout.LayoutParams(-1, -2));

        TextView main = Kit.text(c, chart.mainValueText, 24, 800, 0xFFFFFFFF);
        main.setLineSpacing(0, 0.9f);
        card.addView(main, wrap());

        FrameLayout area = new FrameLayout(c);
        DottedLineView dotted = new DottedLineView(c, 0x1FFFFFFF, 3, 3);
        FrameLayout.LayoutParams dl = new FrameLayout.LayoutParams(-1, Kit.dp(c, 1), Gravity.BOTTOM);
        dl.bottomMargin = Kit.dp(c, 38);
        area.addView(dotted, dl);

        LinearLayout row = new LinearLayout(c);
        row.setGravity(Gravity.BOTTOM);
        float maxBar = 46f;
        for (ProgressModels.ChartDay d : chart.days) {
            LinearLayout col = new LinearLayout(c);
            col.setOrientation(LinearLayout.VERTICAL);
            col.setGravity(Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL);
            FrameLayout slot = new FrameLayout(c);
            View mark = new View(c);
            if (d.hasActivity) {
                float h = (float) Math.max(14.0, Math.min(maxBar, d.value * maxBar));
                mark.setBackground(Kit.rounded(c, LIME, 3));
                slot.addView(mark, new FrameLayout.LayoutParams(Kit.dp(c, 5), Kit.dp(c, h), Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL));
            } else {
                GradientDrawable g = new GradientDrawable();
                g.setShape(GradientDrawable.OVAL);
                g.setColor(0x33FFFFFF);
                mark.setBackground(g);
                slot.addView(mark, new FrameLayout.LayoutParams(Kit.dp(c, 4), Kit.dp(c, 4), Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL));
            }
            col.addView(slot, new LinearLayout.LayoutParams(Kit.dp(c, 20), Kit.dp(c, maxBar)));
            col.addView(Kit.text(c, d.dayLabel, 12, d.isHighlighted ? 800 : 500, d.isHighlighted ? 0xFFFFFFFF : 0x66FFFFFF),
                    Kit.lp(c, -2, -2, 0, 8, 0, 0));
            row.addView(col, new LinearLayout.LayoutParams(0, -1, 1f));
        }
        area.addView(row, new FrameLayout.LayoutParams(-1, Kit.dp(c, 80)));
        card.addView(area, Kit.lp(c, -1, Kit.dp(c, 80), 0, 16, 0, 0));
        card.setOnClickListener(onTap);
        return card;
    }

    // ------------------------------------------------------------------ summary card (detail screen)

    public static View summaryCard(Context c, List<ProgressModels.ChartDay> days, String averageValue) {
        LinearLayout card = card(c, 18);
        LinearLayout header = new LinearLayout(c);
        LinearLayout left = new LinearLayout(c);
        left.setOrientation(LinearLayout.VERTICAL);
        left.addView(Kit.text(c, "", 15, 700, 0xFFFFFFFF), wrap());   // dateRange (empty in Flutter)
        left.addView(Kit.text(c, "", 11, 500, 0x61FFFFFF), Kit.lp(c, -2, -2, 0, 3, 0, 0)); // year
        header.addView(left, new LinearLayout.LayoutParams(0, -2, 1f));
        LinearLayout right = new LinearLayout(c);
        right.setOrientation(LinearLayout.VERTICAL);
        right.setGravity(Gravity.END);
        TextView avg = Kit.text(c, averageValue, 20, 800, 0xFFFFFFFF);
        avg.setLineSpacing(0, 0.9f);
        right.addView(avg, wrap());
        right.addView(Kit.text(c, "Average (min)", 11, 500, 0x61FFFFFF), Kit.lp(c, -2, -2, 0, 3, 0, 0));
        header.addView(right);
        card.addView(header, new LinearLayout.LayoutParams(-1, -2));

        FrameLayout area = new FrameLayout(c);
        FrameLayout.LayoutParams dl = new FrameLayout.LayoutParams(-1, Kit.dp(c, 1), Gravity.TOP);
        dl.topMargin = Kit.dp(c, 36);
        area.addView(new DottedLineView(c, 0xFF28282D, 3, 3), dl);
        LinearLayout row = new LinearLayout(c);
        row.setGravity(Gravity.BOTTOM);
        float max = 56f;
        if (days != null) for (ProgressModels.ChartDay d : days) {
            LinearLayout col = new LinearLayout(c);
            col.setOrientation(LinearLayout.VERTICAL);
            col.setGravity(Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL);
            FrameLayout slot = new FrameLayout(c);
            View mark = new View(c);
            if (d.hasActivity) {
                float h = (float) Math.max(0.0, Math.min(max, d.value * max));
                mark.setBackground(Kit.rounded(c, LIME, 4));
                slot.addView(mark, new FrameLayout.LayoutParams(Math.round(Kit.dp(c, 5.5f)), Kit.dp(c, h), Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL));
            } else {
                GradientDrawable g = new GradientDrawable();
                g.setShape(GradientDrawable.OVAL);
                g.setColor(0xFF424248);
                mark.setBackground(g);
                FrameLayout.LayoutParams mp = new FrameLayout.LayoutParams(Kit.dp(c, 3.5f), Kit.dp(c, 3.5f), Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL);
                mp.bottomMargin = Kit.dp(c, 2);
                slot.addView(mark, mp);
            }
            col.addView(slot, new LinearLayout.LayoutParams(Kit.dp(c, 22), Kit.dp(c, max)));
            col.addView(Kit.text(c, d.dayLabel, 11, d.isHighlighted ? 800 : 500, d.isHighlighted ? 0xFFFFFFFF : 0x61FFFFFF),
                    Kit.lp(c, -2, -2, 0, 8, 0, 0));
            row.addView(col, new LinearLayout.LayoutParams(0, -2, 1f));
        }
        area.addView(row, new FrameLayout.LayoutParams(-1, -1));
        card.addView(area, Kit.lp(c, -1, Kit.dp(c, 90), 0, 20, 0, 0));
        return card;
    }

    // ------------------------------------------------------------------ monthly calendar (history tab)

    private static final String[] WEEK = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
    private static final String[] MONTHS = {"january", "february", "march", "april", "may", "june", "july", "august",
            "september", "october", "november", "december"};

    public static View monthlyCalendar(Context c, String monthTitle, Set<Integer> completed, Integer selectedDay,
                                       View.OnClickListener prev, View.OnClickListener next, DayTap onDay) {
        int year = 2026, month = 9;
        String[] parts = monthTitle.split(" ");
        if (parts.length == 2) {
            try { year = Integer.parseInt(parts[1]); } catch (Exception ignored) { }
            for (int i = 0; i < 12; i++) if (MONTHS[i].equals(parts[0].toLowerCase())) month = i + 1;
        }
        Calendar cal = Calendar.getInstance();
        cal.clear();
        cal.set(year, month - 1, 1);
        int daysInMonth = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
        int startOffset = cal.get(Calendar.DAY_OF_WEEK) - 1; // Sunday = 0
        Calendar pc = (Calendar) cal.clone();
        pc.add(Calendar.MONTH, -1);
        int prevDays = pc.getActualMaximum(Calendar.DAY_OF_MONTH);

        LinearLayout card = card(c, 16);
        LinearLayout nav = new LinearLayout(c);
        nav.setGravity(Gravity.CENTER_VERTICAL);
        TextView l = Icons.view(c, Icons.CHEVRON_LEFT_ROUNDED, 20, 0x61FFFFFF);
        l.setOnClickListener(prev);
        nav.addView(l, new LinearLayout.LayoutParams(Kit.dp(c, 32), Kit.dp(c, 32)));
        TextView title = Kit.text(c, monthTitle, 14, 600, 0xFFFFFFFF);
        title.setGravity(Gravity.CENTER);
        nav.addView(title, new LinearLayout.LayoutParams(0, -2, 1f));
        TextView r = Icons.view(c, Icons.CHEVRON_RIGHT_ROUNDED, 20, 0x61FFFFFF);
        r.setOnClickListener(next);
        nav.addView(r, new LinearLayout.LayoutParams(Kit.dp(c, 32), Kit.dp(c, 32)));
        card.addView(nav, new LinearLayout.LayoutParams(-1, -2));

        card.addView(new DottedLineView(c, 0x1FFFFFFF, 4, 3), Kit.lp(c, -1, Kit.dp(c, 1), 0, 8, 0, 0));

        LinearLayout head = new LinearLayout(c);
        for (String w : WEEK) {
            TextView t = Kit.text(c, w, 12, 500, 0x99FFFFFF);
            t.setGravity(Gravity.CENTER);
            head.addView(t, new LinearLayout.LayoutParams(0, -2, 1f));
        }
        card.addView(head, Kit.lp(c, -1, -2, 0, 14, 0, 0));

        int total = startOffset + daysInMonth;
        int trailing = (7 - (total % 7)) % 7;
        int cells = total + trailing;
        float gridW = c.getResources().getDisplayMetrics().widthPixels - Kit.dp(c, 40) - Kit.dp(c, 32) - 2;
        int cellH = Math.round((gridW - Kit.dp(c, 36)) / 7f / 1.1f);
        LinearLayout grid = new LinearLayout(c);
        grid.setOrientation(LinearLayout.VERTICAL);
        for (int rowIdx = 0; rowIdx < cells / 7; rowIdx++) {
            LinearLayout row = new LinearLayout(c);
            for (int col = 0; col < 7; col++) {
                int idx = rowIdx * 7 + col;
                int dayNumber;
                boolean current;
                if (idx < startOffset) { dayNumber = prevDays - (startOffset - 1 - idx); current = false; }
                else if (idx < startOffset + daysInMonth) { dayNumber = idx - startOffset + 1; current = true; }
                else { dayNumber = idx - startOffset - daysInMonth + 1; current = false; }
                boolean done = current && completed != null && completed.contains(dayNumber);
                boolean sel = current && selectedDay != null && selectedDay == dayNumber;
                FrameLayout cell = new FrameLayout(c);
                View inner;
                int sz = Kit.dp(c, 28);
                if (done) {
                    TextView ok = Icons.view(c, Icons.CHECK_ROUNDED, 16, 0xFF141416);
                    GradientDrawable g = new GradientDrawable();
                    g.setShape(GradientDrawable.OVAL);
                    g.setColor(LIME);
                    if (sel) g.setStroke(Kit.dp(c, 2), 0xFFFFFFFF);
                    ok.setBackground(g);
                    inner = ok;
                } else {
                    TextView t = Kit.text(c, String.valueOf(dayNumber), 14, sel ? 800 : 700,
                            sel ? LIME : (current ? 0xFFFFFFFF : 0x61FFFFFF));
                    t.setGravity(Gravity.CENTER);
                    if (sel) {
                        GradientDrawable g = new GradientDrawable();
                        g.setShape(GradientDrawable.OVAL);
                        g.setStroke(Kit.dp(c, 2), LIME);
                        t.setBackground(g);
                    }
                    inner = t;
                }
                cell.addView(inner, new FrameLayout.LayoutParams(sz, sz, Gravity.CENTER));
                final int dn = dayNumber;
                final boolean cur = current;
                cell.setOnClickListener(v -> { if (onDay != null) onDay.onTap(dn, cur); });
                LinearLayout.LayoutParams cp = new LinearLayout.LayoutParams(0, cellH, 1f);
                if (col > 0) cp.setMarginStart(Kit.dp(c, 6));
                row.addView(cell, cp);
            }
            grid.addView(row, Kit.lp(c, -1, -2, 0, 0, 0, rowIdx == cells / 7 - 1 ? 0 : 14));
        }
        card.addView(grid, Kit.lp(c, -1, -2, 0, 14, 0, 0));
        return card;
    }

    // ------------------------------------------------------------------ workout history card

    public static View historyCard(Context c, List<ProgressModels.HistoryLog> logs, int total) {
        LinearLayout card = card(c, 18);
        LinearLayout header = new LinearLayout(c);
        LinearLayout left = new LinearLayout(c);
        left.setOrientation(LinearLayout.VERTICAL);
        left.addView(Kit.text(c, "", 15, 700, 0xFFFFFFFF), wrap());
        left.addView(Kit.text(c, "", 11, 500, 0x61FFFFFF), Kit.lp(c, -2, -2, 0, 3, 0, 0));
        header.addView(left, new LinearLayout.LayoutParams(0, -2, 1f));
        LinearLayout right = new LinearLayout(c);
        right.setOrientation(LinearLayout.VERTICAL);
        right.setGravity(Gravity.END);
        TextView count = Kit.text(c, String.valueOf(total), 20, 800, 0xFFFFFFFF);
        count.setLineSpacing(0, 0.9f);
        right.addView(count, wrap());
        right.addView(Kit.text(c, "Workouts", 11, 500, 0x61FFFFFF), Kit.lp(c, -2, -2, 0, 3, 0, 0));
        header.addView(right);
        card.addView(header, new LinearLayout.LayoutParams(-1, -2));

        card.addView(new DottedLineView(c, 0xFF28282D, 3, 3), Kit.lp(c, -1, Kit.dp(c, 1), 0, 14, 0, 0));

        if (logs.isEmpty()) {
            LinearLayout col = new LinearLayout(c);
            col.setOrientation(LinearLayout.VERTICAL);
            col.setGravity(Gravity.CENTER_HORIZONTAL);
            TextView ic = Icons.view(c, Icons.FITNESS_CENTER_ROUNDED, 26, 0x61FFFFFF);
            GradientDrawable g = new GradientDrawable();
            g.setShape(GradientDrawable.OVAL);
            g.setColor(0x0AFFFFFF);
            ic.setBackground(g);
            col.addView(ic, new LinearLayout.LayoutParams(Kit.dp(c, 50), Kit.dp(c, 50)));
            TextView t1 = Kit.text(c, Tr.t("no_workout_history"), 14, 600, 0xB3FFFFFF);
            t1.setGravity(Gravity.CENTER);
            col.addView(t1, Kit.lp(c, -2, -2, 0, 10, 0, 0));
            TextView t2 = Kit.text(c, Tr.t("no_workout_history_desc"), 12, 400, 0x61FFFFFF);
            t2.setGravity(Gravity.CENTER);
            col.addView(t2, Kit.lp(c, -2, -2, 0, 4, 0, 0));
            card.addView(col, Kit.lp(c, -1, -2, 16, 40, 16, 24));
        } else {
            LinearLayout list = new LinearLayout(c);
            list.setOrientation(LinearLayout.VERTICAL);
            for (int i = 0; i < logs.size(); i++) {
                ProgressModels.HistoryLog it = logs.get(i);
                LinearLayout item = new LinearLayout(c);
                item.setOrientation(LinearLayout.VERTICAL);
                item.addView(Kit.text(c, it.title, 14, 700, 0xFFFFFFFF));
                LinearLayout row = new LinearLayout(c);
                row.addView(metric(c, it.time, it.date), new LinearLayout.LayoutParams(0, -2, 1f));
                row.addView(metric(c, it.duration, "Duration"), new LinearLayout.LayoutParams(0, -2, 1f));
                row.addView(metric(c, it.calories, "Calorie"), new LinearLayout.LayoutParams(0, -2, 1f));
                item.addView(row, Kit.lp(c, -1, -2, 0, 6, 0, 0));
                list.addView(item, Kit.lp(c, -1, -2, 0, 0, 0, i == logs.size() - 1 ? 0 : 16));
            }
            card.addView(list, Kit.lp(c, -1, -2, 0, 16, 0, 0));
        }
        return card;
    }

    private static View metric(Context c, String top, String bottom) {
        LinearLayout col = new LinearLayout(c);
        col.setOrientation(LinearLayout.VERTICAL);
        col.addView(Kit.text(c, top, 12, 600, 0xB3FFFFFF));
        col.addView(Kit.text(c, bottom, 10, 500, 0x61FFFFFF), Kit.lp(c, -2, -2, 0, 2, 0, 0));
        return col;
    }

    // ------------------------------------------------------------------ premium lock

    /** Dims a premium-only card and shows an unlock badge (Flutter's PremiumLockOverlay). */
    public static View premiumLock(Context c, View child, boolean locked, View.OnClickListener onUnlock) {
        if (!locked) return child;
        FrameLayout f = new FrameLayout(c);
        child.setAlpha(0.25f);
        child.setEnabled(false);
        child.setClickable(false);
        f.addView(child, new FrameLayout.LayoutParams(-1, -2));
        LinearLayout badge = new LinearLayout(c);
        badge.setGravity(Gravity.CENTER_VERTICAL);
        badge.setBackground(Kit.rounded(c, 0xFF1F290F, 20, 1.2f, LIME));
        badge.setPadding(Kit.dp(c, 14), Kit.dp(c, 8), Kit.dp(c, 14), Kit.dp(c, 8));
        badge.addView(Icons.view(c, Icons.LOCK_ROUNDED, 16, LIME));
        badge.addView(Kit.text(c, "Unlock with Premium", 12, 700, LIME), Kit.lp(c, -2, -2, 6, 0, 0, 0));
        f.addView(badge, new FrameLayout.LayoutParams(-2, -2, Gravity.CENTER));
        f.setOnClickListener(onUnlock);
        return f;
    }
}
