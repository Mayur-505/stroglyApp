package com.strongly.strongly.ui;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.widget.FrameLayout;
import android.widget.ImageView;

/**
 * Modern 2-Pose Motion Animation player that smoothly alternates between
 * Image 1 (Start Pose: 0.jpg) and Image 2 (End Pose: 1.jpg).
 *
 * Uses instant frame-by-frame pose switching without transparency blending.
 * Uses INVISIBLE instead of GONE so both poses are measured, sized and loaded
 * at full dimensions right from the start (no size jumps or layout shifts).
 */
public class ExerciseMotionView extends FrameLayout {
    private final ImageView imgStart;
    private final ImageView imgEnd;

    private String startPath;
    private String endPath;
    private boolean showingStart = true;
    private boolean hasTwoPoses = false;

    private final Handler handler = new Handler(Looper.getMainLooper());
    private final Runnable toggleRunnable = new Runnable() {
        @Override
        public void run() {
            togglePose();
            handler.postDelayed(this, 1100);
        }
    };

    public ExerciseMotionView(Context context) {
        super(context);

        imgStart = new ImageView(context);
        imgStart.setScaleType(ImageView.ScaleType.FIT_CENTER);
        addView(imgStart, new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT, Gravity.CENTER));

        imgEnd = new ImageView(context);
        imgEnd.setScaleType(ImageView.ScaleType.FIT_CENTER);
        imgEnd.setVisibility(INVISIBLE);
        addView(imgEnd, new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT, Gravity.CENTER));

        setOnClickListener(v -> {
            if (hasTwoPoses) {
                handler.removeCallbacks(toggleRunnable);
                togglePose();
                handler.postDelayed(toggleRunnable, 1100);
            }
        });
    }

    public void load(String startUrl, String endUrl, int fallbackColor) {
        this.startPath = startUrl != null ? startUrl.trim() : "";
        this.endPath = endUrl != null ? endUrl.trim() : "";

        // Check if we have two distinct poses
        hasTwoPoses = !this.endPath.isEmpty() && !this.endPath.equals(this.startPath);

        showingStart = true;
        imgStart.setVisibility(VISIBLE);
        imgEnd.setVisibility(INVISIBLE);

        ImageLoader.load(imgStart, this.startPath, fallbackColor);
        if (hasTwoPoses) {
            ImageLoader.load(imgEnd, this.endPath, fallbackColor);
            startLoop();
        } else {
            stopLoop();
        }
    }

    private void togglePose() {
        if (!hasTwoPoses) return;
        showingStart = !showingStart;
        if (showingStart) {
            imgStart.setVisibility(VISIBLE);
            imgEnd.setVisibility(INVISIBLE);
        } else {
            imgEnd.setVisibility(VISIBLE);
            imgStart.setVisibility(INVISIBLE);
        }
    }

    private void startLoop() {
        stopLoop();
        if (hasTwoPoses && isAttachedToWindow()) {
            handler.postDelayed(toggleRunnable, 1100);
        }
    }

    private void stopLoop() {
        handler.removeCallbacks(toggleRunnable);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        if (hasTwoPoses) {
            startLoop();
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        stopLoop();
    }
}
