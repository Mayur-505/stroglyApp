package com.strongly.strongly.ui;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.view.Gravity;
import android.view.Window;
import android.widget.LinearLayout;
import android.widget.TextView;

/** Dark confirmation dialogs matching Flutter's AlertDialog styling. */
public final class Dialogs {
    private Dialogs() {}

    /** Red-accent confirm dialog (logout / delete account). */
    public static void danger(Context c, int icon, String title, String message, String confirmLabel, Runnable onConfirm) {
        Dialog d = new Dialog(c);
        d.requestWindowFeature(Window.FEATURE_NO_TITLE);
        LinearLayout root = new LinearLayout(c);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackground(Kit.rounded(c, 0xFF161619, 20, 1, 0x14FFFFFF));
        root.setPadding(Kit.dp(c, 24), Kit.dp(c, 24), Kit.dp(c, 16), Kit.dp(c, 12));

        LinearLayout head = new LinearLayout(c);
        head.setGravity(Gravity.CENTER_VERTICAL);
        TextView ic = Icons.view(c, icon, 20, 0xFFFF5B5B);
        ic.setBackground(Kit.rounded(c, 0xFF2C1414, 10));
        head.addView(ic, new LinearLayout.LayoutParams(Kit.dp(c, 36), Kit.dp(c, 36)));
        head.addView(Kit.text(c, title, 18, 800, 0xFFFFFFFF), Kit.lp(c, -2, -2, 12, 0, 0, 0));
        root.addView(head);

        TextView msg = Kit.text(c, message, 14, 400, 0xB3FFFFFF);
        msg.setLineSpacing(0, 1.15f);
        root.addView(msg, Kit.lp(c, -1, -2, 0, 16, 8, 0));

        LinearLayout actions = new LinearLayout(c);
        actions.setGravity(Gravity.END | Gravity.CENTER_VERTICAL);
        TextView cancel = Kit.text(c, "Cancel", 14, 600, 0x99FFFFFF);
        cancel.setPadding(Kit.dp(c, 14), Kit.dp(c, 10), Kit.dp(c, 14), Kit.dp(c, 10));
        cancel.setOnClickListener(v -> d.dismiss());
        actions.addView(cancel);
        TextView ok = Kit.text(c, confirmLabel, 13, 800, 0xFFFFFFFF);
        ok.setBackground(Kit.rounded(c, 0xFFFF4D4D, 12));
        ok.setPadding(Kit.dp(c, 18), Kit.dp(c, 10), Kit.dp(c, 18), Kit.dp(c, 10));
        ok.setOnClickListener(v -> { d.dismiss(); onConfirm.run(); });
        actions.addView(ok, Kit.lp(c, -2, -2, 8, 0, 0, 0));
        root.addView(actions, Kit.lp(c, -1, -2, 0, 16, 0, 0));

        d.setContentView(root);
        if (d.getWindow() != null) {
            d.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
            d.getWindow().setLayout((int) (c.getResources().getDisplayMetrics().widthPixels * 0.88f), -2);
        }
        d.show();
    }

    /** Neutral two-button dialog (cancel subscription). */
    public static void choice(Context c, String title, String message, String keepLabel, String confirmLabel, Runnable onConfirm) {
        Dialog d = new Dialog(c);
        d.requestWindowFeature(Window.FEATURE_NO_TITLE);
        LinearLayout root = new LinearLayout(c);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackground(Kit.rounded(c, 0xFF1B1B1E, 24));
        root.setPadding(Kit.dp(c, 24), Kit.dp(c, 24), Kit.dp(c, 16), Kit.dp(c, 12));
        root.addView(Kit.text(c, title, 20, 700, 0xFFFFFFFF));
        TextView msg = Kit.text(c, message, 14, 400, 0xB3FFFFFF);
        root.addView(msg, Kit.lp(c, -1, -2, 0, 16, 8, 0));
        LinearLayout actions = new LinearLayout(c);
        actions.setGravity(Gravity.END);
        TextView keep = Kit.text(c, keepLabel, 14, 600, Kit.LIME);
        keep.setPadding(Kit.dp(c, 12), Kit.dp(c, 10), Kit.dp(c, 12), Kit.dp(c, 10));
        keep.setOnClickListener(v -> d.dismiss());
        actions.addView(keep);
        TextView ok = Kit.text(c, confirmLabel, 14, 600, 0xFFFF5252);
        ok.setPadding(Kit.dp(c, 12), Kit.dp(c, 10), Kit.dp(c, 12), Kit.dp(c, 10));
        ok.setOnClickListener(v -> { d.dismiss(); onConfirm.run(); });
        actions.addView(ok);
        root.addView(actions, Kit.lp(c, -1, -2, 0, 16, 0, 0));
        d.setContentView(root);
        if (d.getWindow() != null) {
            d.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
            d.getWindow().setLayout((int) (c.getResources().getDisplayMetrics().widthPixels * 0.88f), -2);
        }
        d.show();
    }
}
