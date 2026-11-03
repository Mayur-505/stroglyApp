package com.strongly.strongly.ui;

import android.content.Intent;
import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;

/**
 * LoginActivity forwards to modern unified AuthActivity (in login mode).
 */
public class LoginActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = new Intent(this, AuthActivity.class);
        intent.putExtra(AuthActivity.EXTRA_INITIAL_IS_LOGIN, true);
        startActivity(intent);
        finish();
    }
}
