package com.strongly.strongly.ui;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

/**
 * Shared base activity for legal pages (Privacy Policy, Terms of Service)
 * matching the modern, card-based layout from SlimTrack without external website buttons.
 */
public abstract class LegalPageActivity extends AppCompatActivity {
    protected static final int LIME = 0xFFA3D223;
    protected static final int BG_DARK = 0xFF0A0D12;
    protected static final int CARD_BG = 0xFF161619;
    protected static final int CARD_BORDER = 0x1AFFFFFF;

    protected LinearLayout content;

    protected abstract String headerTitle();
    protected abstract String headerSubtitle();
    protected abstract View heroCard();
    protected abstract void buildSections();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        UiUtil.edgeToEdge(this);

        FrameLayout root = new FrameLayout(this);
        root.setBackgroundColor(BG_DARK);

        LinearLayout mainCol = new LinearLayout(this);
        mainCol.setOrientation(LinearLayout.VERTICAL);
        UiUtil.padForInsets(mainCol, true, true);
        root.addView(mainCol, new FrameLayout.LayoutParams(-1, -1));

        // Top Header Bar
        mainCol.addView(buildHeaderBar(), new LinearLayout.LayoutParams(-1, -2));

        // Scroll Content
        ScrollView scroll = new ScrollView(this);
        scroll.setVerticalScrollBarEnabled(false);
        scroll.setClipToPadding(false);

        content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setPadding(dp(20), dp(12), dp(20), dp(32));
        scroll.addView(content, new FrameLayout.LayoutParams(-1, -2));
        mainCol.addView(scroll, new LinearLayout.LayoutParams(-1, 0, 1f));

        // Hero Card
        content.addView(heroCard(), lp(-1, -2, 0, 0, 0, 16));

        // Build Sections
        buildSections();

        // Contact Box
        content.addView(buildContactBox(), lp(-1, -2, 0, 8, 0, 16));

        setContentView(root);
    }

    private View buildHeaderBar() {
        LinearLayout bar = new LinearLayout(this);
        bar.setGravity(Gravity.CENTER_VERTICAL);
        bar.setPadding(dp(16), dp(16), dp(16), dp(12));

        TextView back = Icons.view(this, Icons.ARROW_BACK_ROUNDED, 22, 0xFFFFFFFF);
        back.setGravity(Gravity.CENTER);
        back.setBackground(Kit.rounded(this, 0x1FFFFFFF, 12));
        back.setOnClickListener(v -> finish());
        bar.addView(back, new LinearLayout.LayoutParams(dp(40), dp(40)));

        LinearLayout titleCol = new LinearLayout(this);
        titleCol.setOrientation(LinearLayout.VERTICAL);
        titleCol.setPadding(dp(12), 0, 0, 0);

        TextView title = text(headerTitle(), 19, 800, 0xFFFFFFFF);
        TextView sub = text(headerSubtitle(), 12, 400, 0x8AFFFFFF);
        titleCol.addView(title);
        titleCol.addView(sub);
        bar.addView(titleCol, new LinearLayout.LayoutParams(0, -2, 1f));

        return bar;
    }

    protected View heroShell(View inner) {
        FrameLayout outer = new FrameLayout(this);
        outer.setPadding(dp(1), dp(1), dp(1), dp(1));
        outer.setBackground(Kit.rounded(this, 0x00000000, 20, 1, 0x33A3D223));

        FrameLayout box = new FrameLayout(this);
        box.setBackground(Kit.rounded(this, CARD_BG, 19));
        box.setPadding(dp(18), dp(18), dp(18), dp(18));
        box.addView(inner, new FrameLayout.LayoutParams(-1, -2));
        outer.addView(box, new FrameLayout.LayoutParams(-1, -2));
        return outer;
    }

    protected View pillTag(int icon, String label, int color) {
        LinearLayout p = new LinearLayout(this);
        p.setGravity(Gravity.CENTER_VERTICAL);
        p.setBackground(Kit.rounded(this, (color & 0x00FFFFFF) | 0x1A000000, 8, 1, (color & 0x00FFFFFF) | 0x40000000));
        p.setPadding(dp(10), dp(4), dp(10), dp(4));
        if (icon != 0) {
            p.addView(Icons.view(this, icon, 12, color));
            View s = new View(this);
            p.addView(s, new LinearLayout.LayoutParams(dp(5), 1));
        }
        p.addView(text(label, 11, 700, color));
        return p;
    }

    protected LinearLayout section(int icon, int iconColor, String title) {
        LinearLayout card = new LinearLayout(this);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setBackground(Kit.rounded(this, CARD_BG, 16, 1, CARD_BORDER));
        card.setPadding(dp(16), dp(16), dp(16), dp(16));

        LinearLayout head = new LinearLayout(this);
        head.setGravity(Gravity.CENTER_VERTICAL);

        TextView ic = Icons.view(this, icon, 18, iconColor);
        ic.setGravity(Gravity.CENTER);
        ic.setBackground(Kit.rounded(this, (iconColor & 0x00FFFFFF) | 0x24000000, 10));
        head.addView(ic, new LinearLayout.LayoutParams(dp(34), dp(34)));

        TextView t = text(title, 15, 700, 0xFFFFFFFF);
        t.setPadding(dp(10), 0, 0, 0);
        head.addView(t, new LinearLayout.LayoutParams(0, -2, 1f));

        card.addView(head);

        View gap = new View(this);
        card.addView(gap, new LinearLayout.LayoutParams(-1, dp(12)));

        content.addView(card, lp(-1, -2, 0, 0, 0, 14));
        return card;
    }

    protected void body(LinearLayout p, String s) {
        TextView t = text(s, 13, 400, 0xB3FFFFFF);
        t.setLineSpacing(0, 1.4f);
        p.addView(t, lp(-1, -2, 0, 0, 0, 8));
    }

    protected void bullet(LinearLayout p, String strong, String s) {
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setPadding(0, dp(2), 0, dp(4));

        TextView dot = Icons.view(this, Icons.CHECK_ROUNDED, 14, LIME);
        dot.setPadding(0, dp(3), 0, 0);
        row.addView(dot);

        TextView t = new TextView(this);
        t.setTextSize(13);
        t.setLineSpacing(0, 1.35f);
        t.setPadding(dp(8), 0, 0, 0);

        android.text.SpannableStringBuilder sb = new android.text.SpannableStringBuilder();
        if (strong != null && !strong.isEmpty()) {
            int start = 0;
            sb.append(strong).append(" ");
            sb.setSpan(new android.text.style.StyleSpan(android.graphics.Typeface.BOLD),
                    start, sb.length(), android.text.Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
            sb.setSpan(new android.text.style.ForegroundColorSpan(0xFFFFFFFF),
                    start, sb.length(), android.text.Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        }
        int textStart = sb.length();
        sb.append(s);
        sb.setSpan(new android.text.style.ForegroundColorSpan(0xB3FFFFFF),
                textStart, sb.length(), android.text.Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        t.setText(sb);

        row.addView(t, new LinearLayout.LayoutParams(0, -2, 1f));
        p.addView(row);
    }

    protected void callout(LinearLayout p, int icon, int iconColor, String title, String msg) {
        LinearLayout box = new LinearLayout(this);
        box.setOrientation(LinearLayout.VERTICAL);
        box.setBackground(Kit.rounded(this, (iconColor & 0x00FFFFFF) | 0x14000000, 12, 1,
                (iconColor & 0x00FFFFFF) | 0x33000000));
        box.setPadding(dp(12), dp(10), dp(12), dp(10));

        LinearLayout head = new LinearLayout(this);
        head.setGravity(Gravity.CENTER_VERTICAL);
        head.addView(Icons.view(this, icon, 16, iconColor));
        TextView t = text(title, 13, 700, iconColor);
        t.setPadding(dp(8), 0, 0, 0);
        head.addView(t);
        box.addView(head);

        TextView m = text(msg, 12, 400, 0xCCFFFFFF);
        m.setLineSpacing(0, 1.3f);
        box.addView(m, lp(-1, -2, 0, 6, 0, 0));

        p.addView(box, lp(-1, -2, 0, 6, 0, 8));
    }

    private View buildContactBox() {
        LinearLayout card = new LinearLayout(this);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setBackground(Kit.rounded(this, CARD_BG, 16, 1, CARD_BORDER));
        card.setPadding(dp(16), dp(16), dp(16), dp(16));

        TextView badge = text("DEVELOPMENT ORGANIZATION", 10.5f, 800, LIME);
        badge.setLetterSpacing(0.06f);
        card.addView(badge);

        TextView name = text("Gree Web Solutions", 16, 800, 0xFFFFFFFF);
        card.addView(name, lp(-2, -2, 0, 4, 0, 0));

        TextView sub = text("Strongly Fitness & Legal Compliance Team", 12, 400, 0x8AFFFFFF);
        card.addView(sub, lp(-2, -2, 0, 2, 0, 12));

        View divider = new View(this);
        divider.setBackgroundColor(0x14FFFFFF);
        card.addView(divider, new LinearLayout.LayoutParams(-1, dp(1)));

        View gap = new View(this);
        card.addView(gap, new LinearLayout.LayoutParams(-1, dp(12)));

        card.addView(contactRow(Icons.MAIL_OUTLINE_ROUNDED, "info@greewebsolutions.com",
                "mailto:info@greewebsolutions.com"));
        card.addView(contactRow(Icons.CHEVRON_RIGHT_ROUNDED, "https://greewebsolutions.com",
                "https://greewebsolutions.com"));

        return card;
    }

    private View contactRow(int icon, String label, String uri) {
        LinearLayout r = new LinearLayout(this);
        r.setGravity(Gravity.CENTER_VERTICAL);
        r.setPadding(0, dp(4), 0, dp(4));
        r.addView(Icons.view(this, icon, 16, LIME));
        TextView t = text(label, 13, 600, 0xFFFFFFFF);
        t.setPadding(dp(10), 0, 0, 0);
        r.addView(t);
        r.setOnClickListener(v -> {
            try { startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(uri))); } catch (Exception ignored) {}
        });
        return r;
    }

    protected int dp(float v) { return Kit.dp(this, v); }

    protected TextView text(String s, float sp, int weight, int color) {
        return Kit.text(this, s, sp, weight, color);
    }

    protected LinearLayout.LayoutParams lp(int w, int h, float l, float t, float r, float b) {
        return Kit.lp(this, w, h, l, t, r, b);
    }
}
