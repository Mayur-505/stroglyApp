package com.strongly.strongly.model;

import java.util.HashMap;
import java.util.Map;

/**
 * Local day-progress overrides shared by the plan screens. Flutter keeps this state in the
 * schedule screen through callbacks; here it lives in memory per plan so every screen sees it.
 */
public final class PlanState {
    private PlanState() {}

    public static final class DayOverride {
        public Double progress;
        public Boolean completed;
        public Boolean unlocked;
    }

    private static final Map<String, Map<Integer, DayOverride>> STATE = new HashMap<>();
    /** Day completions already sent to the server this session (Flutter's _submittedKeys). */
    public static final java.util.Set<String> SUBMITTED = new java.util.HashSet<>();

    private static DayOverride get(String planId, int day) {
        Map<Integer, DayOverride> m = STATE.get(planId);
        if (m == null) { m = new HashMap<>(); STATE.put(planId, m); }
        DayOverride d = m.get(day);
        if (d == null) { d = new DayOverride(); m.put(day, d); }
        return d;
    }

    /** True once a day has been started and not yet completed (the "Continue" state). */
    public static boolean isStarted(String planId, int day) {
        Map<Integer, DayOverride> m = STATE.get(planId);
        DayOverride o = m == null ? null : m.get(day);
        return o != null && o.progress != null && o.progress > 0 && !Boolean.TRUE.equals(o.completed);
    }

    public static void start(String planId, int day) { get(planId, day).progress = 0.40; }

    public static void restart(String planId, int day) {
        DayOverride d = get(planId, day);
        d.progress = 0.0;
        d.completed = false;
    }

    public static void complete(String planId, int day) {
        DayOverride d = get(planId, day);
        d.completed = true;
        d.progress = 1.0;
        DayOverride next = get(planId, day + 1);
        next.unlocked = true;
        next.progress = 0.0;
        next.completed = false;
    }

    public static PlanModels.Day apply(String planId, PlanModels.Day day) {
        Map<Integer, DayOverride> m = STATE.get(planId);
        DayOverride o = m == null ? null : m.get(day.dayNumber);
        if (o == null) return day;
        return new PlanModels.Day(day.dayNumber, day.duration,
                o.progress != null ? o.progress : day.progress,
                o.unlocked != null ? o.unlocked : day.isUnlocked,
                o.completed != null ? o.completed : day.isCompleted);
    }
}
