package com.strongly.strongly.ui;

import android.content.Intent;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.style.ForegroundColorSpan;
import android.text.style.StyleSpan;
import android.text.style.UnderlineSpan;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.strongly.strongly.billing.PremiumService;

import java.util.ArrayList;
import java.util.List;

/** Paywall with plans, benefits and subscription management (Flutter's GoPremiumScreen). */
public class GoPremiumActivity extends AppCompatActivity {
    private static final int LIME = Kit.LIME;
    private static final int INK = 0xFF0A0A0B;

    private final PremiumService premium = PremiumService.get();
    private boolean loading = true, purchasing = false;
    private PremiumService.Plans data = new PremiumService.Plans();
    private String selectedPlanId;
    private FrameLayout root;
    private final Runnable onPremiumChanged = this::render;

    /** Flutter's GoPremiumScreen.open: already-premium users skip the screen. Returns true if no screen was needed. */
    public static boolean open(android.content.Context c) {
        if (PremiumService.get().isPremium()) return true;
        c.startActivity(new Intent(c, GoPremiumActivity.class));
        return false;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        UiUtil.edgeToEdge(this);
        root = new FrameLayout(this);
        root.setBackgroundColor(INK);
        setContentView(root);
        premium.addListener(onPremiumChanged);
        premium.refreshStatus(null);
        render();
        fetchPlans();
    }

    @Override
    protected void onDestroy() {
        premium.removeListener(onPremiumChanged);
        super.onDestroy();
    }

    private int dp(float v) { return Kit.dp(this, v); }

    private PremiumService.Plan selectedPlan() {
        for (PremiumService.Plan p : data.plans) if (p.id.equals(selectedPlanId)) return p;
        return data.plans.isEmpty() ? null : data.plans.get(0);
    }

    private void fetchPlans() {
        premium.loadPlans(result -> {
            if (isFinishing() || isDestroyed()) return;
            data = result;
            if (selectedPlanId == null && !data.plans.isEmpty()) {
                PremiumService.Plan pick = data.plans.get(0);
                for (PremiumService.Plan p : data.plans) if (p.isBestValue) { pick = p; break; }
                selectedPlanId = pick.id;
            }
            loading = false;
            render();
        });
    }

    // ------------------------------------------------------------------ actions

    private void message(String text, boolean success) {
        com.google.android.material.snackbar.Snackbar sb = com.google.android.material.snackbar.Snackbar.make(root, text, 3000);
        sb.setBackgroundTint(0xFF1F1F23);
        sb.setTextColor(success ? LIME : 0xFFFFFFFF);
        sb.show();
    }

    private void goPremium() {
        PremiumService.Plan plan = selectedPlan();
        if (plan == null) { message("Plans are not available right now. Please try again.", false); return; }
        purchasing = true;
        render();
        premium.buy(this, plan, result -> {
            if (isFinishing() || isDestroyed()) return;
            purchasing = false;
            if (result.success && premium.isPremium()) {
                android.widget.Toast.makeText(this, result.message != null ? result.message : "Premium Activated Successfully! 🎉",
                        android.widget.Toast.LENGTH_LONG).show();
                finish();
            } else {
                render();
                if (result.message != null && !result.message.equals("Purchase canceled.")) message(result.message, false);
            }
        });
    }

    private void restore() {
        purchasing = true;
        render();
        premium.restore(() -> {
            // the store results arrive asynchronously; give the backend a moment, as Flutter does
            root.postDelayed(() -> premium.refreshStatus(() -> {
                if (isFinishing() || isDestroyed()) return;
                purchasing = false;
                if (premium.isPremium()) {
                    android.widget.Toast.makeText(this, "Purchases restored. Premium active 🎉", android.widget.Toast.LENGTH_LONG).show();
                    finish();
                } else {
                    render();
                    message("No active subscription found.", false);
                }
            }), 3000);
        });
    }

    private void cancelSubscription() {
        Dialogs.choice(this, "Cancel subscription?",
                "Auto-renew will be turned off. You keep Premium until the end of the current period.",
                "Keep Premium", "Cancel Subscription", () -> {
                    purchasing = true;
                    render();
                    premium.cancel(result -> {
                        if (isFinishing() || isDestroyed()) return;
                        purchasing = false;
                        render();
                        if (result.manageUrl != null) {
                            try { startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(result.manageUrl))); } catch (Exception ignored) { }
                            return;
                        }
                        message(result.message != null ? result.message
                                : (result.success ? "Subscription canceled." : "Could not cancel subscription."), result.success);
                    });
                });
    }

    // ------------------------------------------------------------------ rendering

    private String priceLine(PremiumService.Plan p) {
        String price = p.interval.equals("lifetime") ? p.displayPrice() : p.displayPrice() + "/" + p.intervalLabel();
        return p.trialDays > 0 ? "Free " + p.trialDays + "-day trial, then " + price : price;
    }

    private void render() {
        root.removeAllViews();
        if (loading && data.benefits.isEmpty()) {
            ProgressBar pb = new ProgressBar(this);
            pb.setIndeterminateTintList(android.content.res.ColorStateList.valueOf(LIME));
            root.addView(pb, new FrameLayout.LayoutParams(dp(36), dp(36), Gravity.CENTER));
            return;
        }
        boolean isPremium = premium.isPremium();
        PremiumService.Plan sel = selectedPlan();
        String ctaTitle, ctaSub;
        Runnable ctaAction;
        if (isPremium) {
            ctaTitle = premium.autoRenewing() ? "Cancel Subscription" : "Done";
            ctaSub = premium.autoRenewing() ? "Premium stays active until the period ends" : "";
            ctaAction = premium.autoRenewing() ? this::cancelSubscription : this::finish;
        } else {
            ctaTitle = "Go Premium";
            ctaSub = sel != null ? priceLine(sel) : data.trialOffer;
            ctaAction = this::goPremium;
        }

        ScrollView sv = new ScrollView(this);
        sv.setVerticalScrollBarEnabled(false);
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        col.addView(hero());

        LinearLayout body = new LinearLayout(this);
        body.setOrientation(LinearLayout.VERTICAL);
        body.setPadding(dp(22), 0, dp(22), 0);
        TextView h1 = Kit.text(this, "Start Strong", 34, 900, 0xFFFFFFFF);
        h1.setLineSpacing(0, 0.85f);
        body.addView(h1);
        SpannableString h2 = new SpannableString("Become Stronger.");
        h2.setSpan(new ForegroundColorSpan(LIME), 7, h2.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        h2.setSpan(new StyleSpan(Typeface.ITALIC), 7, h2.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        h2.setSpan(new UnderlineSpan(), 7, h2.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        TextView h2v = Kit.text(this, "", 34, 900, 0xFFFFFFFF);
        h2v.setText(h2);
        body.addView(h2v);

        LinearLayout benefits = new LinearLayout(this);
        benefits.setOrientation(LinearLayout.VERTICAL);
        for (String b : data.benefits) {
            LinearLayout row = new LinearLayout(this);
            row.setGravity(Gravity.CENTER_VERTICAL);
            TextView ck = Icons.view(this, Icons.CHECK_PLAIN, 14, INK);
            GradientDrawable g = new GradientDrawable();
            g.setShape(GradientDrawable.OVAL);
            g.setColor(LIME);
            ck.setBackground(g);
            row.addView(ck, new LinearLayout.LayoutParams(dp(20), dp(20)));
            row.addView(Kit.text(this, b, 14, 500, 0xFFFFFFFF), Kit.lp(this, 0, -2, 12, 0, 0, 0));
            ((LinearLayout.LayoutParams) row.getChildAt(1).getLayoutParams()).weight = 1f;
            benefits.addView(row, Kit.lp(this, -1, -2, 0, 0, 0, 14));
        }
        body.addView(benefits, Kit.lp(this, -1, -2, 0, 22, 0, 0));

        LinearLayout plans = new LinearLayout(this);
        plans.setOrientation(LinearLayout.VERTICAL);
        if (isPremium) plans.addView(activeCard());
        else for (PremiumService.Plan p : data.plans) plans.addView(planCard(p, sel != null && p.id.equals(sel.id)));
        body.addView(plans, Kit.lp(this, -1, -2, 0, 12, 0, 0));

        LinearLayout terms = new LinearLayout(this);
        terms.setOrientation(LinearLayout.VERTICAL);
        for (String[] t : data.terms) {
            LinearLayout item = new LinearLayout(this);
            item.setOrientation(LinearLayout.VERTICAL);
            item.addView(Kit.text(this, t[0], 12, 700, 0xB3FFFFFF));
            TextView d = Kit.text(this, t[1], 11, 400, 0x61FFFFFF);
            d.setLineSpacing(0, 1.15f);
            item.addView(d, Kit.lp(this, -2, -2, 0, 4, 0, 0));
            terms.addView(item, Kit.lp(this, -1, -2, 0, 0, 0, 14));
        }
        body.addView(terms, Kit.lp(this, -1, -2, 0, 24, 0, 0));
        col.addView(body);
        col.setPadding(0, 0, 0, dp(140));
        UiUtil.padForInsets(col, false, true);
        sv.addView(col);
        root.addView(sv, new FrameLayout.LayoutParams(-1, -1));

        root.addView(cta(isPremium, ctaTitle, ctaSub, ctaAction), new FrameLayout.LayoutParams(-1, -2, Gravity.BOTTOM));
    }

    private View hero() {
        FrameLayout hero = new FrameLayout(this);
        TopCropImageView img = new TopCropImageView(this);
        ImageLoader.load(img, "assets/images/premium_athletes.jpg", 0xFF1B1B1E);
        hero.addView(img, new FrameLayout.LayoutParams(-1, dp(360)));
        View shade = new View(this);
        shade.setBackground(Kit.stops(new int[]{0x59000000, 0x00000000, 0xD90A0A0B, 0xFF0A0A0B},
                new float[]{0f, 0.45f, 0.82f, 1f}, true));
        hero.addView(shade, new FrameLayout.LayoutParams(-1, dp(360)));
        TextView back = Icons.view(this, Icons.ARROW_BACK_ROUNDED, 20, 0xFFFFFFFF);
        back.setBackground(Kit.rounded(this, 0x80000000, 19, 1, 0x1FFFFFFF));
        back.setOnClickListener(v -> finish());
        FrameLayout.LayoutParams bp = new FrameLayout.LayoutParams(dp(38), dp(38), Gravity.TOP | Gravity.START);
        bp.topMargin = dp(48);
        bp.setMarginStart(dp(20));
        hero.addView(back, bp);
        return hero;
    }

    private View planCard(PremiumService.Plan p, boolean selected) {
        LinearLayout card = new LinearLayout(this);
        card.setGravity(Gravity.CENTER_VERTICAL);
        card.setBackground(Kit.rounded(this, selected ? 0xFF1F290F : 0xFF141416, 16, selected ? 1.6f : 1f, selected ? LIME : 0x1FFFFFFF));
        card.setPadding(dp(16), dp(14), dp(16), dp(14));
        card.addView(Icons.view(this, selected ? Icons.RADIO_CHECKED_ROUNDED : Icons.RADIO_OFF_ROUNDED, 22, selected ? LIME : 0x61FFFFFF),
                new LinearLayout.LayoutParams(dp(22), dp(22)));

        LinearLayout mid = new LinearLayout(this);
        mid.setOrientation(LinearLayout.VERTICAL);
        LinearLayout titleRow = new LinearLayout(this);
        titleRow.setGravity(Gravity.CENTER_VERTICAL);
        titleRow.addView(Kit.text(this, p.title, 14, 700, 0xFFFFFFFF));
        if (p.isBestValue) {
            TextView best = Kit.text(this, "BEST VALUE", 9, 800, INK);
            best.setBackground(Kit.rounded(this, LIME, 10));
            best.setPadding(dp(8), dp(2), dp(8), dp(2));
            titleRow.addView(best, Kit.lp(this, -2, -2, 8, 0, 0, 0));
        }
        mid.addView(titleRow);
        if (p.trialDays > 0) mid.addView(Kit.text(this, p.trialDays + "-day free trial", 11, 600, LIME), Kit.lp(this, -2, -2, 0, 2, 0, 0));
        card.addView(mid, Kit.lp(this, 0, -2, 12, 0, 8, 0));
        ((LinearLayout.LayoutParams) mid.getLayoutParams()).weight = 1f;

        String price = p.interval.equals("lifetime") ? p.displayPrice() : p.displayPrice() + "/" + p.intervalLabel();
        card.addView(Kit.text(this, price, 14, 800, 0xFFFFFFFF));
        card.setOnClickListener(v -> { selectedPlanId = p.id; render(); });
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(-1, -2);
        lp.bottomMargin = dp(12);
        card.setLayoutParams(lp);
        return card;
    }

    private View activeCard() {
        LinearLayout card = new LinearLayout(this);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setBackground(Kit.rounded(this, 0xFF1F290F, 16, 1.2f, LIME));
        card.setPadding(dp(16), dp(16), dp(16), dp(16));
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.addView(Icons.view(this, Icons.WORKSPACE_PREMIUM_ROUNDED, 20, LIME));
        row.addView(Kit.text(this, premium.isTrial() ? "Free trial active" : "Premium active", 16, 800, LIME), Kit.lp(this, -2, -2, 8, 0, 0, 0));
        card.addView(row);
        String date = premium.expiresAtFormatted();
        card.addView(Kit.text(this, premium.autoRenewing() ? "Renews on " + date : "Premium until " + date + " (auto-renew off)",
                13, 400, 0xB3FFFFFF), Kit.lp(this, -2, -2, 0, 6, 0, 0));
        return card;
    }

    private View cta(boolean isPremium, String title, String sub, Runnable action) {
        LinearLayout wrap = new LinearLayout(this);
        wrap.setOrientation(LinearLayout.VERTICAL);
        wrap.setGravity(Gravity.CENTER_HORIZONTAL);
        wrap.setBackground(Kit.stops(new int[]{0x000A0A0B, 0xF20A0A0B, 0xFF0A0A0B}, new float[]{0f, 0.5f, 1f}, true));
        wrap.setPadding(dp(20), dp(12), dp(20), dp(18));
        UiUtil.padForInsets(wrap, false, true);

        LinearLayout btn = new LinearLayout(this);
        btn.setOrientation(LinearLayout.VERTICAL);
        btn.setGravity(Gravity.CENTER);
        btn.setBackground(Kit.rounded(this, LIME, 28));
        btn.setElevation(dp(6));
        btn.setPadding(0, dp(12), 0, dp(12));
        if (purchasing) {
            ProgressBar pb = new ProgressBar(this);
            pb.setIndeterminateTintList(android.content.res.ColorStateList.valueOf(INK));
            btn.addView(pb, new LinearLayout.LayoutParams(dp(22), dp(22)));
        } else {
            LinearLayout line = new LinearLayout(this);
            line.setGravity(Gravity.CENTER);
            line.addView(Icons.view(this, Icons.WORKSPACE_PREMIUM_ROUNDED, 18, INK));
            line.addView(Kit.text(this, title, 16, 800, INK), Kit.lp(this, -2, -2, 6, 0, 0, 0));
            btn.addView(line);
            if (!sub.isEmpty()) btn.addView(Kit.text(this, sub, 11, 600, INK), Kit.lp(this, -2, -2, 0, 2, 0, 0));
            btn.setOnClickListener(v -> action.run());
        }
        wrap.addView(btn, new LinearLayout.LayoutParams(-1, -2));

        if (isPremium) {
            wrap.addView(Kit.text(this, "You can also manage it from your store account", 11, 500, 0x61FFFFFF), Kit.lp(this, -2, -2, 0, 8, 0, 0));
        } else {
            String a = "Cancel anytime  •  ", b = "Restore purchases";
            SpannableString s = new SpannableString(a + b);
            s.setSpan(new ForegroundColorSpan(0x61FFFFFF), 0, a.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            s.setSpan(new ForegroundColorSpan(0xB3FFFFFF), a.length(), s.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            s.setSpan(new StyleSpan(Typeface.BOLD), a.length(), s.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            s.setSpan(new UnderlineSpan(), a.length(), s.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            TextView t = Kit.text(this, "", 11, 500, 0x61FFFFFF);
            t.setText(s);
            t.setOnClickListener(v -> { if (!purchasing) restore(); });
            wrap.addView(t, Kit.lp(this, -2, -2, 0, 8, 0, 0));
        }
        return wrap;
    }
}
