package com.strongly.strongly.ui;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ListPopupWindow;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.strongly.strongly.R;
import com.strongly.strongly.model.UserProfile;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.net.ApiConstants;
import com.strongly.strongly.util.Prefs;
import com.strongly.strongly.util.Tr;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Seven-step questionnaire (Flutter screens 106-112). */
public class QuestionnaireActivity extends AppCompatActivity {
    public static final String EXTRA_GENDER = "gender";
    private static final int LIME = 0xFFA3D223;
    private static final int STEPS = 7;

    private UserProfile profile;
    private int step = 0;
    private int heightV, weightV, ageV;
    private String heightStr, weightStr, ageStr, manualTime = "";

    private TextView title, subtitle, nextText, nextIcon;
    private LinearLayout body;
    private View glow;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_questionnaire);
        UiUtil.edgeToEdge(this);
        UiUtil.padForInsets(findViewById(R.id.content), true, true);
        UiUtil.weight((TextView) findViewById(R.id.title), 900);
        UiUtil.weight((TextView) findViewById(R.id.next_text), 600);

        String g = getIntent().getStringExtra(EXTRA_GENDER);
        profile = new UserProfile(g != null ? g : "Male");
        heightStr = String.valueOf(profile.height);
        weightStr = String.valueOf(profile.weight);
        ageStr = String.valueOf(profile.age);

        title = findViewById(R.id.title);
        subtitle = findViewById(R.id.subtitle);
        nextText = findViewById(R.id.next_text);
        nextIcon = findViewById(R.id.next_icon);
        body = findViewById(R.id.body);
        glow = findViewById(R.id.top_glow);

        float screenH = getResources().getDisplayMetrics().heightPixels / getResources().getDisplayMetrics().density;
        float glowH = Math.max(310f, Math.min(350f, screenH * 0.35f));
        glow.getLayoutParams().height = UiUtil.dp(this, glowH);
        GradientDrawable gd = new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM,
                new int[]{0xFFA3D223, 0xB3A3D223, 0x38A3D223, 0x00A3D223});
        glow.setBackground(gd);

        FrameLayout back = findViewById(R.id.back);
        TextView arrow = Icons.view(this, Icons.ARROW_BACK_ROUNDED, 20, 0xFFFFFFFF);
        back.addView(arrow, new FrameLayout.LayoutParams(-1, -1));
        back.setOnClickListener(v -> prev());

        Icons.apply(nextIcon, Icons.ARROW_FORWARD_ROUNDED, 18, 0xFFFFFFFF);
        findViewById(R.id.next).setOnClickListener(v -> next());
        render();
    }

    private void hideKeyboard() {
        View f = getCurrentFocus();
        if (f != null) {
            ((InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE)).hideSoftInputFromWindow(f.getWindowToken(), 0);
            f.clearFocus();
        }
    }

    private void prev() {
        hideKeyboard();
        if (step > 0) { step--; render(); } else finish();
    }

    private void next() {
        hideKeyboard();
        if (step == 0) {
            profile.height = parse(heightStr, 175);
            profile.weight = parse(weightStr, 75);
            profile.age = parse(ageStr, 25);
        }
        if (step < STEPS - 1) { step++; render(); } else complete();
    }

    private static int parse(String s, int def) {
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return def; }
    }

    private void complete() {
        profile.save();
        Prefs.putBool("onboarding_completed", true);

        JsonObject o = new Gson().toJsonTree(profile).getAsJsonObject();
        ApiClient.get().post(ApiConstants.QUESTIONNAIRE, o, r -> { });

        Intent i = new Intent(this, HomeActivity.class);
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(i);
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
    }

    // ------------------------------------------------------------------ rendering

    private void render() {
        body.removeAllViews();
        body.setAlpha(0f);
        String sub = null;
        String btn = Tr.t("next");
        switch (step) {
            case 0:
                title.setText(Tr.t("lets_understand_body"));
                sub = Tr.t("personalize_fitness_journey");
                buildBody();
                break;
            case 1:
                title.setText(Tr.t("select_main_goal"));
                sub = Tr.t("select_more_than_one_goal");
                buildGoals();
                break;
            case 2:
                title.setText(Tr.t("where_prefer_workout"));
                buildPlaces();
                break;
            case 3:
                title.setText(Tr.t("fitness_level_title"));
                buildLevels();
                break;
            case 4:
                title.setText(Tr.t("how_much_time"));
                buildTime();
                break;
            case 5:
                title.setText(Tr.t("how_often_train"));
                buildFrequency();
                break;
            default:
                title.setText(Tr.t("personalized_plan_title"));
                btn = Tr.t("get_started");
                buildSummary();
        }
        subtitle.setText(sub);
        subtitle.setVisibility(sub == null ? View.GONE : View.VISIBLE);
        nextText.setText(btn);
        body.animate().alpha(1f).setDuration(250).start();
    }

    // ------------------------------------------------------------------ helpers

    private int dp(float v) { return UiUtil.dp(this, v); }

    private TextView text(String s, float sp, int weight, int color) {
        TextView t = new TextView(this);
        t.setText(s);
        t.setTextSize(sp);
        t.setTextColor(color);
        UiUtil.weight(t, weight);
        return t;
    }

    private LinearLayout.LayoutParams lp(int w, int h, int top) {
        LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(w, h);
        p.topMargin = dp(top);
        return p;
    }

    private GradientDrawable field(float radius) {
        GradientDrawable d = new GradientDrawable();
        d.setColor(0xFF1B1B1D);
        d.setCornerRadius(dp(radius));
        d.setStroke(dp(1), 0x1AFFFFFF);
        return d;
    }

    private View checkIcon() {
        return Icons.view(this, Icons.CHECK_CIRCLE_ROUNDED, 18, LIME);
    }

    // ------------------------------------------------------------------ step 0

    private void buildBody() {
        body.addView(metricRow(Tr.t("height"), Icons.HEIGHT_ROUNDED, heightStr, s -> heightStr = s,
                profile.heightUnit, new String[]{"CM", "FT"}, u -> profile.heightUnit = u), lp(-1, -2, 0));
        body.addView(metricRow(Tr.t("weight"), Icons.MONITOR_WEIGHT_OUTLINED, weightStr, s -> weightStr = s,
                profile.weightUnit, new String[]{"Kg", "Lbs"}, u -> profile.weightUnit = u), lp(-1, -2, 16));
        body.addView(metricRow(Tr.t("age"), Icons.CALENDAR_TODAY_OUTLINED, ageStr, s -> ageStr = s,
                null, null, null), lp(-1, -2, 16));
        body.addView(activityRow(), lp(-1, -2, 16));
    }

    private interface Str { void set(String s); }

    private View labeled(String label, int icon, View field) {
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        TextView l = text(label, 13, 400, 0x8AFFFFFF);
        l.setPadding(dp(48), 0, 0, dp(6));
        col.addView(l);
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.CENTER_VERTICAL);
        TextView ic = Icons.view(this, icon, 28, LIME);
        row.addView(ic, new LinearLayout.LayoutParams(dp(28), dp(28)));
        LinearLayout.LayoutParams fp = new LinearLayout.LayoutParams(0, dp(52), 1f);
        fp.setMarginStart(dp(16));
        row.addView(field, fp);
        col.addView(row);
        return col;
    }

    private View metricRow(String label, int icon, String value, Str onText, String unit, String[] opts, Str onUnit) {
        LinearLayout box = new LinearLayout(this);
        box.setGravity(Gravity.CENTER_VERTICAL);
        box.setBackground(field(14));
        box.setPadding(dp(16), 0, dp(16), 0);

        EditText et = new EditText(this);
        et.setBackground(null);
        et.setPadding(0, 0, 0, 0);
        et.setInputType(InputType.TYPE_CLASS_NUMBER);
        et.setText(value);
        et.setTextSize(16);
        et.setTextColor(0xFFFFFFFF);
        UiUtil.weight(et, 600);
        et.setSingleLine();
        et.addTextChangedListener(new SimpleWatcher(s -> onText.set(s)));
        box.addView(et, new LinearLayout.LayoutParams(0, -2, 1f));

        if (unit != null) {
            TextView[] holder = new TextView[1];
            LinearLayout dd = dropdown(unit, opts, v -> {
                onUnit.set(v);
                holder[0].setText(v);
            }, false, holder);
            box.addView(dd, new LinearLayout.LayoutParams(-2, -2));
        }
        return labeled(label, icon, box);
    }

    private interface Pick { void pick(String v); }

    /** Value + chevron that opens a dark popup list, like Flutter's DropdownButton. */
    private LinearLayout dropdown(String current, String[] options, Pick onPick, boolean expanded, TextView[] valueOut) {
        LinearLayout dd = new LinearLayout(this);
        dd.setGravity(Gravity.CENTER_VERTICAL);
        TextView val = text(current, 15, 600, 0xFFFFFFFF);
        valueOut[0] = val;
        dd.addView(val, expanded ? new LinearLayout.LayoutParams(0, -2, 1f) : new LinearLayout.LayoutParams(-2, -2));
        TextView chev = Icons.view(this, Icons.KEYBOARD_ARROW_DOWN_ROUNDED, 20, 0xB3FFFFFF);
        dd.addView(chev);
        dd.setOnClickListener(v -> {
            hideKeyboard();
            ListPopupWindow pw = new ListPopupWindow(this);
            pw.setAnchorView(dd);
            pw.setModal(true);
            GradientDrawable bg = new GradientDrawable();
            bg.setColor(0xFF222226);
            bg.setCornerRadius(dp(14));
            pw.setBackgroundDrawable(bg);
            pw.setWidth(Math.max(dd.getWidth(), dp(110)));
            List<String> labels = new ArrayList<>();
            for (String o : options) labels.add(o);
            pw.setAdapter(new android.widget.BaseAdapter() {
                @Override public int getCount() { return options.length; }
                @Override public Object getItem(int i) { return options[i]; }
                @Override public long getItemId(int i) { return i; }
                @Override public View getView(int i, View cv, ViewGroup parent) {
                    boolean sel = options[i].equals(val.getTag() != null ? val.getTag() : current);
                    TextView t = text(labelFor(options[i]), 15, sel ? 700 : 500, sel ? LIME : 0xFFFFFFFF);
                    t.setPadding(dp(16), dp(12), dp(16), dp(12));
                    return t;
                }
            });
            pw.setOnItemClickListener((p, view, pos, id) -> {
                val.setTag(options[pos]);
                onPick.pick(options[pos]);
                val.setText(labelFor(options[pos]));
                pw.dismiss();
            });
            pw.show();
        });
        return dd;
    }

    private String labelFor(String v) {
        switch (v) {
            case "Sedentary": return Tr.t("sedentary");
            case "Moderate": return Tr.t("moderate");
            case "High Active": return Tr.t("high_active");
            default: return v;
        }
    }

    private View activityRow() {
        LinearLayout box = new LinearLayout(this);
        box.setGravity(Gravity.CENTER_VERTICAL);
        box.setBackground(field(14));
        box.setPadding(dp(16), 0, dp(16), 0);
        TextView[] holder = new TextView[1];
        LinearLayout dd = dropdown(profile.activityLevel, new String[]{"Sedentary", "Moderate", "High Active"},
                v -> profile.activityLevel = v, true, holder);
        holder[0].setText(labelFor(profile.activityLevel));
        holder[0].setTag(profile.activityLevel);
        box.addView(dd, new LinearLayout.LayoutParams(-1, -2));
        return labeled(Tr.t("activity_level"), Icons.DIRECTIONS_RUN_OUTLINED, box);
    }

    // ------------------------------------------------------------------ step 1: goals

    private void buildGoals() {
        String[][] goals = {
                {"Lose Weight", "lose_weight", String.valueOf(Icons.FIRE_ROUNDED)},
                {"Build Muscle", "build_muscle", String.valueOf(Icons.FITNESS_CENTER_ROUNDED)},
                {"Six Pack", "six_pack", String.valueOf(Icons.GYMNASTICS_ROUNDED)},
                {"Improve Fitness", "improve_fitness", String.valueOf(Icons.FAVORITE_ROUNDED)},
                {"Increase Strength", "increase_strength", String.valueOf(Icons.BOLT_ROUNDED)},
                {"Stay Active", "stay_active", String.valueOf(Icons.SMILE_ROUNDED)},
        };
        int gap = dp(14);
        for (int r = 0; r < goals.length; r += 2) {
            LinearLayout row = new LinearLayout(this);
            row.setOrientation(LinearLayout.HORIZONTAL);
            for (int c = 0; c < 2; c++) {
                String[] g = goals[r + c];
                boolean sel = profile.goals.contains(g[0]);

                FrameLayout content = new FrameLayout(this);
                LinearLayout col = new LinearLayout(this);
                col.setOrientation(LinearLayout.VERTICAL);
                col.setGravity(Gravity.CENTER);
                col.addView(Icons.view(this, Integer.parseInt(g[2]), 32, sel ? LIME : 0xFFFFFFFF));
                TextView t = text(Tr.t(g[1]), 14, 600, 0xFFFFFFFF);
                t.setGravity(Gravity.CENTER);
                LinearLayout.LayoutParams tp = new LinearLayout.LayoutParams(-2, -2);
                tp.topMargin = dp(10);
                col.addView(t, tp);
                content.addView(col, new FrameLayout.LayoutParams(-1, -1, Gravity.CENTER));
                if (sel) {
                    FrameLayout.LayoutParams cp = new FrameLayout.LayoutParams(-2, -2, Gravity.TOP | Gravity.END);
                    content.addView(checkIcon(), cp);
                }
                int p = dp(12);
                View card = Cards.gradientCard(this, sel, 16, p, p, p, p, content, v -> {
                    if (profile.goals.contains(g[0])) profile.goals.remove(g[0]); else profile.goals.add(g[0]);
                    int sy = ((View) body.getParent()).getScrollY();
                    render();
                    body.post(() -> ((View) body.getParent()).setScrollY(sy));
                });
                // aspect ratio 1.25 (width / height)
                int w = (getResources().getDisplayMetrics().widthPixels - dp(48) - gap) / 2;
                LinearLayout.LayoutParams cl = new LinearLayout.LayoutParams(w, Math.round(w / 1.25f));
                if (c == 1) cl.setMarginStart(gap);
                row.addView(card, cl);
            }
            body.addView(row, lp(-2, -2, r == 0 ? 0 : 14));
        }
    }

    // ------------------------------------------------------------------ steps 2, 3: list cards

    private void buildPlaces() {
        String[][] places = {
                {"Home", "home", "home_place_desc", String.valueOf(Icons.HOME_ROUNDED)},
                {"Gym", "gym", "gym_place_desc", String.valueOf(Icons.FITNESS_CENTER_ROUNDED)},
                {"Outdoor", "outdoor", "outdoor_place_desc", String.valueOf(Icons.PARK_ROUNDED)},
        };
        for (String[] pl : places) {
            boolean sel = profile.workoutPlace.equals(pl[0]);
            LinearLayout row = new LinearLayout(this);
            row.setGravity(Gravity.CENTER_VERTICAL);
            row.addView(Icons.view(this, Integer.parseInt(pl[3]), 26, sel ? LIME : 0xFFFFFFFF),
                    new LinearLayout.LayoutParams(dp(26), dp(26)));
            LinearLayout col = new LinearLayout(this);
            col.setOrientation(LinearLayout.VERTICAL);
            col.addView(text(Tr.t(pl[1]), 16, 700, 0xFFFFFFFF));
            TextView sub = text(Tr.t(pl[2]), 13, 400, 0x99FFFFFF);
            col.addView(sub, lp(-2, -2, 3));
            LinearLayout.LayoutParams cp = new LinearLayout.LayoutParams(0, -2, 1f);
            cp.setMarginStart(dp(16));
            row.addView(col, cp);
            if (sel) row.addView(Icons.view(this, Icons.CHECK_CIRCLE_ROUNDED, 20, LIME));
            int p = dp(18);
            body.addView(Cards.gradientCard(this, sel, 16, p, p, p, p, row, v -> {
                profile.workoutPlace = pl[0];
                render();
            }), lp(-1, -2, 0));
            ((LinearLayout.LayoutParams) body.getChildAt(body.getChildCount() - 1).getLayoutParams()).bottomMargin = dp(14);
        }
    }

    private void buildLevels() {
        String[][] levels = {
                {"Beginner", "beginner", "beginner_desc"},
                {"Intermediate", "intermediate", "intermediate_desc"},
                {"Advanced", "advanced", "advanced_desc"},
        };
        for (String[] lv : levels) {
            boolean sel = profile.fitnessLevel.equals(lv[0]);
            LinearLayout row = new LinearLayout(this);
            row.setGravity(Gravity.CENTER_VERTICAL);
            LinearLayout col = new LinearLayout(this);
            col.setOrientation(LinearLayout.VERTICAL);
            col.addView(text(Tr.t(lv[1]), 17, 700, 0xFFFFFFFF));
            col.addView(text(Tr.t(lv[2]), 13, 400, 0x99FFFFFF), lp(-2, -2, 4));
            row.addView(col, new LinearLayout.LayoutParams(0, -2, 1f));
            if (sel) row.addView(Icons.view(this, Icons.CHECK_CIRCLE_ROUNDED, 20, LIME));
            int p = dp(20);
            View card = Cards.gradientCard(this, sel, 16, p, p, p, p, row, v -> {
                profile.fitnessLevel = lv[0];
                render();
            });
            LinearLayout.LayoutParams cp = lp(-1, -2, 0);
            cp.bottomMargin = dp(14);
            body.addView(card, cp);
        }
    }

    // ------------------------------------------------------------------ step 4: time

    private void buildTime() {
        String minLabel = Tr.t("min");
        body.addView(text(Tr.t("input_manually"), 13, 400, 0x8AFFFFFF));

        LinearLayout box = new LinearLayout(this);
        box.setGravity(Gravity.CENTER_VERTICAL);
        box.setBackground(field(12));
        box.setPadding(dp(16), 0, dp(16), 0);
        EditText et = new EditText(this);
        et.setBackground(null);
        et.setPadding(0, 0, 0, 0);
        et.setInputType(InputType.TYPE_CLASS_NUMBER);
        et.setHint("00000");
        et.setHintTextColor(0x3DFFFFFF);
        et.setText(manualTime);
        et.setTextSize(15);
        et.setTextColor(0xFFFFFFFF);
        UiUtil.weight(et, 500);
        et.setSingleLine();
        box.addView(et, new LinearLayout.LayoutParams(0, -2, 1f));
        box.addView(text(minLabel, 15, 400, 0x8AFFFFFF));
        body.addView(box, lp(-1, dp(48), 8));

        LinearLayout grid = new LinearLayout(this);
        grid.setOrientation(LinearLayout.VERTICAL);
        body.addView(grid, lp(-1, -2, 20));
        int[] values = {10, 20, 30, 40, 50, 60};
        List<View> cards = new ArrayList<>();
        buildOptionGrid(grid, values.length, i -> values[i] + " " + minLabel,
                i -> profile.duration.startsWith(String.valueOf(values[i])),
                i -> {
                    profile.duration = values[i] + " " + minLabel;
                    manualTime = "";
                    render();
                });

        et.addTextChangedListener(new SimpleWatcher(s -> {
            manualTime = s;
            if (!s.isEmpty()) {
                profile.duration = s + " " + minLabel;
                // Flutter rebuilds the grid on each keystroke; refresh the highlighted card only
                grid.removeAllViews();
                buildOptionGrid(grid, values.length, i -> values[i] + " " + minLabel,
                        i -> profile.duration.startsWith(String.valueOf(values[i])),
                        i -> {
                            profile.duration = values[i] + " " + minLabel;
                            manualTime = "";
                            render();
                        });
            }
        }));
    }

    private interface IntStr { String get(int i); }
    private interface IntBool { boolean get(int i); }
    private interface IntAct { void run(int i); }

    /** Two-column grid of option cards, aspect ratio 2.2, 14dp gaps. */
    private void buildOptionGrid(LinearLayout parent, int count, IntStr label, IntBool selected, IntAct onTap) {
        int gap = dp(14);
        int w = (getResources().getDisplayMetrics().widthPixels - dp(48) - gap) / 2;
        for (int r = 0; r < count; r += 2) {
            LinearLayout row = new LinearLayout(this);
            for (int c = 0; c < 2 && r + c < count; c++) {
                int idx = r + c;
                boolean sel = selected.get(idx);
                LinearLayout content = new LinearLayout(this);
                content.setGravity(Gravity.CENTER_VERTICAL);
                content.addView(text(label.get(idx), 15, 600, 0xFFFFFFFF), new LinearLayout.LayoutParams(0, -2, 1f));
                if (sel) content.addView(checkIcon());
                View card = Cards.gradientCard(this, sel, 14, dp(14), 0, dp(14), 0, content, v -> onTap.run(idx));
                ((FrameLayout) ((FrameLayout) card).getChildAt(0)).getChildAt(0).setLayoutParams(
                        new FrameLayout.LayoutParams(-1, -1));
                LinearLayout.LayoutParams cl = new LinearLayout.LayoutParams(w, Math.round(w / 2.2f));
                if (c == 1) cl.setMarginStart(gap);
                row.addView(card, cl);
            }
            parent.addView(row, lp(-2, -2, r == 0 ? 0 : 14));
        }
    }

    // ------------------------------------------------------------------ step 5: frequency

    private void buildFrequency() {
        String dayLabel = Tr.t("day"), daysLabel = Tr.t("days"), everyDay = Tr.t("every_day");
        LinearLayout grid = new LinearLayout(this);
        grid.setOrientation(LinearLayout.VERTICAL);
        body.addView(grid, lp(-1, -2, 0));
        buildOptionGrid(grid, 6, i -> (i + 1) + " " + (i + 1 == 1 ? dayLabel : daysLabel),
                i -> profile.trainingDays.startsWith(String.valueOf(i + 1)),
                i -> {
                    profile.trainingDays = (i + 1) + " " + (i + 1 == 1 ? dayLabel : daysLabel);
                    render();
                });

        boolean sel = profile.trainingDays.equals("Every Day") || profile.trainingDays.equals(everyDay);
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.addView(text(everyDay, 15, 600, 0xFFFFFFFF), new LinearLayout.LayoutParams(0, -2, 1f));
        if (sel) row.addView(checkIcon());
        View card = Cards.gradientCard(this, sel, 14, dp(16), 0, dp(16), 0, row, v -> {
            profile.trainingDays = everyDay;
            render();
        });
        ((FrameLayout) ((FrameLayout) card).getChildAt(0)).getChildAt(0).setLayoutParams(
                new FrameLayout.LayoutParams(-1, dp(50)));
        body.addView(card, lp(-1, -2, 14));
    }

    // ------------------------------------------------------------------ step 6: summary

    private void buildSummary() {
        Map<String, String> goalT = new LinkedHashMap<>();
        goalT.put("Lose Weight", Tr.t("lose_weight"));
        goalT.put("Build Muscle", Tr.t("build_muscle"));
        goalT.put("Six Pack", Tr.t("six_pack"));
        goalT.put("Improve Fitness", Tr.t("improve_fitness"));
        goalT.put("Increase Strength", Tr.t("increase_strength"));
        goalT.put("Stay Active", Tr.t("stay_active"));
        Map<String, String> levelT = new LinkedHashMap<>();
        levelT.put("Beginner", Tr.t("beginner"));
        levelT.put("Intermediate", Tr.t("intermediate"));
        levelT.put("Advanced", Tr.t("advanced"));
        Map<String, String> placeT = new LinkedHashMap<>();
        placeT.put("Home", Tr.t("home"));
        placeT.put("Gym", Tr.t("gym"));
        placeT.put("Outdoor", Tr.t("outdoor"));

        List<String> gs = new ArrayList<>();
        for (String g : profile.goals) gs.add(goalT.containsKey(g) ? goalT.get(g) : g);
        String goalDisplay = gs.isEmpty() ? Tr.t("stay_active") : android.text.TextUtils.join(", ", gs);

        String[][] rows = {
                {Tr.t("gender"), profile.gender.equals("Male") ? Tr.t("men") : Tr.t("women")},
                {Tr.t("height"), profile.height + " " + profile.heightUnit},
                {Tr.t("weight"), profile.weight + " " + profile.weightUnit},
                {Tr.t("age"), String.valueOf(profile.age)},
                {Tr.t("goal"), goalDisplay},
                {Tr.t("level"), levelT.containsKey(profile.fitnessLevel) ? levelT.get(profile.fitnessLevel) : profile.fitnessLevel},
                {Tr.t("workout"), placeT.containsKey(profile.workoutPlace) ? placeT.get(profile.workoutPlace) : profile.workoutPlace},
                {Tr.t("duration"), profile.duration},
                {Tr.t("days_per_week"), profile.trainingDays},
        };

        LinearLayout card = new LinearLayout(this);
        card.setOrientation(LinearLayout.VERTICAL);
        GradientDrawable bg = new GradientDrawable();
        bg.setColor(0xFF1B1B1D);
        bg.setCornerRadius(dp(20));
        bg.setStroke(dp(1), 0x1FFFFFFF);
        card.setBackground(bg);
        card.setPadding(dp(20), dp(22), dp(20), dp(22));
        for (String[] r : rows) {
            LinearLayout row = new LinearLayout(this);
            row.setGravity(Gravity.CENTER_VERTICAL);
            row.setPadding(0, dp(8), 0, dp(8));
            row.addView(text(r[0], 16, 600, LIME));
            TextView v = text(r[1], 15, 500, 0xFFFFFFFF);
            v.setGravity(Gravity.END);
            LinearLayout.LayoutParams vp = new LinearLayout.LayoutParams(0, -2, 1f);
            vp.setMarginStart(dp(16));
            row.addView(v, vp);
            card.addView(row);
        }
        body.addView(card, lp(-1, -2, 0));
    }

    // ------------------------------------------------------------------ misc

    private static class SimpleWatcher implements TextWatcher {
        private final Str cb;
        SimpleWatcher(Str cb) { this.cb = cb; }
        @Override public void beforeTextChanged(CharSequence s, int a, int b, int c) {}
        @Override public void onTextChanged(CharSequence s, int a, int b, int c) {}
        @Override public void afterTextChanged(Editable e) { cb.set(e.toString()); }
    }
}
