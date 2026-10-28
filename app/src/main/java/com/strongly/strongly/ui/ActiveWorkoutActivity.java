package com.strongly.strongly.ui;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import androidx.media3.common.MediaItem;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.ui.AspectRatioFrameLayout;
import androidx.media3.ui.PlayerView;

import com.strongly.strongly.model.PlanModels;

import java.util.ArrayList;
import java.util.Locale;

/** Landscape workout player: exercise timer, rest, pause, quit survey (Flutter's ActiveWorkoutLandscapeScreen). */
public class ActiveWorkoutActivity extends AppCompatActivity {
    public static final String EXTRA_DAY = "dayNumber", EXTRA_TITLE = "workoutTitle", EXTRA_INDEX = "initialExerciseIndex",
            EXTRA_EXERCISES = "exercises";
    private static final int LIME = Kit.LIME;
    private static final int INK = 0xFF141416;

    private enum Step { EXERCISING, PAUSED, RESTING, ENCOURAGEMENT, WHY_QUIT }

    private ArrayList<PlanModels.Exercise> exercises = new ArrayList<>();
    private int index;
    private Step step = Step.EXERCISING;

    private int exerciseSeconds = 30, restSeconds = 20, elapsed = 0;
    private boolean videoReady = false, muted = false, finished = false;

    private final Handler handler = new Handler(Looper.getMainLooper());
    private final Runnable tick = new Runnable() {
        @Override public void run() { onTick(); handler.postDelayed(this, 1000); }
    };

    private FrameLayout root;
    private ExoPlayer player;
    private PlayerView playerView;
    private String playerUrl;
    private String preloadedUrl;
    private TextView timerText, elapsedText, restText;

    @SuppressWarnings("unchecked")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
        WindowInsetsControllerCompat ctl = WindowCompat.getInsetsController(getWindow(), getWindow().getDecorView());
        ctl.setSystemBarsBehavior(WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
        ctl.hide(WindowInsetsCompat.Type.systemBars());
        ctl.setAppearanceLightStatusBars(true);

        Object ex = getIntent().getSerializableExtra(EXTRA_EXERCISES);
        if (ex instanceof ArrayList) exercises = (ArrayList<PlanModels.Exercise>) ex;
        int i = getIntent().getIntExtra(EXTRA_INDEX, 0);
        index = i >= 0 && i < exercises.size() ? i : 0;
        exerciseSeconds = exercises.isEmpty() ? 30 : parseDuration(exercises.get(index).duration);
        videoReady = !hasVideo(exercises.isEmpty() ? null : exercises.get(index));

        root = new FrameLayout(this);
        root.setBackgroundColor(0xFFFFFFFF);
        setContentView(root);
        if (exercises.isEmpty()) { finish(); return; }
        render();
        handler.postDelayed(tick, 1000);
    }

    private int dp(float v) { return Kit.dp(this, v); }

    private static boolean hasVideo(PlanModels.Exercise e) { return e != null && e.videoUrl != null && !e.videoUrl.isEmpty(); }

    private static int parseDuration(String s) {
        try {
            String[] p = s.split(":");
            if (p.length == 2) return Integer.parseInt(p[0].trim()) * 60 + Integer.parseInt(p[1].trim());
        } catch (Exception ignored) { }
        return 30;
    }

    private static String fmt(int total) {
        return String.format(Locale.US, "%02d:%02d", total / 60, total % 60);
    }

    // ------------------------------------------------------------------ timer / state machine

    private void onTick() {
        if (finished) return;
        if (step == Step.EXERCISING) {
            if (hasVideo(exercises.get(index)) && !videoReady) return; // wait for the video before counting down
            elapsed++;
            if (exerciseSeconds > 0) exerciseSeconds--; else { onExerciseCompleted(); return; }
            updateTimers();
        } else if (step == Step.RESTING) {
            elapsed++;
            if (restSeconds > 0) restSeconds--; else { advance(); return; }
            updateTimers();
        }
    }

    private void updateTimers() {
        if (timerText != null) timerText.setText(fmt(exerciseSeconds));
        if (elapsedText != null) elapsedText.setText(fmt(elapsed));
        if (restText != null) restText.setText(fmt(restSeconds));
    }

    private void onExerciseCompleted() {
        if (index == 4 && step != Step.ENCOURAGEMENT) { step = Step.ENCOURAGEMENT; render(); return; }
        if (index >= exercises.size() - 1) { complete(); return; }
        step = Step.RESTING;
        restSeconds = 20;
        preloadNext();
        render();
    }

    private void advance() {
        if (index < exercises.size() - 1) {
            index++;
            exerciseSeconds = parseDuration(exercises.get(index).duration);
            step = Step.EXERCISING;
            PlanModels.Exercise cur = exercises.get(index);
            videoReady = !hasVideo(cur) || (cur.videoUrl.equals(preloadedUrl) && player != null
                    && player.getPlaybackState() == Player.STATE_READY);
            render();
        } else complete();
    }

    private void previous() {
        if (index > 0) {
            index--;
            exerciseSeconds = parseDuration(exercises.get(index).duration);
            step = Step.EXERCISING;
            videoReady = !hasVideo(exercises.get(index));
            render();
        }
    }

    private void restartCurrent() {
        exerciseSeconds = parseDuration(exercises.get(index).duration);
        step = Step.EXERCISING;
        videoReady = !hasVideo(exercises.get(index));
        render();
    }

    private void complete() {
        if (finished) return;
        finished = true;
        Intent out = new Intent();
        out.putExtra(ExercisePreviewActivity.EXTRA_ELAPSED, elapsed);
        setResult(RESULT_OK, out);
        finish();
    }

    private void exit() {
        finished = true;
        finish();
    }

    // ------------------------------------------------------------------ video

    private void preloadNext() {
        if (index + 1 >= exercises.size()) return;
        String next = exercises.get(index + 1).videoUrl;
        if (next == null || next.isEmpty() || next.equals(preloadedUrl)) return;
        preloadedUrl = next;
        ensurePlayer();
        player.setMediaItem(MediaItem.fromUri(next));
        player.setPlayWhenReady(false);
        player.prepare();
        playerUrl = next;
    }

    private void ensurePlayer() {
        if (player != null) return;
        player = new ExoPlayer.Builder(this).build();
        player.setRepeatMode(Player.REPEAT_MODE_ONE);
        player.addListener(new Player.Listener() {
            @Override public void onPlaybackStateChanged(int state) {
                if (finished) return;
                if (state == Player.STATE_READY) {
                    if (!videoReady) videoReady = true;
                } else if (state == Player.STATE_BUFFERING && step == Step.EXERCISING) {
                    videoReady = false;
                }
                applyVideoState();
            }

            @Override public void onPlayerError(androidx.media3.common.PlaybackException error) {
                // keep the countdown from being blocked if the video cannot load
                videoReady = true;
            }
        });
    }

    private void applyVideoState() {
        if (player == null) return;
        player.setVolume(muted ? 0f : 1f);
        player.setPlayWhenReady(step == Step.EXERCISING && videoReady);
    }

    // ------------------------------------------------------------------ rendering

    private void render() {
        root.removeAllViews();
        timerText = null; elapsedText = null; restText = null;
        root.setBackgroundColor(0xFFFFFFFF);
        root.addView(activeScreen(), new FrameLayout.LayoutParams(-1, -1));
        switch (step) {
            case RESTING: root.addView(restScreen(), new FrameLayout.LayoutParams(-1, -1)); break;
            case ENCOURAGEMENT: root.addView(encouragement(), new FrameLayout.LayoutParams(-1, -1)); break;
            case PAUSED: root.addView(pauseOverlay(), new FrameLayout.LayoutParams(-1, -1)); break;
            case WHY_QUIT: root.addView(whyQuit(), new FrameLayout.LayoutParams(-1, -1)); break;
            default: break;
        }
        applyVideoState();
    }

    private TextView round(int icon, float size, int dia, int fill, boolean shadow, View.OnClickListener click) {
        TextView t = Icons.view(this, icon, size, LIME);
        GradientDrawable g = new GradientDrawable();
        g.setShape(GradientDrawable.OVAL);
        g.setColor(fill);
        t.setBackground(g);
        t.setLayoutParams(new LinearLayout.LayoutParams(dp(dia), dp(dia)));
        if (shadow) t.setElevation(dp(5));
        t.setOnClickListener(click);
        return t;
    }

    private View activeScreen() {
        PlanModels.Exercise cur = exercises.get(index);
        FrameLayout screen = new FrameLayout(this);
        screen.setBackgroundColor(0xFFFFFFFF);
        screen.setPadding(dp(20), dp(14), dp(20), dp(14));

        // center: video or poster image
        int h = (int) (getResources().getDisplayMetrics().heightPixels * 0.65f);
        FrameLayout media = new FrameLayout(this);
        if (hasVideo(cur)) {
            ensurePlayer();
            ImageView poster = new ImageView(this);
            poster.setScaleType(ImageView.ScaleType.FIT_CENTER);
            poster.setBackground(Kit.rounded(this, 0xFFF6F6F6, 16));
            ImageLoader.load(poster, cur.imagePath, 0xFFF6F6F6);
            media.addView(poster, new FrameLayout.LayoutParams(-1, -1));
            playerView = new PlayerView(this);
            playerView.setUseController(false);
            playerView.setResizeMode(AspectRatioFrameLayout.RESIZE_MODE_FIT);
            playerView.setShutterBackgroundColor(0x00000000);
            playerView.setPlayer(player);
            playerView.setVisibility(videoReady ? View.VISIBLE : View.INVISIBLE);
            media.addView(playerView, new FrameLayout.LayoutParams(-1, -1));
            if (!videoReady) {
                ProgressBar pb = new ProgressBar(this);
                pb.setIndeterminateTintList(android.content.res.ColorStateList.valueOf(0xFFC6FF00));
                media.addView(pb, new FrameLayout.LayoutParams(dp(36), dp(36), Gravity.CENTER));
            }
            if (!cur.videoUrl.equals(playerUrl)) {
                playerUrl = cur.videoUrl;
                preloadedUrl = cur.videoUrl;
                player.setMediaItem(MediaItem.fromUri(cur.videoUrl));
                player.prepare();
            }
        } else {
            ImageView img = new ImageView(this);
            img.setScaleType(ImageView.ScaleType.FIT_CENTER);
            img.setBackground(Kit.rounded(this, 0xFFF6F6F6, 16));
            img.setClipToOutline(true);
            img.setAdjustViewBounds(true);
            ImageLoader.load(img, cur.imagePath, 0xFFF6F6F6);
            media.addView(img, new FrameLayout.LayoutParams(-2, -1));
            // gentle bounce, like Flutter's ScaleTransition(0.97..1.03)
            android.animation.ValueAnimator a = android.animation.ValueAnimator.ofFloat(0.97f, 1.03f);
            a.setDuration(900);
            a.setRepeatMode(android.animation.ValueAnimator.REVERSE);
            a.setRepeatCount(android.animation.ValueAnimator.INFINITE);
            a.addUpdateListener(v -> { media.setScaleX((float) v.getAnimatedValue()); media.setScaleY((float) v.getAnimatedValue()); });
            a.start();
        }
        FrameLayout.LayoutParams mp = new FrameLayout.LayoutParams(-2, h, Gravity.CENTER);
        if (hasVideo(cur)) media.setMinimumWidth((int) (h * 16f / 9f));
        screen.addView(media, mp);

        // top row
        LinearLayout top = new LinearLayout(this);
        top.setGravity(Gravity.CENTER_VERTICAL);
        LinearLayout counter = new LinearLayout(this);
        counter.setGravity(Gravity.CENTER_VERTICAL);
        TextView chev = Icons.view(this, Icons.CHEVRON_LEFT_ROUNDED, 20, INK);
        chev.setBackground(Kit.rounded(this, 0x0F000000, 14));
        counter.addView(chev, new LinearLayout.LayoutParams(dp(28), dp(28)));
        counter.addView(Kit.text(this, "Exercise " + (index + 1) + "/" + exercises.size(), 14, 700, INK), Kit.lp(this, -2, -2, 8, 0, 0, 0));
        counter.setOnClickListener(v -> { step = Step.PAUSED; render(); });
        top.addView(counter);
        TextView sound = Icons.view(this, muted ? Icons.VOLUME_OFF_ROUNDED : Icons.VOLUME_UP_ROUNDED, 16, INK);
        sound.setBackground(Kit.rounded(this, 0x0F000000, 14));
        sound.setOnClickListener(v -> { muted = !muted; render(); });
        top.addView(sound, Kit.lp(this, dp(28), dp(28), 14, 0, 0, 0));
        top.addView(new View(this), new LinearLayout.LayoutParams(0, 1, 1f));
        elapsedText = Kit.text(this, fmt(elapsed), 15, 800, INK);
        top.addView(elapsedText);
        screen.addView(top, new FrameLayout.LayoutParams(-1, -2, Gravity.TOP));

        // bottom-left
        LinearLayout bl = new LinearLayout(this);
        bl.setOrientation(LinearLayout.VERTICAL);
        bl.addView(Kit.text(this, cur.title, 16, 800, INK));
        timerText = Kit.text(this, fmt(exerciseSeconds), 40, 900, INK);
        timerText.setLetterSpacing(-0.025f);
        bl.addView(timerText, Kit.lp(this, -2, -2, 0, 2, 0, 0));
        LinearLayout nav = new LinearLayout(this);
        nav.setGravity(Gravity.CENTER_VERTICAL);
        boolean canPrev = index > 0;
        LinearLayout prev = new LinearLayout(this);
        prev.setGravity(Gravity.CENTER_VERTICAL);
        prev.addView(Icons.view(this, Icons.SKIP_PREVIOUS_ROUNDED, 16, canPrev ? INK : 0x42000000));
        prev.addView(Kit.text(this, "Previous", 12, 600, canPrev ? INK : 0x42000000), Kit.lp(this, -2, -2, 4, 0, 0, 0));
        if (canPrev) prev.setOnClickListener(v -> previous());
        nav.addView(prev);
        nav.addView(Kit.text(this, "|", 12, 400, 0x42000000), Kit.lp(this, -2, -2, 10, 0, 10, 0));
        LinearLayout skip = new LinearLayout(this);
        skip.setGravity(Gravity.CENTER_VERTICAL);
        skip.addView(Icons.view(this, Icons.SKIP_NEXT_ROUNDED, 16, INK));
        skip.addView(Kit.text(this, "Skip", 12, 600, INK), Kit.lp(this, -2, -2, 4, 0, 0, 0));
        skip.setOnClickListener(v -> onExerciseCompleted());
        nav.addView(skip);
        bl.addView(nav, Kit.lp(this, -2, -2, 0, 6, 0, 0));
        screen.addView(bl, new FrameLayout.LayoutParams(-2, -2, Gravity.BOTTOM | Gravity.START));

        // right: pause + complete
        LinearLayout right = new LinearLayout(this);
        right.setOrientation(LinearLayout.VERTICAL);
        right.addView(round(Icons.PAUSE_ROUNDED, 26, 50, 0xFF182215, true, v -> { step = Step.PAUSED; render(); }));
        LinearLayout.LayoutParams cp = new LinearLayout.LayoutParams(dp(50), dp(50));
        cp.topMargin = dp(18);
        right.addView(round(Icons.CHECK_ROUNDED, 28, 50, 0xFF182215, true, v -> onExerciseCompleted()), cp);
        screen.addView(right, new FrameLayout.LayoutParams(-2, -2, Gravity.END | Gravity.CENTER_VERTICAL));
        return screen;
    }

    private View pill(String text, int fill, int color, int hPad, int weight, View.OnClickListener click) {
        TextView t = Kit.text(this, text, 13, weight, color);
        t.setBackground(Kit.rounded(this, fill, 24));
        t.setPadding(dp(hPad), dp(12), dp(hPad), dp(12));
        t.setGravity(Gravity.CENTER);
        t.setOnClickListener(click);
        return t;
    }

    private View pillGroup(View... pills) {
        LinearLayout g = new LinearLayout(this);
        g.setBackground(Kit.rounded(this, 0xFF1C1C20, 28, 1, 0x14FFFFFF));
        g.setPadding(dp(4), dp(4), dp(4), dp(4));
        for (int i = 0; i < pills.length; i++) {
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(-2, -2);
            if (i > 0) lp.setMarginStart(dp(8));
            g.addView(pills[i], lp);
        }
        return g;
    }

    private View pauseOverlay() {
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        col.setGravity(Gravity.CENTER);
        col.setBackgroundColor(0xFF000000);
        col.addView(Kit.text(this, "Pause", 26, 800, LIME), new LinearLayout.LayoutParams(-2, -2));
        col.addView(pillGroup(
                pill("Restart this exercise", LIME, INK, 20, 800, v -> restartCurrent()),
                pill("Quit", 0xFF2C2C32, 0xFFFFFFFF, 26, 700, v -> { step = Step.WHY_QUIT; render(); }),
                pill("Resume", 0xFF2C2C32, 0xFFFFFFFF, 26, 700, v -> { step = Step.EXERCISING; render(); })),
                Kit.lp(this, -2, -2, 0, 24, 0, 0));
        col.setClickable(true);
        return col;
    }

    private View restScreen() {
        int nextIndex = index + 1 < exercises.size() ? index + 1 : index;
        PlanModels.Exercise next = exercises.get(nextIndex);

        LinearLayout row = new LinearLayout(this);
        row.setBackgroundColor(0xFFFFFFFF);
        row.setClickable(true);

        FrameLayout left = new FrameLayout(this);
        left.setPadding(dp(24), dp(24), dp(24), dp(24));
        LinearLayout lc = new LinearLayout(this);
        lc.setOrientation(LinearLayout.VERTICAL);
        lc.addView(Kit.text(this, "Next " + (nextIndex + 1) + "/" + exercises.size(), 12, 600, 0x73000000));
        LinearLayout tl = new LinearLayout(this);
        tl.setGravity(Gravity.CENTER_VERTICAL);
        tl.addView(Kit.text(this, next.title, 18, 800, INK));
        tl.addView(Icons.view(this, Icons.INFO_OUTLINE_ROUNDED, 15, 0x73000000), Kit.lp(this, -2, -2, 4, 0, 0, 0));
        lc.addView(tl, Kit.lp(this, -2, -2, 0, 2, 0, 0));
        lc.addView(Kit.text(this, next.duration, 14, 700, INK));
        FrameLayout imgHolder = new FrameLayout(this);
        ImageView img = new ImageView(this);
        img.setScaleType(ImageView.ScaleType.FIT_CENTER);
        img.setBackground(Kit.rounded(this, 0xFFF6F6F6, 16));
        img.setClipToOutline(true);
        ImageLoader.load(img, next.imagePath, 0xFFF6F6F6);
        imgHolder.addView(img, new FrameLayout.LayoutParams(-2, -1, Gravity.CENTER));
        img.setAdjustViewBounds(true);
        lc.addView(imgHolder, new LinearLayout.LayoutParams(-1, 0, 1f));
        left.addView(lc, new FrameLayout.LayoutParams(-1, -1));
        row.addView(left, new LinearLayout.LayoutParams(0, -1, 3f));

        LinearLayout card = new LinearLayout(this);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setGravity(Gravity.CENTER);
        card.setBackground(Kit.rounded(this, 0xFF1C1C20, 24));
        card.setPadding(dp(24), dp(20), dp(24), dp(20));
        card.addView(Kit.text(this, "Rest", 15, 600, 0xB3FFFFFF), new LinearLayout.LayoutParams(-2, -2));
        restText = Kit.text(this, fmt(restSeconds), 42, 900, 0xFFFFFFFF);
        restText.setLetterSpacing(-0.025f);
        card.addView(restText, Kit.lp(this, -2, -2, 0, 6, 0, 0));
        TextView plus = Kit.text(this, "+20s", 12, 700, 0xB3FFFFFF);
        plus.setBackground(Kit.rounded(this, 0xFF2B2B32, 16));
        plus.setPadding(dp(16), dp(6), dp(16), dp(6));
        plus.setOnClickListener(v -> { restSeconds += 20; updateTimers(); });
        card.addView(plus, Kit.lp(this, -2, -2, 0, 14, 0, 0));
        TextView skip = Kit.text(this, "Skip", 15, 800, INK);
        skip.setGravity(Gravity.CENTER);
        skip.setBackground(Kit.rounded(this, LIME, 22));
        skip.setElevation(dp(5));
        skip.setOnClickListener(v -> advance());
        card.addView(skip, Kit.lp(this, dp(130), dp(44), 0, 16, 0, 0));
        LinearLayout.LayoutParams cp = new LinearLayout.LayoutParams(0, -1, 2f);
        cp.setMargins(dp(12), dp(12), dp(12), dp(12));
        row.addView(card, cp);
        return row;
    }

    private View encouragement() {
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        col.setGravity(Gravity.CENTER);
        col.setBackgroundColor(0xF0000000);
        col.setPadding(dp(40), 0, dp(40), 0);
        col.setClickable(true);
        col.addView(Kit.text(this, "5 exercises done!", 16, 800, LIME), new LinearLayout.LayoutParams(-2, -2));
        TextView msg = Kit.text(this, "You’re on the right track. Keep going!", 22, 800, 0xFFFFFFFF);
        msg.setGravity(Gravity.CENTER);
        col.addView(msg, Kit.lp(this, -2, -2, 0, 10, 0, 0));
        col.addView(pill("Keep exercising", LIME, INK, 36, 800,
                v -> { step = Step.RESTING; restSeconds = 20; preloadNext(); render(); }), Kit.lp(this, -2, -2, 0, 24, 0, 0));
        TextView later = Kit.text(this, "Do it later", 13, 600, 0x99FFFFFF);
        later.setOnClickListener(v -> exit());
        col.addView(later, Kit.lp(this, -2, -2, 0, 14, 0, 0));
        return col;
    }

    private View whyQuit() {
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        col.setGravity(Gravity.CENTER);
        col.setBackgroundColor(0xFF000000);
        col.setPadding(dp(40), 0, dp(40), 0);
        col.setClickable(true);
        col.addView(Kit.text(this, "Why quit?", 24, 800, LIME), new LinearLayout.LayoutParams(-2, -2));
        TextView msg = Kit.text(this, "Every challenge is a chance to grow. Stay focused, keep moving forward, and remember why you started this journey.",
                12, 400, 0xB3FFFFFF);
        msg.setGravity(Gravity.CENTER);
        msg.setLineSpacing(0, 1.15f);
        msg.setMaxWidth(dp(460));
        col.addView(msg, Kit.lp(this, -2, -2, 0, 10, 0, 0));
        col.addView(pillGroup(
                pill("Just take a look", LIME, INK, 20, 800, v -> exit()),
                pill("Too hard", 0xFF2C2C32, 0xFFFFFFFF, 24, 700, v -> exit()),
                pill("Too easy", 0xFF2C2C32, 0xFFFFFFFF, 24, 700, v -> exit())),
                Kit.lp(this, -2, -2, 0, 24, 0, 0));
        return col;
    }

    // ------------------------------------------------------------------ lifecycle

    @Override
    protected void onPause() {
        super.onPause();
        if (player != null) player.setPlayWhenReady(false);
    }

    @Override
    protected void onResume() {
        super.onResume();
        applyVideoState();
    }

    @Override
    protected void onDestroy() {
        handler.removeCallbacksAndMessages(null);
        if (player != null) { player.release(); player = null; }
        super.onDestroy();
    }
}
