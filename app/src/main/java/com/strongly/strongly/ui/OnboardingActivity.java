package com.strongly.strongly.ui;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;

import com.strongly.strongly.R;
import com.strongly.strongly.util.Tr;

public class OnboardingActivity extends AppCompatActivity {
    private static final int[] IMAGES = {R.drawable.onboarding_1, R.drawable.onboarding_2, R.drawable.onboarding_3};
    private ViewPager2 pager;
    private TextView title, desc;
    private LinearLayout indicator;
    private View next, getStarted;
    private int index = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_onboarding);
        UiUtil.edgeToEdge(this);
        UiUtil.padForInsets(findViewById(R.id.bottom), false, true);
        UiUtil.weight((TextView) findViewById(R.id.title), 900);
        UiUtil.weight((TextView) findViewById(R.id.get_started_text), 600);

        pager = findViewById(R.id.pager);
        title = findViewById(R.id.title);
        desc = findViewById(R.id.desc);
        indicator = findViewById(R.id.indicator);
        next = findViewById(R.id.next);
        getStarted = findViewById(R.id.get_started);
        ((TextView) findViewById(R.id.get_started_text)).setText(Tr.t("get_started"));

        pager.setAdapter(new RecyclerView.Adapter<RecyclerView.ViewHolder>() {
            @NonNull @Override
            public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup p, int t) {
                return new RecyclerView.ViewHolder(LayoutInflater.from(p.getContext())
                        .inflate(R.layout.item_onboarding_page, p, false)) {};
            }

            @Override
            public void onBindViewHolder(@NonNull RecyclerView.ViewHolder h, int pos) {
                ((ImageView) h.itemView).setImageResource(IMAGES[pos]);
            }

            @Override public int getItemCount() { return IMAGES.length; }
        });
        pager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override public void onPageSelected(int position) { index = position; render(); }
        });

        next.setOnClickListener(v -> pager.setCurrentItem(index + 1, true));
        getStarted.setOnClickListener(v -> {
            startActivity(new Intent(this, LanguageActivity.class));
            finish();
        });
        render();
    }

    private void render() {
        int n = IMAGES.length;
        title.setText(Tr.t("onboarding_" + (index + 1) + "_title"));
        desc.setText(Tr.t("onboarding_" + (index + 1) + "_desc"));
        boolean last = index == n - 1;
        next.setVisibility(last ? View.GONE : View.VISIBLE);
        indicator.setVisibility(last ? View.GONE : View.VISIBLE);
        getStarted.setVisibility(last ? View.VISIBLE : View.GONE);

        indicator.removeAllViews();
        for (int i = 0; i < n; i++) {
            View dot = new View(this);
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                    UiUtil.dp(this, i == index ? 24 : 6), UiUtil.dp(this, 6));
            lp.setMarginEnd(UiUtil.dp(this, 6));
            dot.setLayoutParams(lp);
            android.graphics.drawable.GradientDrawable g = new android.graphics.drawable.GradientDrawable();
            g.setCornerRadius(UiUtil.dp(this, 4));
            g.setColor(i == index ? 0xFFFFFFFF : 0x66FFFFFF);
            dot.setBackground(g);
            indicator.addView(dot);
        }
    }
}
