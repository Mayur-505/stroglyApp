package com.strongly.strongly.ui;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.google.gson.JsonObject;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.net.ApiConstants;
import com.strongly.strongly.util.Session;
import com.strongly.strongly.util.Tr;

/** Profile tab: account banner or backup card, settings list, logout (Flutter's ProfileScreen). */
public class ProfileFragment extends Fragment {
    private static final int LIME = Kit.LIME;

    private LinearLayout content;
    private String renderedLanguage;

    @Nullable @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle state) {
        Context c = requireContext();
        ScrollView sv = new ScrollView(c);
        sv.setVerticalScrollBarEnabled(false);
        content = new LinearLayout(c);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setPadding(Kit.dp(c, 20), Kit.dp(c, 10), Kit.dp(c, 20), Kit.dp(c, 30));
        sv.addView(content, new ViewGroup.LayoutParams(-1, -2));
        render();
        fetchProfile();
        return sv;
    }

    @Override
    public void onResume() {
        super.onResume();
        // returning from login / edit profile / language changes
        render();
    }

    private void fetchProfile() {
        if (Session.isGuestOrAnonymous()) return;
        ApiClient.get().get(ApiConstants.ME, null, r -> {
            if (!isAdded() || !r.isOk() || r.data == null || !r.data.isJsonObject()) return;
            JsonObject d = r.data.getAsJsonObject();
            if (d.has("data") && d.get("data").isJsonObject()) d = d.getAsJsonObject("data");
            Session.save(Session.token() != null ? Session.token() : "", Session.userId() != null ? Session.userId() : "",
                    false, UiUtil.str(d, "name"), UiUtil.str(d, "email"), UiUtil.str(d, "avatar"));
            render();
        });
    }

    // ------------------------------------------------------------------ rendering

    private void render() {
        if (!isAdded()) return;
        Context c = requireContext();
        content.removeAllViews();
        boolean guest = Session.isGuestOrAnonymous();
        String userName = Session.userName() != null ? Session.userName() : "Athlete";

        LinearLayout top = new LinearLayout(c);
        top.setGravity(Gravity.CENTER_VERTICAL);
        TextView back = Icons.view(c, Icons.ARROW_BACK_ROUNDED, 22, 0xFFFFFFFF);
        back.setOnClickListener(v -> { if (getActivity() instanceof HomeActivity) ((HomeActivity) getActivity()).goHome(); });
        top.addView(back, new LinearLayout.LayoutParams(Kit.dp(c, 38), Kit.dp(c, 38)));
        top.addView(Kit.text(c, Tr.t("my_profile"), 22, 800, 0xFFFFFFFF), Kit.lp(c, 0, -2, 8, 0, 0, 0));
        ((LinearLayout.LayoutParams) top.getChildAt(1).getLayoutParams()).weight = 1f;

        LinearLayout premium = new LinearLayout(c);
        premium.setGravity(Gravity.CENTER_VERTICAL);
        premium.setBackground(Kit.rounded(c, 0xFF1F290F, 20, 1.2f, LIME));
        premium.setPadding(Kit.dp(c, 14), Kit.dp(c, 8), Kit.dp(c, 14), Kit.dp(c, 8));
        premium.addView(Icons.view(c, Icons.WORKSPACE_PREMIUM_ROUNDED, 16, LIME));
        premium.addView(Kit.text(c, Tr.t("go_premium"), 12, 700, LIME), Kit.lp(c, -2, -2, 6, 0, 0, 0));
        premium.setOnClickListener(v -> startActivity(new Intent(c, GoPremiumActivity.class)));
        top.addView(premium);
        content.addView(top, new LinearLayout.LayoutParams(-1, -2));

        if (guest) {
            content.addView(backupCard(c), Kit.lp(c, -1, -2, 0, 20, 0, 24));
        } else {
            content.addView(accountBanner(c, userName), Kit.lp(c, -1, -2, 0, 20, 0, 24));
        }

        content.addView(Kit.text(c, Tr.t("setting"), 18, 700, 0xFFFFFFFF), Kit.lp(c, -2, -2, 0, 0, 0, 12));
        content.addView(settingsCard(c, guest));
    }

    private View backupCard(Context c) {
        LinearLayout card = new LinearLayout(c);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setBackground(Kit.rounded(c, 0xFF161619, 18, 1, 0x0FFFFFFF));
        card.setPadding(Kit.dp(c, 18), Kit.dp(c, 18), Kit.dp(c, 18), Kit.dp(c, 18));
        card.addView(Kit.text(c, "Backup & Restore", 17, 700, 0xFFFFFFFF));
        card.addView(Kit.text(c, "Synchronize your data", 13, 400, 0x61FFFFFF), Kit.lp(c, -2, -2, 0, 4, 0, 0));

        LinearLayout row = new LinearLayout(c);
        TextView login = Kit.text(c, "Log In", 15, 700, 0xFF111113);
        login.setGravity(Gravity.CENTER);
        login.setBackground(Kit.rounded(c, LIME, 12));
        login.setOnClickListener(v -> startActivity(new Intent(c, LoginActivity.class)));
        row.addView(login, new LinearLayout.LayoutParams(0, Kit.dp(c, 46), 1f));
        TextView signin = Kit.text(c, "Sign In", 15, 700, 0xFFFFFFFF);
        signin.setGravity(Gravity.CENTER);
        signin.setBackground(Kit.rounded(c, 0xFF38383B, 12, 1, 0x1FFFFFFF));
        signin.setOnClickListener(v -> startActivity(new Intent(c, SignupActivity.class)));
        LinearLayout.LayoutParams sp = new LinearLayout.LayoutParams(0, Kit.dp(c, 46), 1f);
        sp.setMarginStart(Kit.dp(c, 12));
        row.addView(signin, sp);
        card.addView(row, Kit.lp(c, -1, -2, 0, 16, 0, 0));
        return card;
    }

    private View accountBanner(Context c, String name) {
        LinearLayout card = new LinearLayout(c);
        card.setGravity(Gravity.CENTER_VERTICAL);
        card.setBackground(Kit.rounded(c, 0xFF161619, 18, 1.2f, 0x40A3D223));
        card.setPadding(Kit.dp(c, 16), Kit.dp(c, 16), Kit.dp(c, 16), Kit.dp(c, 16));

        FrameLayout avatar = new FrameLayout(c);
        GradientDrawable ring = new GradientDrawable();
        ring.setShape(GradientDrawable.OVAL);
        ring.setColor(0x26A3D223);
        ring.setStroke(Math.max(1, Kit.dp(c, 1.5f)), 0x80A3D223);
        avatar.setBackground(ring);
        avatar.setClipToOutline(true);
        String url = Session.userAvatar();
        TextView person = Icons.view(c, Icons.PERSON_ROUNDED, 28, LIME);
        avatar.addView(person, new FrameLayout.LayoutParams(-1, -1));
        if (url != null && !url.isEmpty()) {
            ImageView img = new ImageView(c);
            img.setScaleType(ImageView.ScaleType.CENTER_CROP);
            ImageLoader.load(img, url, 0x00000000);
            avatar.addView(img, new FrameLayout.LayoutParams(-1, -1));
        }
        card.addView(avatar, new LinearLayout.LayoutParams(Kit.dp(c, 48), Kit.dp(c, 48)));

        LinearLayout col = new LinearLayout(c);
        col.setOrientation(LinearLayout.VERTICAL);
        col.addView(Kit.text(c, name, 17, 800, 0xFFFFFFFF));
        LinearLayout pill = new LinearLayout(c);
        pill.setGravity(Gravity.CENTER_VERTICAL);
        pill.setBackground(Kit.rounded(c, 0x1FA3D223, 10));
        pill.setPadding(Kit.dp(c, 8), Kit.dp(c, 3), Kit.dp(c, 8), Kit.dp(c, 3));
        View dot = new View(c);
        GradientDrawable g = new GradientDrawable();
        g.setShape(GradientDrawable.OVAL);
        g.setColor(LIME);
        dot.setBackground(g);
        pill.addView(dot, new LinearLayout.LayoutParams(Kit.dp(c, 6), Kit.dp(c, 6)));
        pill.addView(Kit.text(c, "Synchronized Account", 11, 700, LIME), Kit.lp(c, -2, -2, 6, 0, 0, 0));
        col.addView(pill, Kit.lp(c, -2, -2, 0, 4, 0, 0));
        card.addView(col, Kit.lp(c, 0, -2, 14, 0, 0, 0));
        ((LinearLayout.LayoutParams) col.getLayoutParams()).weight = 1f;
        return card;
    }

    private View settingsCard(Context c, boolean guest) {
        LinearLayout card = new LinearLayout(c);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setBackground(Kit.rounded(c, 0xFF161619, 18, 1, 0x0FFFFFFF));
        card.setPadding(Kit.dp(c, 16), Kit.dp(c, 12), Kit.dp(c, 16), Kit.dp(c, 12));

        String[][] items = guest
                ? new String[][]{{"login_signup", "Log In / Sign Up"}, {"language", "Language"}}
                : new String[][]{{"my_profile", "My Profile"}, {"language", "Language"}, {"logout", "Log Out"}};
        int[] icons = guest
                ? new int[]{Icons.MOOD_ROUNDED, Icons.TRANSLATE_ROUNDED}
                : new int[]{Icons.MOOD_ROUNDED, Icons.TRANSLATE_ROUNDED, Icons.LOGOUT_ROUNDED};
        for (int i = 0; i < items.length; i++) {
            String id = items[i][0];
            boolean danger = id.equals("logout") || id.equals("delete_account");
            LinearLayout row = new LinearLayout(c);
            row.setGravity(Gravity.CENTER_VERTICAL);
            row.setPadding(0, Kit.dp(c, 4), 0, Kit.dp(c, 4));
            TextView ic = Icons.view(c, icons[i], 20, danger ? 0xFFFF5B5B : LIME);
            ic.setBackground(Kit.rounded(c, danger ? 0xFF2C1414 : 0xFF233010, 12));
            row.addView(ic, new LinearLayout.LayoutParams(Kit.dp(c, 38), Kit.dp(c, 38)));
            String label = !Tr.t(id).equals(id) ? Tr.t(id) : items[i][1];
            row.addView(Kit.text(c, label, 14, 600, danger ? 0xFFFF5B5B : 0xFFFFFFFF), Kit.lp(c, 0, -2, 14, 0, 0, 0));
            ((LinearLayout.LayoutParams) row.getChildAt(1).getLayoutParams()).weight = 1f;
            row.addView(Icons.view(c, Icons.CHEVRON_RIGHT_ROUNDED, 20, danger ? 0xFFFF5B5B : 0x61FFFFFF));
            row.setOnClickListener(v -> onSetting(id));
            card.addView(row, Kit.lp(c, -1, -2, 0, 0, 0, i == items.length - 1 ? 0 : 12));
        }
        return card;
    }

    private void onSetting(String id) {
        Context c = requireContext();
        switch (id) {
            case "login_signup":
                startActivity(new Intent(c, LoginActivity.class));
                break;
            case "my_profile":
                startActivity(new Intent(c, EditProfileActivity.class));
                break;
            case "language": {
                Intent i = new Intent(c, LanguageActivity.class);
                i.putExtra(LanguageActivity.EXTRA_FROM_SETTINGS, true);
                startActivity(i);
                break;
            }
            case "logout":
                Dialogs.danger(c, Icons.LOGOUT_ROUNDED, "Log Out",
                        "Are you sure you want to log out of your account? Your progress will remain saved in your account.",
                        "Log Out", this::logout);
                break;
            default:
                break;
        }
    }

    private void logout() {
        ApiClient.get().post(ApiConstants.LOGOUT, null, r -> {
            Session.clear();
            // re-initialize a guest session
            JsonObject body = new JsonObject();
            body.addProperty("language", Session.language());
            ApiClient.get().post(ApiConstants.GUEST_LOGIN, body, g -> {
                if (g.isOk()) {
                    JsonObject d = g.dataObject();
                    if (d.has("token") && d.has("user") && d.get("user").isJsonObject()) {
                        JsonObject u = d.getAsJsonObject("user");
                        Session.save(d.get("token").getAsString(), UiUtil.str(u, "_id") != null ? UiUtil.str(u, "_id") : "",
                                true, UiUtil.str(u, "name"), null, null);
                    }
                }
                if (!isAdded()) return;
                android.widget.Toast.makeText(requireContext(), "Logged out successfully", android.widget.Toast.LENGTH_SHORT).show();
                Intent home = new Intent(requireContext(), HomeActivity.class);
                home.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                startActivity(home);
            });
        });
    }
}
