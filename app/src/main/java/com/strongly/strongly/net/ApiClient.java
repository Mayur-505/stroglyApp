package com.strongly.strongly.net;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.strongly.strongly.util.Session;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.HttpUrl;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

/** JSON API client. Callbacks are delivered on the main thread. */
public final class ApiClient {
    public interface Listener { void onResult(ApiResponse r); }

    private static final MediaType JSON = MediaType.get("application/json");
    private static final ApiClient INSTANCE = new ApiClient();
    private final OkHttpClient http = new OkHttpClient.Builder()
            .connectTimeout(15, TimeUnit.SECONDS)
            .readTimeout(15, TimeUnit.SECONDS)
            .build();
    private final Handler main = new Handler(Looper.getMainLooper());

    private ApiClient() {}

    public static ApiClient get() { return INSTANCE; }

    private Request.Builder builder(String path, Map<String, String> query) {
        HttpUrl base = HttpUrl.parse(ApiConstants.BASE_URL + path);
        HttpUrl.Builder u = base.newBuilder();
        String lang = Session.language();
        if (!path.contains("/upload") && base.queryParameter("lang") == null) u.addQueryParameter("lang", lang);
        if (query != null) {
            for (Map.Entry<String, String> e : query.entrySet()) {
                if (e.getValue() != null) u.addQueryParameter(e.getKey(), e.getValue());
            }
        }
        Request.Builder b = new Request.Builder().url(u.build())
                .header("Accept", "application/json")
                .header("Accept-Language", lang);
        String t = Session.token();
        if (t != null && !t.isEmpty()) b.header("Authorization", "Bearer " + t);
        return b;
    }

    public void get(String path, Map<String, String> query, Listener cb) {
        run(builder(path, query).get().build(), cb);
    }

    public void post(String path, JsonObject body, Listener cb) {
        run(builder(path, null).post(RequestBody.create(body == null ? "{}" : body.toString(), JSON)).build(), cb);
    }

    public void put(String path, JsonObject body, Listener cb) {
        run(builder(path, null).put(RequestBody.create(body == null ? "{}" : body.toString(), JSON)).build(), cb);
    }

    public void delete(String path, Listener cb) {
        run(builder(path, null).delete().build(), cb);
    }

    public void uploadPhoto(byte[] bytes, String fileName, String mime, Listener cb) {
        RequestBody form = new MultipartBody.Builder().setType(MultipartBody.FORM)
                .addFormDataPart("photo", fileName, RequestBody.create(bytes, MediaType.parse(mime)))
                .build();
        run(builder(ApiConstants.UPLOAD_PHOTO, null).post(form).build(), cb);
    }

    private void run(Request req, Listener cb) {
        http.newCall(req).enqueue(new Callback() {
            @Override public void onFailure(@NonNull Call call, @NonNull IOException e) {
                deliver(cb, new ApiResponse(false, e.getMessage(), null, 500));
            }

            @Override public void onResponse(@NonNull Call call, @NonNull Response resp) throws IOException {
                String text = resp.body() != null ? resp.body().string() : "";
                int code = resp.code();
                boolean ok = code >= 200 && code < 300;
                String msg = null;
                JsonElement data = null;
                try {
                    JsonElement root = JsonParser.parseString(text);
                    if (root.isJsonObject()) {
                        JsonObject o = root.getAsJsonObject();
                        if (o.has("success")) ok = ok && o.get("success").getAsBoolean();
                        if (o.has("message") && !o.get("message").isJsonNull()) msg = o.get("message").getAsString();
                        data = o.has("data") ? o.get("data") : o;
                    } else {
                        data = root;
                    }
                } catch (Exception ignored) {
                    if (!ok) msg = "Server error (" + code + ")";
                }
                deliver(cb, new ApiResponse(ok, msg, data, code));
            }
        });
    }

    private void deliver(Listener cb, ApiResponse r) { main.post(() -> cb.onResult(r)); }
}
