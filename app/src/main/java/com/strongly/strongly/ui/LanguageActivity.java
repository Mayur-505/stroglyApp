package com.strongly.strongly.ui;

import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.gson.JsonObject;
import com.strongly.strongly.R;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.net.ApiConstants;
import com.strongly.strongly.util.Session;
import com.strongly.strongly.util.Tr;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class LanguageActivity extends AppCompatActivity {
    public static final String EXTRA_FROM_SETTINGS = "from_settings";

    private static final String[][] LANGS = {
            {"en", "English", "English", "🇺🇸"},
            {"es", "Spanish", "Español", "🇪🇸"},
            {"fr", "French", "Français", "🇫🇷"},
            {"de", "German", "Deutsch", "🇩🇪"},
            {"ar", "Arabic", "العربية", "🇸🇦"},
            {"zh", "Chinese", "中文", "🇨🇳"},
            {"pt", "Portuguese", "Português", "🇧🇷"},
            {"ja", "Japanese", "日本語", "🇯🇵"},
            {"hi", "Hindi", "हिन्दी", "🇮🇳"},
            {"gu", "Gujarati", "ગુજરાતી", "🇮🇳"},
    };

    private String selected;
    private final List<String[]> filtered = new ArrayList<>(java.util.Arrays.asList(LANGS));
    private RecyclerView.Adapter<?> adapter;
    private boolean fromSettings;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_language);
        UiUtil.edgeToEdge(this);
        UiUtil.padForInsets(findViewById(R.id.root), true, true);
        UiUtil.weight((TextView) findViewById(R.id.title), 800);
        UiUtil.weight((TextView) findViewById(R.id.continue_text), 800);
        fromSettings = getIntent().getBooleanExtra(EXTRA_FROM_SETTINGS, false);
        selected = Session.language();

        Icons.apply(findViewById(R.id.badge), 0xf83f, 20, 0xFFA3D223);
        ((TextView) findViewById(R.id.title)).setText(Tr.t("select_language"));
        ((TextView) findViewById(R.id.subtitle)).setText(Tr.t("choose_language_desc"));
        ((TextView) findViewById(R.id.continue_text)).setText(Tr.t(fromSettings ? "save_changes" : "continue_btn"));
        EditText search = findViewById(R.id.search);
        search.setHint(Tr.t("search_language"));
        View back = findViewById(R.id.back);
        if (fromSettings) {
            back.setVisibility(View.VISIBLE);
            back.setOnClickListener(v -> finish());
        }

        Icons.apply(findViewById(R.id.search_icon), 0xf013d, 20, 0x61FFFFFF);
        TextView clear = findViewById(R.id.search_clear);
        Icons.apply(clear, 0xf647, 18, 0x61FFFFFF);
        clear.setOnClickListener(v -> search.setText(""));
        search.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int a, int b, int c) {}
            @Override public void onTextChanged(CharSequence s, int a, int b, int c) {}
            @Override public void afterTextChanged(Editable s) {
                clear.setVisibility(s.length() > 0 ? View.VISIBLE : View.GONE);
                filter(s.toString());
            }
        });

        RecyclerView list = findViewById(R.id.list);
        list.setLayoutManager(new LinearLayoutManager(this));
        adapter = new RecyclerView.Adapter<RecyclerView.ViewHolder>() {
            @NonNull @Override
            public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup p, int t) {
                return new RecyclerView.ViewHolder(LayoutInflater.from(p.getContext())
                        .inflate(R.layout.item_language, p, false)) {};
            }

            @Override
            public void onBindViewHolder(@NonNull RecyclerView.ViewHolder h, int pos) {
                String[] l = filtered.get(pos);
                boolean sel = l[0].equals(selected);
                View v = h.itemView;
                ((TextView) v.findViewById(R.id.flag)).setText(l[3]);
                TextView nn = v.findViewById(R.id.native_name);
                nn.setText(l[2]);
                UiUtil.weight(nn, 700);
                nn.setTextColor(sel ? 0xFFA3D223 : 0xFFFFFFFF);
                TextView n = v.findViewById(R.id.name);
                n.setText(l[1]);
                n.setTextColor(sel ? 0xB3FFFFFF : 0x61FFFFFF);

                GradientDrawable card = new GradientDrawable();
                card.setCornerRadius(UiUtil.dp(v.getContext(), 16));
                card.setColor(sel ? 0xFF1F2910 : 0xFF161619);
                card.setStroke(UiUtil.dp(v.getContext(), sel ? 1.5f : 1f), sel ? 0xFFA3D223 : 0x14FFFFFF);
                v.setBackground(card);

                GradientDrawable radio = new GradientDrawable();
                radio.setShape(GradientDrawable.OVAL);
                radio.setColor(sel ? 0xFFA3D223 : 0x00000000);
                radio.setStroke(UiUtil.dp(v.getContext(), 2), sel ? 0xFFA3D223 : 0x61FFFFFF);
                ImageView r = v.findViewById(R.id.radio);
                r.setBackground(radio);
                r.setImageResource(sel ? R.drawable.ic_check : 0);
                v.setOnClickListener(x -> { selected = l[0]; adapter.notifyDataSetChanged(); });
            }

            @Override public int getItemCount() { return filtered.size(); }
        };
        list.setAdapter(adapter);

        findViewById(R.id.continue_btn).setOnClickListener(v -> onContinue());
    }

    private void filter(String q) {
        String t = q.trim().toLowerCase(Locale.ROOT);
        filtered.clear();
        for (String[] l : LANGS) {
            if (t.isEmpty() || l[1].toLowerCase(Locale.ROOT).contains(t)
                    || l[2].toLowerCase(Locale.ROOT).contains(t) || l[0].contains(t)) filtered.add(l);
        }
        adapter.notifyDataSetChanged();
    }

    private void onContinue() {
        Tr.setLanguage(selected);
        JsonObject body = new JsonObject();
        body.addProperty("language", selected);
        ApiClient.get().put(ApiConstants.UPDATE_LANGUAGE, body, r -> { });
        if (fromSettings) {
            finish();
        } else {
            startActivity(new Intent(this, GenderActivity.class));
            finish();
        }
    }
}
