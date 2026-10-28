package com.strongly.strongly.ui;

import android.os.Bundle;
import android.view.Gravity;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

/** Placeholder for screens not yet ported (workout detail, category workouts). */
public class StubActivity extends AppCompatActivity {
    public static final String EXTRA_TITLE = "title";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TextView t = new TextView(this);
        t.setText(getIntent().getStringExtra(EXTRA_TITLE) + " - not ported yet");
        t.setTextColor(0x99FFFFFF);
        t.setGravity(Gravity.CENTER);
        setContentView(t);
    }
}
