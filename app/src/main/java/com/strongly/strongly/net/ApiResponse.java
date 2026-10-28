package com.strongly.strongly.net;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

public class ApiResponse {
    public final boolean success;
    public final String message;
    public final JsonElement data;
    public final int statusCode;

    public ApiResponse(boolean success, String message, JsonElement data, int statusCode) {
        this.success = success;
        this.message = message;
        this.data = data;
        this.statusCode = statusCode;
    }

    public boolean isOk() { return success && statusCode >= 200 && statusCode < 300; }

    public JsonObject dataObject() {
        return data != null && data.isJsonObject() ? data.getAsJsonObject() : new JsonObject();
    }
}
