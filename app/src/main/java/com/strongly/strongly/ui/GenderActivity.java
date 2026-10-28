package com.strongly.strongly.ui;

import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.strongly.strongly.R;
import com.strongly.strongly.util.Tr;

public class GenderActivity extends AppCompatActivity {
    private boolean male = true;
    private View cardMen, cardWomen;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_gender);
        UiUtil.edgeToEdge(this);
        UiUtil.padForInsets(findViewById(R.id.cards), true, false);
        UiUtil.padForInsets(findViewById(R.id.bottom), false, true);
        UiUtil.weight((TextView) findViewById(R.id.title), 900);
        UiUtil.weight((TextView) findViewById(R.id.continue_text), 600);

        ((TextView) findViewById(R.id.title)).setText(Tr.t("tell_us_about_yourself"));
        ((TextView) findViewById(R.id.subtitle)).setText(Tr.t("personalize_fitness_journey"));
        ((TextView) findViewById(R.id.continue_text)).setText(Tr.t("continue_btn"));

        cardMen = findViewById(R.id.card_men);
        cardWomen = findViewById(R.id.card_women);
        ((ImageView) cardMen.findViewById(R.id.athlete)).setImageResource(R.drawable.athlete_splash);
        ((ImageView) cardWomen.findViewById(R.id.athlete)).setImageResource(R.drawable.female_athlete);
        ((TextView) cardMen.findViewById(R.id.label)).setText(Tr.t("men"));
        ((TextView) cardWomen.findViewById(R.id.label)).setText(Tr.t("women"));
        UiUtil.weight((TextView) cardMen.findViewById(R.id.label), 900);
        UiUtil.weight((TextView) cardWomen.findViewById(R.id.label), 900);
        cardMen.setOnClickListener(v -> { male = true; render(); });
        cardWomen.setOnClickListener(v -> { male = false; render(); });
        render();

        findViewById(R.id.continue_btn).setOnClickListener(v -> {
            Intent i = new Intent(this, QuestionnaireActivity.class);
            i.putExtra(QuestionnaireActivity.EXTRA_GENDER, male ? "Male" : "Female");
            startActivity(i);
        });
    }

    private void render() {
        style(cardMen, male);
        style(cardWomen, !male);
    }

    private void style(View card, boolean selected) {
        GradientDrawable border = new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM,
                new int[]{0xFFA3D223, selected ? 0x66A3D223 : 0x00A3D223});
        border.setCornerRadius(UiUtil.dp(this, 20));
        card.setBackground(border);

        GradientDrawable dome = new GradientDrawable();
        float r = UiUtil.dp(this, 75);
        dome.setCornerRadii(new float[]{r, r, r, r, 0, 0, 0, 0});
        dome.setColor(selected ? 0xFFA3D223 : 0xFF26390E);
        card.findViewById(R.id.dome).setBackground(dome);

        ((TextView) card.findViewById(R.id.label)).setTextColor(selected ? 0xFFA3D223 : 0xFFFFFFFF);
    }
}
