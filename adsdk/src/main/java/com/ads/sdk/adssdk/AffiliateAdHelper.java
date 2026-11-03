package com.ads.sdk.adssdk;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.browser.customtabs.CustomTabsIntent;
import androidx.core.content.ContextCompat;
import androidx.core.view.ViewCompat;

import com.bumptech.glide.Glide;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class AffiliateAdHelper {

    public static final String AFFILIATE_JSON_URL = GetFirebasedata.qureka_server;

    private static final String TAG = "AffiliateAdHelper";

    public static void fetchAndCache(Context context) {
        if (context == null) return;
        final Context appContext = context.getApplicationContext();
        new Thread(() -> {
            HttpURLConnection connection = null;
            try {
                String serverUrl = GetFirebasedata.qureka_server;
                if (TextUtils.isEmpty(serverUrl)) {
                    serverUrl = AFFILIATE_JSON_URL;
                }
                if (TextUtils.isEmpty(serverUrl)) {
                    return;
                }
                URL url = new URL(serverUrl);
                connection = (HttpURLConnection) url.openConnection();
                connection.setConnectTimeout(15000);
                connection.setReadTimeout(15000);
                connection.setRequestMethod("GET");
                connection.connect();

                if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) {
                    Log.w(TAG, "fetch failed code=" + connection.getResponseCode());
                    return;
                }

                InputStream inputStream = connection.getInputStream();
                BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
                StringBuilder builder = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    builder.append(line);
                }
                reader.close();

                String body = builder.toString();
                JSONObject root = new JSONObject(body);
                if (!root.has("response") || !(root.get("response") instanceof JSONArray)) {
                    Log.w(TAG, "invalid response array");
                    return;
                }
                if (root.getJSONArray("response").length() == 0) {
                    Log.w(TAG, "empty response array");
                    return;
                }

                new PreferencesHelper(appContext).setAffiliateAdsJson(body);
                Log.d(TAG, "affiliate ads cached, count=" + root.getJSONArray("response").length());
            } catch (Exception e) {
                Log.e(TAG, "fetchAndCache error", e);
            } finally {
                if (connection != null) {
                    connection.disconnect();
                }
            }
        }).start();
    }

    public static AffiliateAdItem getRandomItem(Context context) {
        if (context == null) return null;
        try {
            String json = new PreferencesHelper(context).getAffiliateAdsJson();
            if (TextUtils.isEmpty(json)) return null;

            JSONArray array = new JSONObject(json).optJSONArray("response");
            if (array == null || array.length() == 0) return null;

            List<AffiliateAdItem> items = new ArrayList<>();
            for (int i = 0; i < array.length(); i++) {
                JSONObject obj = array.optJSONObject(i);
                if (obj == null) continue;
                items.add(new AffiliateAdItem(
                        obj.optString("AId", ""),
                        obj.optString("App_Name", ""),
                        obj.optString("Package_Name", ""),
                        obj.optString("App_Logo", ""),
                        obj.optString("App_Banner", ""),
                        obj.optString("Playstore_link", ""),
                        obj.optString("App_Description", ""),
                        obj.optString("App_Button_Name", "")
                ));
            }
            if (items.isEmpty()) return null;
            return items.get(new Random().nextInt(items.size()));
        } catch (Exception e) {
            Log.e(TAG, "getRandomItem error", e);
            return null;
        }
    }

    /** Banner strip: AD + logo + App_Name + App_Description + App_Button_Name. */
    public static boolean bindBanner(Context context, View root) {
        AffiliateAdItem item = getRandomItem(context);
        if (item == null || root == null) return false;

        TextView tvTitle = root.findViewById(R.id.tv_title);
        TextView tvMessage = root.findViewById(R.id.tv_message);
        ImageView ivLogo = root.findViewById(R.id.iv_logo);
        Button btnPlay = root.findViewById(R.id.btn_playnow);
        View clickRoot = root.findViewById(R.id.ll_atmeclick);

        // ad games = App_Name
        if (tvTitle != null) {
            tvTitle.setText(item.appName);
            tvTitle.setVisibility(TextUtils.isEmpty(item.appName) ? View.GONE : View.VISIBLE);
        }
        // description = App_Description
        if (tvMessage != null) {
            tvMessage.setText(item.appDescription);
            tvMessage.setVisibility(TextUtils.isEmpty(item.appDescription) ? View.GONE : View.VISIBLE);
        }
        // btn name = App_Button_Name
        if (btnPlay != null) {
            btnPlay.setBackgroundResource(R.drawable.bg_loading_subtitles_accent_yllw);
            ViewCompat.setBackgroundTintList(btnPlay, null);
            if (!TextUtils.isEmpty(item.appButtonName)) {
                btnPlay.setText(item.appButtonName);
            }
        }
        // logo = App_Logo
        if (ivLogo != null && !TextUtils.isEmpty(item.appLogo)) {
            Glide.with(context)
                    .load(item.appLogo)
                    .centerCrop()
                    .placeholder(R.drawable.atmebanner)
                    .error(R.drawable.atmebanner)
                    .into(ivLogo);
        }

        View.OnClickListener open = v -> openPlaystore(context, item.playstoreLink);
        if (btnPlay != null) btnPlay.setOnClickListener(open);
        if (clickRoot != null) clickRoot.setOnClickListener(open);
        return true;
    }

    /** Large native: banner, logo, title, subtitle, description, CTA. Returns true if bound. */
    public static boolean bindNative(Context context, View root) {
        AffiliateAdItem item = getRandomItem(context);
        if (item == null || root == null) return false;

        TextView tvTitle = root.findViewById(R.id.tv_title);
        TextView tvDescription = root.findViewById(R.id.tv_description);
        ImageView mediaView = root.findViewById(R.id.media_view);
        ImageView ivLogo = root.findViewById(R.id.iv_logo);
        Button btnPlay = root.findViewById(R.id.btn_playnow);
        View clickRoot = root.findViewById(R.id.ll_atmeclick);

        if (tvTitle != null) tvTitle.setText(item.appName);
        if (tvDescription != null) tvDescription.setText(item.appDescription);
        if (btnPlay != null) {
            btnPlay.setBackgroundResource(R.drawable.bg_loading_subtitles_accent_yllw);
            ViewCompat.setBackgroundTintList(btnPlay, null);
            if (!TextUtils.isEmpty(item.appButtonName)) {
                btnPlay.setText(item.appButtonName);
            }
        }
        if (mediaView != null && !TextUtils.isEmpty(item.appBanner)) {
            try {
                Glide.with(context).load(item.appBanner).into(mediaView);
            } catch (Exception e) {
            }
        }
        if (ivLogo != null && !TextUtils.isEmpty(item.appLogo)) {
            try {
                Glide.with(context).load(item.appLogo).into(ivLogo);
            } catch (Exception e) {

            }
        }

        View.OnClickListener open = v -> openPlaystore(context, GetFirebasedata.getNextQurekaUrl(context));
        if (btnPlay != null) btnPlay.setOnClickListener(open);
        if (clickRoot != null) clickRoot.setOnClickListener(open);
        return true;
    }

    @SuppressLint("WrongConstant")
    public static void openPlaystore(Context context, String url) {
        if (context == null) return;

        if (TextUtils.isEmpty(url) || url.equals(GetFirebasedata.QurekaAppURL) || url.contains(",")) {
            url = GetFirebasedata.getNextQurekaUrl(context);
        }
        if (TextUtils.isEmpty(url)) return;

        try {
            CustomTabsIntent.Builder builder = new CustomTabsIntent.Builder();
            builder.setToolbarColor(ContextCompat.getColor(context, R.color.install_color));
            CustomTabsIntent customTabsIntent = builder.build();
            PackageManager pm = context.getPackageManager();
            try {
                pm.getPackageInfo("com.android.chrome", PackageManager.GET_ACTIVITIES);
                customTabsIntent.intent.setPackage("com.android.chrome");
            } catch (PackageManager.NameNotFoundException e) {
                customTabsIntent.intent.setPackage(null);
            }
            customTabsIntent.launchUrl(context, Uri.parse(url));
        } catch (Exception e) {
            try {
                Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
                browserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(browserIntent);
            } catch (Exception ex) {
                Log.e(TAG, "openPlaystore error", ex);
            }
        }
    }
}
