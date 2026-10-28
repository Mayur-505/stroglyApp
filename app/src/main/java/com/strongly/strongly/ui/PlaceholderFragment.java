package com.strongly.strongly.ui;

import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

/** Temporary tab content until the real screen is ported. */
public class PlaceholderFragment extends Fragment {
    public static PlaceholderFragment of(String name) {
        PlaceholderFragment f = new PlaceholderFragment();
        Bundle b = new Bundle();
        b.putString("name", name);
        f.setArguments(b);
        return f;
    }

    @Nullable @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle state) {
        TextView t = new TextView(requireContext());
        t.setText(requireArguments().getString("name") + " - not ported yet");
        t.setTextColor(0x99FFFFFF);
        t.setGravity(Gravity.CENTER);
        return t;
    }
}
