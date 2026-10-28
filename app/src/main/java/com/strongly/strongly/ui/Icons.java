package com.strongly.strongly.ui;

import android.content.Context;
import android.graphics.Typeface;
import android.util.TypedValue;
import android.view.Gravity;
import android.widget.TextView;

import androidx.core.content.res.ResourcesCompat;

import com.strongly.strongly.R;

/** Material icons rendered from the same icon font Flutter uses, so glyphs match exactly. */
public final class Icons {
    private Icons() {}

    public static final int HEIGHT_ROUNDED = 0xf7e2;
    public static final int MONITOR_WEIGHT_OUTLINED = 0xf1e2;
    public static final int CALENDAR_TODAY_OUTLINED = 0xef11;
    public static final int DIRECTIONS_RUN_OUTLINED = 0xefcb;
    public static final int FIRE_ROUNDED = 0xf86b;
    public static final int FITNESS_CENTER_ROUNDED = 0xf767;
    public static final int GYMNASTICS_ROUNDED = 0xf06d0;
    public static final int FAVORITE_ROUNDED = 0xf738;
    public static final int BOLT_ROUNDED = 0xf5ca;
    public static final int SMILE_ROUNDED = 0xf014f;
    public static final int HOME_ROUNDED = 0xf7f5;
    public static final int PARK_ROUNDED = 0xf004e;
    public static final int CHECK_CIRCLE_ROUNDED = 0xf635;
    public static final int ARROW_BACK_ROUNDED = 0xf572;
    public static final int ARROW_FORWARD_ROUNDED = 0xf57a;
    public static final int KEYBOARD_ARROW_DOWN_ROUNDED = 0xf82b;

    public static final int SELF_IMPROVEMENT_ROUNDED = 0xf0144;
    public static final int ACCESSIBILITY_NEW_ROUNDED = 0xf51b;
    public static final int FITNESS_CENTER = 0xe28d;
    public static final int INSIGHTS_ROUNDED = 0xf820;
    public static final int PERSON_OUTLINE_ROUNDED = 0xf006c;
    public static final int TIMER_OUTLINED = 0xf44a;
    public static final int FIRE_OUTLINED = 0xf17a;

    public static final int SEARCH_ROUNDED = 0xf013d;
    public static final int TUNE_ROUNDED = 0xf0258;
    public static final int CLEAR_ROUNDED = 0xf645;
    public static final int CLOSE_ROUNDED = 0xf647;
    public static final int SEARCH_OFF_ROUNDED = 0xf013c;
    public static final int ACCESS_TIME_ROUNDED = 0xf51a;

    public static final int CHECK_ROUNDED = 0xf636;
    public static final int LOCK_ROUNDED = 0xf889;
    public static final int STAR_ROUNDED = 0xf01d4;
    public static final int STAR_OUTLINE_ROUNDED = 0xf01d1;

    public static final int HELP_OUTLINE_ROUNDED = 0xf7e4;
    public static final int MORE_VERT_ROUNDED = 0xf8dc;
    public static final int CHEVRON_LEFT_ROUNDED = 0xf63a;
    public static final int CHEVRON_RIGHT_ROUNDED = 0xf63b;
    public static final int VOLUME_OFF_ROUNDED = 0xf0299;
    public static final int VOLUME_UP_ROUNDED = 0xf029a;
    public static final int SKIP_PREVIOUS_ROUNDED = 0xf0193;
    public static final int SKIP_NEXT_ROUNDED = 0xf0192;
    public static final int PAUSE_ROUNDED = 0xf0056;
    public static final int INFO_OUTLINE_ROUNDED = 0xf815;
    public static final int FIRE_FILLED = 0xf86b;

    public static final int DIRECTIONS_WALK_ROUNDED = 0xf6bd;

    public static final int CALENDAR_TODAY_ROUNDED = 0xf5fe;
    public static final int CALENDAR_MONTH_ROUNDED = 0xf06c8;
    public static final int CAMERA_ALT_ROUNDED = 0xf60b;
    public static final int CHECK_PLAIN = 0xe156;
    public static final int CLOSE_PLAIN = 0xe16a;
    public static final int DELETE_FOREVER_ROUNDED = 0xf695;
    public static final int DIRECTIONS_RUN_ROUNDED = 0xf6b8;
    public static final int HEIGHT_ROUNDED2 = 0xf7e2;
    public static final int LOCK_OUTLINE_ROUNDED = 0xf888;
    public static final int LOGOUT_ROUNDED = 0xf88b;
    public static final int MAIL_OUTLINE_ROUNDED = 0xf89b;
    public static final int MOOD_ROUNDED = 0xf8d7;
    public static final int PERSON_ROUNDED = 0xf0071;
    public static final int PRIVACY_TIP_OUTLINED = 0xf2d0;
    public static final int RADIO_CHECKED_ROUNDED = 0xf00d7;
    public static final int RADIO_OFF_ROUNDED = 0xf00d8;
    public static final int TRANSLATE_ROUNDED = 0xf0250;
    public static final int TRENDING_UP_ROUNDED = 0xf0254;
    public static final int VISIBILITY_OFF_OUTLINED = 0xf4a0;
    public static final int VISIBILITY_OUTLINED = 0xf4a1;
    public static final int WORKSPACE_PREMIUM_ROUNDED = 0xf03c0;

    private static Typeface face;

    public static Typeface face(Context c) {
        if (face == null) face = ResourcesCompat.getFont(c, R.font.material_icons);
        return face;
    }

    public static TextView view(Context c, int codePoint, float sizeDp, int color) {
        TextView t = new TextView(c);
        t.setTypeface(face(c));
        t.setText(new String(Character.toChars(codePoint)));
        t.setTextSize(TypedValue.COMPLEX_UNIT_DIP, sizeDp);
        t.setTextColor(color);
        t.setGravity(Gravity.CENTER);
        t.setIncludeFontPadding(false);
        t.setLayoutParams(new android.widget.LinearLayout.LayoutParams(-2, -2));
        return t;
    }

    public static void apply(TextView t, int codePoint, float sizeDp, int color) {
        t.setTypeface(face(t.getContext()));
        t.setText(new String(Character.toChars(codePoint)));
        t.setTextSize(TypedValue.COMPLEX_UNIT_DIP, sizeDp);
        t.setTextColor(color);
        t.setIncludeFontPadding(false);
    }
}
