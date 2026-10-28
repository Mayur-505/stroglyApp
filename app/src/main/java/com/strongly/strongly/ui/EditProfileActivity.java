package com.strongly.strongly.ui;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.text.InputType;
import android.view.Gravity;
import android.view.View;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.net.ApiConstants;
import com.strongly.strongly.util.Session;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/** Edit profile (Flutter's EditProfileScreen). */
public class EditProfileActivity extends AppCompatActivity {
    private static final int LIME = Kit.LIME;

    private static final List<String> GENDERS = Arrays.asList("Male", "Female");
    private static final List<String> ACTIVITY = Arrays.asList("Sedentary", "Moderate", "High Active");
    private static final List<String> PLACES = Arrays.asList("Home", "Gym", "Outdoor");
    private static final List<String> LEVELS = Arrays.asList("Beginner", "Intermediate", "Advanced");
    private static final List<String> DURATIONS = Arrays.asList("10 min", "20 min", "30 min", "40 min", "50 min", "60 min");
    private static final List<String> DAYS = Arrays.asList("1 Day", "2 Days", "3 Days", "4 Days", "5 Days", "6 Days", "Everyday");
    private static final List<String> GOALS = Arrays.asList("Lose Weight", "Build Muscle", "Six Pack", "Improve Fitness",
            "Increase Strength", "Stay Active");

    private final EditText[] name = new EditText[1], age = new EditText[1], height = new EditText[1], weight = new EditText[1];
    private String email = "user@example.com", avatarUrl = "";
    private String gender = "Male", heightUnit = "CM", weightUnit = "Kg", activity = "Moderate", place = "Home",
            level = "Beginner", duration = "30 min", days = "5 Days";
    private List<String> goals = new ArrayList<>(Arrays.asList("Build Muscle", "Stay Active"));
    private boolean fetching = true, uploading = false, saving = false;

    private FrameLayout root;
    private LinearLayout form;
    private AuthUi.LoadingButton saveButton;

    private final ActivityResultLauncher<String> picker =
            registerForActivityResult(new ActivityResultContracts.GetContent(), this::onPicked);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        UiUtil.edgeToEdge(this);
        root = new FrameLayout(this);
        root.setBackgroundColor(0xFF000000);
        UiUtil.padForInsets(root, true, true);
        setContentView(root);
        loadProfile();
        render();
    }

    private int dp(float v) { return Kit.dp(this, v); }

    // ------------------------------------------------------------------ data

    private void loadProfile() {
        fetching = true;
        String n = Session.userName() != null ? Session.userName() : "Athlete";
        pendingName = n;
        email = Session.userEmail() != null ? Session.userEmail() : "user@example.com";
        avatarUrl = Session.userAvatar() != null ? Session.userAvatar() : "";
        ApiClient.get().get(ApiConstants.ME, null, r -> {
            if (isFinishing() || isDestroyed()) return;
            if (r.isOk() && r.data != null && r.data.isJsonObject()) {
                JsonObject d = r.data.getAsJsonObject();
                if (d.has("data") && d.get("data").isJsonObject()) d = d.getAsJsonObject("data");
                if (UiUtil.str(d, "name") != null) pendingName = UiUtil.str(d, "name");
                if (UiUtil.str(d, "email") != null) email = UiUtil.str(d, "email");
                if (UiUtil.str(d, "avatar") != null) avatarUrl = UiUtil.str(d, "avatar");
                if (UiUtil.str(d, "gender") != null) gender = UiUtil.str(d, "gender");
                if (d.has("profile") && d.get("profile").isJsonObject()) {
                    JsonObject p = d.getAsJsonObject("profile");
                    pendingHeight = orDef(p, "height", "175");
                    heightUnit = orDef(p, "heightUnit", "CM");
                    pendingWeight = orDef(p, "weight", "75");
                    weightUnit = orDef(p, "weightUnit", "Kg");
                    pendingAge = orDef(p, "age", "25");
                    activity = orDef(p, "activityLevel", "Moderate");
                    place = orDef(p, "workoutPlace", "Home");
                    level = orDef(p, "fitnessLevel", "Beginner");
                    duration = orDef(p, "duration", "30 min");
                    days = orDef(p, "trainingDays", "5 Days");
                    if (p.has("goals") && p.get("goals").isJsonArray()) {
                        goals = new ArrayList<>();
                        for (JsonElement e : p.getAsJsonArray("goals")) goals.add(e.getAsString());
                    }
                }
                Session.save(Session.token() != null ? Session.token() : "", Session.userId() != null ? Session.userId() : "",
                        Session.isGuest(), pendingName, email, avatarUrl);
            }
            fetching = false;
            render();
        });
    }

    private String pendingName = "", pendingAge = "", pendingHeight = "", pendingWeight = "";

    private static String orDef(JsonObject o, String k, String def) {
        String v = UiUtil.str(o, k);
        return v != null ? v : def;
    }

    private void onPicked(Uri uri) {
        if (uri == null) return;
        uploading = true;
        render();
        new Thread(() -> {
            byte[] bytes = null;
            try (InputStream in = getContentResolver().openInputStream(uri)) {
                Bitmap bmp = BitmapFactory.decodeStream(in);
                if (bmp != null) {
                    int max = 1920;
                    float s = Math.min(1f, Math.min(max / (float) bmp.getWidth(), max / (float) bmp.getHeight()));
                    if (s < 1f) bmp = Bitmap.createScaledBitmap(bmp, Math.round(bmp.getWidth() * s), Math.round(bmp.getHeight() * s), true);
                    ByteArrayOutputStream out = new ByteArrayOutputStream();
                    bmp.compress(Bitmap.CompressFormat.JPEG, 85, out);
                    bytes = out.toByteArray();
                }
            } catch (Exception ignored) { }
            final byte[] data = bytes;
            runOnUiThread(() -> {
                if (data == null || data.length == 0) { uploading = false; render(); return; }
                ApiClient.get().uploadPhoto(data, "photo.jpg", "image/jpeg", r -> {
                    if (isFinishing() || isDestroyed()) return;
                    uploading = false;
                    if (r.isOk() && r.data != null && r.data.isJsonObject()) {
                        JsonObject d = r.data.getAsJsonObject();
                        String url = UiUtil.str(d, "url");
                        if (url == null && d.has("data") && d.get("data").isJsonObject()) url = UiUtil.str(d.getAsJsonObject("data"), "url");
                        if (url != null && !url.isEmpty()) { avatarUrl = url; toast("Profile photo uploaded successfully!", false); }
                        else toast("Photo uploaded but server did not return image URL", true);
                    } else {
                        toast(r.message != null ? r.message : "Failed to upload photo", true);
                    }
                    render();
                });
            });
        }).start();
    }

    private void save() {
        String n = name[0].getText().toString().trim();
        if (n.isEmpty()) { toast("Please enter your full name", true); return; }
        capture();
        saving = true;
        saveButton.setLoading(true);
        JsonObject b = new JsonObject();
        b.addProperty("name", n);
        b.addProperty("avatar", avatarUrl);
        b.addProperty("gender", gender);
        b.addProperty("height", parseD(pendingHeight, 175));
        b.addProperty("heightUnit", heightUnit);
        b.addProperty("weight", parseD(pendingWeight, 75));
        b.addProperty("weightUnit", weightUnit);
        b.addProperty("age", (int) parseD(pendingAge, 25));
        b.addProperty("activityLevel", activity);
        JsonArray g = new JsonArray();
        for (String s : goals) g.add(s);
        b.add("goals", g);
        b.addProperty("workoutPlace", place);
        b.addProperty("fitnessLevel", level);
        b.addProperty("duration", duration);
        b.addProperty("trainingDays", days);
        ApiClient.get().post(ApiConstants.QUESTIONNAIRE, b, r -> {
            if (isFinishing() || isDestroyed()) return;
            saving = false;
            saveButton.setLoading(false);
            if (r.isOk()) {
                Session.save(Session.token() != null ? Session.token() : "", Session.userId() != null ? Session.userId() : "",
                        false, n, null, avatarUrl);
                toast("Profile updated successfully!", false);
                setResult(RESULT_OK);
                finish();
            } else {
                toast(r.message != null ? r.message : "Failed to update profile", true);
            }
        });
    }

    private static double parseD(String s, double def) {
        try { return Double.parseDouble(s.trim()); } catch (Exception e) { return def; }
    }

    private void toast(String msg, boolean error) {
        com.google.android.material.snackbar.Snackbar sb = com.google.android.material.snackbar.Snackbar.make(root, msg, 3000);
        sb.setBackgroundTint(error ? 0xFF2C1414 : 0xFF1B1B1D);
        sb.setTextColor(error ? 0xFFFF5B5B : LIME);
        sb.show();
    }

    /** Keep typed values when the form re-renders (e.g. after picking a dropdown value). */
    private void capture() {
        if (name[0] != null) pendingName = name[0].getText().toString();
        if (age[0] != null) pendingAge = age[0].getText().toString();
        if (height[0] != null) pendingHeight = height[0].getText().toString();
        if (weight[0] != null) pendingWeight = weight[0].getText().toString();
    }

    // ------------------------------------------------------------------ rendering

    private void render() {
        if (form != null) capture();
        root.removeAllViews();
        if (fetching) {
            ProgressBar pb = new ProgressBar(this);
            pb.setIndeterminateTintList(android.content.res.ColorStateList.valueOf(LIME));
            root.addView(pb, new FrameLayout.LayoutParams(dp(36), dp(36), Gravity.CENTER));
            return;
        }
        ScrollView sv = new ScrollView(this);
        sv.setVerticalScrollBarEnabled(false);
        form = new LinearLayout(this);
        form.setOrientation(LinearLayout.VERTICAL);
        form.setPadding(dp(20), dp(14), dp(20), dp(14));
        sv.addView(form);
        root.addView(sv, new FrameLayout.LayoutParams(-1, -1));

        LinearLayout top = new LinearLayout(this);
        top.setGravity(Gravity.CENTER_VERTICAL);
        TextView back = Icons.view(this, Icons.ARROW_BACK_ROUNDED, 20, 0xFFFFFFFF);
        back.setBackground(Kit.rounded(this, 0x0DFFFFFF, 19));
        back.setOnClickListener(v -> finish());
        top.addView(back, new LinearLayout.LayoutParams(dp(38), dp(38)));
        top.addView(Kit.text(this, "My Profile", 22, 800, 0xFFFFFFFF), Kit.lp(this, -2, -2, 14, 0, 0, 0));
        form.addView(top, new LinearLayout.LayoutParams(-1, -2));

        form.addView(avatar(), Kit.lp(this, -2, -2, 0, 24, 0, 0));
        ((LinearLayout.LayoutParams) form.getChildAt(form.getChildCount() - 1).getLayoutParams()).gravity = Gravity.CENTER_HORIZONTAL;

        section("Account Information", 28);
        label("Full Name");
        form.addView(textField(name, pendingName, "Enter full name", Icons.PERSON_OUTLINE_ROUNDED, InputType.TYPE_CLASS_TEXT
                | InputType.TYPE_TEXT_FLAG_CAP_WORDS), Kit.lp(this, -1, -2, 0, 6, 0, 14));
        label("Email Address (Read Only)");
        form.addView(readOnlyField(email), Kit.lp(this, -1, -2, 0, 6, 0, 0));

        section("Body Metrics & Personal Info", 28);
        label("Gender");
        LinearLayout gRow = new LinearLayout(this);
        for (int i = 0; i < GENDERS.size(); i++) {
            String g = GENDERS.get(i);
            boolean sel = g.equals(gender);
            TextView t = Kit.text(this, g, 14, sel ? 700 : 600, sel ? 0xFF000000 : 0xFFFFFFFF);
            t.setGravity(Gravity.CENTER);
            t.setBackground(Kit.rounded(this, sel ? LIME : 0xFF161619, 14, 1, sel ? LIME : 0x1FFFFFFF));
            t.setOnClickListener(v -> { gender = g; render(); });
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(0, dp(46), 1f);
            if (i > 0) lp.setMarginStart(dp(12));
            gRow.addView(t, lp);
        }
        form.addView(gRow, Kit.lp(this, -1, -2, 0, 8, 0, 14));

        label("Age");
        form.addView(textField(age, pendingAge, "Enter age (years)", Icons.CALENDAR_MONTH_ROUNDED, InputType.TYPE_CLASS_NUMBER),
                Kit.lp(this, -1, -2, 0, 6, 0, 14));
        label("Height");
        form.addView(metricRow(height, pendingHeight, "Enter height", Icons.HEIGHT_ROUNDED, "CM", "FT", heightUnit, u -> heightUnit = u),
                Kit.lp(this, -1, -2, 0, 6, 0, 14));
        label("Weight");
        form.addView(metricRow(weight, pendingWeight, "Enter weight", Icons.MONITOR_WEIGHT_OUTLINED, "Kg", "Lbs", weightUnit, u -> weightUnit = u),
                Kit.lp(this, -1, -2, 0, 6, 0, 0));

        section("Fitness Preferences", 28);
        label("Main Fitness Goals");
        form.addView(goalChips(), Kit.lp(this, -1, -2, 0, 8, 0, 16));
        label("Activity Level");
        form.addView(dropdown(activity, ACTIVITY, Icons.DIRECTIONS_RUN_ROUNDED, v -> activity = v), Kit.lp(this, -1, -2, 0, 6, 0, 14));
        label("Workout Place");
        form.addView(dropdown(place, PLACES, Icons.FITNESS_CENTER_ROUNDED, v -> place = v), Kit.lp(this, -1, -2, 0, 6, 0, 14));
        label("Fitness Experience Level");
        form.addView(dropdown(level, LEVELS, Icons.TRENDING_UP_ROUNDED, v -> level = v), Kit.lp(this, -1, -2, 0, 6, 0, 14));
        label("Preferred Workout Duration");
        form.addView(dropdown(duration, DURATIONS, Icons.TIMER_OUTLINED, v -> duration = v), Kit.lp(this, -1, -2, 0, 6, 0, 14));
        label("Training Days Per Week");
        form.addView(dropdown(days, DAYS, Icons.CALENDAR_TODAY_ROUNDED, v -> days = v), Kit.lp(this, -1, -2, 0, 6, 0, 0));

        saveButton = new AuthUi.LoadingButton(this, "Save Profile", v -> save());
        saveButton.setLoading(saving);
        form.addView(saveButton.view, Kit.lp(this, -1, dp(52), 0, 36, 0, 20));
    }

    private interface Str { void set(String s); }

    private void section(String title, int topMargin) {
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        col.addView(Kit.text(this, title, 17, 800, LIME));
        View line = new View(this);
        line.setBackground(Kit.rounded(this, LIME, 2));
        col.addView(line, Kit.lp(this, dp(40), dp(2), 0, 4, 0, 0));
        form.addView(col, Kit.lp(this, -2, -2, 0, topMargin, 0, 14));
    }

    private void label(String s) { form.addView(Kit.text(this, s, 13, 500, 0xB3FFFFFF)); }

    private View avatar() {
        FrameLayout f = new FrameLayout(this);
        FrameLayout circle = new FrameLayout(this);
        GradientDrawable ring = new GradientDrawable();
        ring.setShape(GradientDrawable.OVAL);
        ring.setColor(0x26A3D223);
        ring.setStroke(Math.max(1, dp(2)), LIME);
        circle.setBackground(ring);
        circle.setClipToOutline(true);
        circle.addView(Icons.view(this, Icons.PERSON_ROUNDED, 52, LIME), new FrameLayout.LayoutParams(-1, -1));
        if (!avatarUrl.isEmpty()) {
            ImageView img = new ImageView(this);
            img.setScaleType(ImageView.ScaleType.CENTER_CROP);
            ImageLoader.load(img, avatarUrl, 0x00000000);
            circle.addView(img, new FrameLayout.LayoutParams(-1, -1));
        }
        if (uploading) {
            FrameLayout dim = new FrameLayout(this);
            dim.setBackgroundColor(0x8A000000);
            ProgressBar pb = new ProgressBar(this);
            pb.setIndeterminateTintList(android.content.res.ColorStateList.valueOf(LIME));
            dim.addView(pb, new FrameLayout.LayoutParams(dp(24), dp(24), Gravity.CENTER));
            circle.addView(dim, new FrameLayout.LayoutParams(-1, -1));
        }
        f.addView(circle, new FrameLayout.LayoutParams(dp(96), dp(96)));
        TextView cam = Icons.view(this, Icons.CAMERA_ALT_ROUNDED, 16, 0xFF000000);
        GradientDrawable badge = new GradientDrawable();
        badge.setShape(GradientDrawable.OVAL);
        badge.setColor(LIME);
        badge.setStroke(Math.max(1, dp(2)), 0xFF000000);
        cam.setBackground(badge);
        f.addView(cam, new FrameLayout.LayoutParams(dp(32), dp(32), Gravity.BOTTOM | Gravity.END));
        f.setOnClickListener(v -> { if (!uploading) picker.launch("image/*"); });
        return f;
    }

    private View textField(EditText[] out, String value, String hint, int icon, int inputType) {
        LinearLayout box = new LinearLayout(this);
        box.setGravity(Gravity.CENTER_VERTICAL);
        box.setBackground(Kit.rounded(this, 0xFF161619, 24, 1, 0x1FFFFFFF));
        box.setPadding(dp(14), 0, dp(14), 0);
        box.addView(Icons.view(this, icon, 20, 0x8AFFFFFF), new LinearLayout.LayoutParams(dp(24), dp(24)));
        EditText et = new EditText(this);
        et.setBackground(null);
        et.setSingleLine();
        et.setText(value);
        et.setHint(hint);
        et.setHintTextColor(0x61FFFFFF);
        et.setTextColor(0xFFFFFFFF);
        et.setTextSize(14);
        UiUtil.weight(et, 400);
        et.setInputType(inputType);
        et.setPadding(dp(12), dp(14), 0, dp(14));
        box.addView(et, new LinearLayout.LayoutParams(0, -2, 1f));
        out[0] = et;
        return box;
    }

    private View readOnlyField(String value) {
        LinearLayout box = new LinearLayout(this);
        box.setGravity(Gravity.CENTER_VERTICAL);
        box.setBackground(Kit.rounded(this, 0xFF101012, 24, 1, 0x0FFFFFFF));
        box.setPadding(dp(14), dp(14), dp(14), dp(14));
        box.addView(Icons.view(this, Icons.MAIL_OUTLINE_ROUNDED, 20, 0x61FFFFFF), new LinearLayout.LayoutParams(dp(24), dp(24)));
        box.addView(Kit.text(this, value, 14, 400, 0x8AFFFFFF), Kit.lp(this, 0, -2, 12, 0, 0, 0));
        ((LinearLayout.LayoutParams) box.getChildAt(1).getLayoutParams()).weight = 1f;
        box.addView(Icons.view(this, Icons.LOCK_OUTLINE_ROUNDED, 18, 0x61FFFFFF));
        return box;
    }

    private View metricRow(EditText[] out, String value, String hint, int icon, String u1, String u2, String unit, Str onUnit) {
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.addView(textField(out, value, hint, icon, InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL),
                new LinearLayout.LayoutParams(0, -2, 1f));

        LinearLayout toggle = new LinearLayout(this);
        toggle.setBackground(Kit.rounded(this, 0xFF161619, 24, 1, 0x1FFFFFFF));
        toggle.setPadding(dp(3), dp(3), dp(3), dp(3));
        for (String u : new String[]{u1, u2}) {
            boolean sel = u.equals(unit);
            TextView t = Kit.text(this, u, 13, sel ? 700 : 500, sel ? 0xFF000000 : 0x99FFFFFF);
            t.setGravity(Gravity.CENTER);
            t.setBackground(Kit.rounded(this, sel ? LIME : 0x00000000, 22));
            t.setPadding(dp(14), dp(10), dp(14), dp(10));
            t.setOnClickListener(v -> { onUnit.set(u); render(); });
            toggle.addView(t);
        }
        LinearLayout.LayoutParams tp = new LinearLayout.LayoutParams(-2, -2);
        tp.setMarginStart(dp(10));
        row.addView(toggle, tp);
        return row;
    }

    private View goalChips() {
        FlowLayoutView flow = new FlowLayoutView(this, dp(8), dp(8));
        for (String g : GOALS) {
            boolean sel = goals.contains(g);
            TextView t = Kit.text(this, g, 13, sel ? 700 : 500, sel ? 0xFF000000 : 0xB3FFFFFF);
            t.setBackground(Kit.rounded(this, sel ? LIME : 0xFF161619, 20, 1, sel ? LIME : 0x1FFFFFFF));
            t.setPadding(dp(14), dp(9), dp(14), dp(9));
            t.setOnClickListener(v -> {
                if (goals.contains(g)) goals.remove(g); else goals.add(g);
                render();
            });
            flow.addView(t);
        }
        return flow;
    }

    private View dropdown(String value, List<String> options, int icon, Str onChanged) {
        LinearLayout box = new LinearLayout(this);
        box.setGravity(Gravity.CENTER_VERTICAL);
        box.setBackground(Kit.rounded(this, 0xFF161619, 24, 1, 0x1FFFFFFF));
        box.setPadding(dp(16), dp(14), dp(16), dp(14));
        box.addView(Icons.view(this, icon, 20, 0x8AFFFFFF), new LinearLayout.LayoutParams(dp(24), dp(24)));
        box.addView(Kit.text(this, value, 14, 400, 0xFFFFFFFF), Kit.lp(this, 0, -2, 12, 0, 0, 0));
        ((LinearLayout.LayoutParams) box.getChildAt(1).getLayoutParams()).weight = 1f;
        box.addView(Icons.view(this, Icons.KEYBOARD_ARROW_DOWN_ROUNDED, 22, 0x8AFFFFFF));
        box.setOnClickListener(v -> pick(value, options, onChanged));
        return box;
    }

    private void pick(String current, List<String> options, Str onChanged) {
        capture();
        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        GradientDrawable bg = new GradientDrawable();
        bg.setColor(0xFF161619);
        float r = dp(24);
        bg.setCornerRadii(new float[]{r, r, r, r, 0, 0, 0, 0});
        content.setBackground(bg);
        content.setPadding(dp(16), dp(12), dp(16), dp(36));
        View handle = new View(this);
        handle.setBackground(Kit.rounded(this, 0x3DFFFFFF, 2));
        LinearLayout.LayoutParams hp = new LinearLayout.LayoutParams(dp(38), dp(4));
        hp.gravity = Gravity.CENTER_HORIZONTAL;
        content.addView(handle, hp);

        BottomSheetDialog dialog = new BottomSheetDialog(this);
        dialog.setContentView(content);
        View s = dialog.findViewById(com.google.android.material.R.id.design_bottom_sheet);
        if (s != null) s.setBackgroundColor(0x00000000);
        dialog.getBehavior().setState(BottomSheetBehavior.STATE_EXPANDED);
        for (String o : options) {
            boolean sel = o.equals(current);
            LinearLayout row = new LinearLayout(this);
            row.setGravity(Gravity.CENTER_VERTICAL);
            row.setPadding(dp(16), dp(14), dp(16), dp(14));
            row.addView(Kit.text(this, o, 15, sel ? 700 : 500, sel ? LIME : 0xFFFFFFFF), new LinearLayout.LayoutParams(0, -2, 1f));
            if (sel) row.addView(Icons.view(this, Icons.CHECK_CIRCLE_ROUNDED, 20, LIME));
            row.setOnClickListener(v -> { dialog.dismiss(); onChanged.set(o); render(); });
            content.addView(row, Kit.lp(this, -1, -2, 0, o.equals(options.get(0)) ? 16 : 0, 0, 0));
        }
        dialog.show();
    }

    /** Minimal wrapping layout for the goal chips. */
    static final class FlowLayoutView extends android.view.ViewGroup {
        private final int hGap, vGap;

        FlowLayoutView(android.content.Context c, int hGap, int vGap) {
            super(c);
            this.hGap = hGap;
            this.vGap = vGap;
        }

        @Override
        protected void onMeasure(int wSpec, int hSpec) {
            int maxW = MeasureSpec.getSize(wSpec);
            int x = 0, y = 0, rowH = 0;
            for (int i = 0; i < getChildCount(); i++) {
                View ch = getChildAt(i);
                ch.measure(MeasureSpec.makeMeasureSpec(maxW, MeasureSpec.AT_MOST), MeasureSpec.UNSPECIFIED);
                int cw = ch.getMeasuredWidth(), chh = ch.getMeasuredHeight();
                if (x > 0 && x + cw > maxW) { x = 0; y += rowH + vGap; rowH = 0; }
                x += cw + hGap;
                rowH = Math.max(rowH, chh);
            }
            setMeasuredDimension(maxW, y + rowH);
        }

        @Override
        protected void onLayout(boolean changed, int l, int t, int r, int b) {
            int maxW = r - l;
            int x = 0, y = 0, rowH = 0;
            for (int i = 0; i < getChildCount(); i++) {
                View ch = getChildAt(i);
                int cw = ch.getMeasuredWidth(), chh = ch.getMeasuredHeight();
                if (x > 0 && x + cw > maxW) { x = 0; y += rowH + vGap; rowH = 0; }
                ch.layout(x, y, x + cw, y + chh);
                x += cw + hGap;
                rowH = Math.max(rowH, chh);
            }
        }
    }
}
