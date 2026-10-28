package com.strongly.strongly.ui;

import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentTransaction;

import com.strongly.strongly.R;
import com.strongly.strongly.util.Tr;

/** Hosts the four main tabs (Home, Workout, Progress, Profile) and the bottom navigation bar. */
public class HomeActivity extends AppCompatActivity {
    private static final int LIME = 0xFFA3D223;
    private static final int[] NAV_ICONS = {Icons.HOME_ROUNDED, Icons.FITNESS_CENTER_ROUNDED,
            Icons.INSIGHTS_ROUNDED, Icons.PERSON_OUTLINE_ROUNDED};
    private static final String[] NAV_KEYS = {"nav_home", "nav_workout", "nav_progress", "nav_profile"};

    private final Fragment[] tabs = new Fragment[4];
    private final TextView[] icons = new TextView[4];
    private final TextView[] labels = new TextView[4];
    private int selected = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);
        UiUtil.edgeToEdge(this);
        UiUtil.padForInsets(findViewById(R.id.tab_container), true, false);

        if (savedInstanceState == null) {
            tabs[0] = new HomeFragment();
            tabs[1] = new WorkoutsFragment();
            tabs[2] = new ProgressFragment();
            tabs[3] = new ProfileFragment();
            FragmentTransaction t = getSupportFragmentManager().beginTransaction();
            for (int i = 0; i < 4; i++) {
                t.add(R.id.tab_container, tabs[i], "tab" + i);
                if (i != 0) t.hide(tabs[i]);
            }
            t.commitNow();
        } else {
            selected = savedInstanceState.getInt("tab", 0);
            for (int i = 0; i < 4; i++) tabs[i] = getSupportFragmentManager().findFragmentByTag("tab" + i);
        }
        buildNav();
        render();
    }

    @Override
    protected void onResume() {
        super.onResume();
        render(); // bottom-bar labels follow a language change made on another screen
    }

    @Override
    protected void onSaveInstanceState(Bundle out) {
        super.onSaveInstanceState(out);
        out.putInt("tab", selected);
    }

    /** Called by tab content to jump back to the Home tab (Flutter's onBack). */
    public void goHome() { select(0); }

    private void buildNav() {
        LinearLayout bar = findViewById(R.id.nav_bar);
        bar.removeAllViews();
        for (int i = 0; i < 4; i++) {
            LinearLayout item = new LinearLayout(this);
            item.setOrientation(LinearLayout.VERTICAL);
            item.setGravity(Gravity.CENTER_HORIZONTAL);
            icons[i] = Icons.view(this, NAV_ICONS[i], 22, 0x8AFFFFFF);
            item.addView(icons[i], new LinearLayout.LayoutParams(UiUtil.dp(this, 22), UiUtil.dp(this, 22)));
            labels[i] = new TextView(this);
            labels[i].setTextSize(11);
            labels[i].setGravity(Gravity.CENTER);
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(-2, -2);
            lp.topMargin = UiUtil.dp(this, 4);
            item.addView(labels[i], lp);
            final int idx = i;
            item.setOnClickListener(v -> select(idx));
            bar.addView(item, new LinearLayout.LayoutParams(0, -2, 1f));
        }
        int bottomInsetPad = UiUtil.dp(this, 10);
        bar.setPadding(0, UiUtil.dp(this, 10), 0, bottomInsetPad);
        // bottom system inset is added on the wrapper so the bar background extends behind the gesture area
        UiUtil.padForInsets(findViewById(R.id.nav_wrapper), false, true);
    }

    private void select(int index) {
        if (index == selected) return;
        FragmentTransaction t = getSupportFragmentManager().beginTransaction();
        t.hide(tabs[selected]).show(tabs[index]).commit();
        selected = index;
        render();
        // Flutter refreshes the dashboard whenever the Progress tab is selected
        if (index == 2 && tabs[2] instanceof ProgressFragment) ((ProgressFragment) tabs[2]).fetchDashboard();
    }

    private void render() {
        for (int i = 0; i < 4; i++) {
            boolean sel = i == selected;
            icons[i].setTextColor(sel ? LIME : 0x8AFFFFFF);
            labels[i].setText(Tr.t(NAV_KEYS[i]));
            labels[i].setTextColor(sel ? LIME : 0x8AFFFFFF);
            UiUtil.weight(labels[i], sel ? 700 : 500);
        }
    }

    @Override
    public void onBackPressed() {
        if (selected != 0) select(0); else super.onBackPressed();
    }
}
