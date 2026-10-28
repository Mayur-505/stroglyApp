package com.strongly.strongly.ui;

import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.drawable.DrawableTransitionOptions;

import java.util.Locale;

/** Loads either a network URL (cached) or a bundled asset path like "assets/images/x.jpg". */
public final class ImageLoader {
    private ImageLoader() {}

    /** Maps "assets/images/image 7 (1).png" to the sanitized drawable name used in res/. */
    public static int drawableFor(Context c, String path) {
        String file = path.substring(path.lastIndexOf('/') + 1);
        int dot = file.lastIndexOf('.');
        String base = dot >= 0 ? file.substring(0, dot) : file;
        String name = base.toLowerCase(Locale.ROOT).replaceAll("[ ()]", "_").replaceAll("_+", "_");
        return c.getResources().getIdentifier(name, "drawable", c.getPackageName());
    }

    public static void load(ImageView v, String path, int fallbackColor) {
        Context c = v.getContext();
        String p = path == null ? "" : path.trim();
        if (p.startsWith("http://") || p.startsWith("https://")) {
            Glide.with(c).load(p)
                    .placeholder(new ColorDrawable(0xFF1B1B1D))
                    .error(new ColorDrawable(fallbackColor))
                    .transition(DrawableTransitionOptions.withCrossFade(200))
                    .into(v);
            return;
        }
        int id = p.isEmpty() ? 0 : drawableFor(c, p);
        if (id != 0) v.setImageResource(id);
        else v.setImageDrawable(new ColorDrawable(fallbackColor));
    }
}
