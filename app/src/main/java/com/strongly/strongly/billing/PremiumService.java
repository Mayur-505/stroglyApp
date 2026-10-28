package com.strongly.strongly.billing;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ApplicationInfo;

import com.android.billingclient.api.AcknowledgePurchaseParams;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.PendingPurchasesParams;
import com.android.billingclient.api.ProductDetails;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.QueryProductDetailsParams;
import com.android.billingclient.api.QueryPurchasesParams;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.strongly.strongly.net.ApiClient;
import com.strongly.strongly.net.ApiConstants;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/** Premium status, Play Billing purchases and backend verification (Flutter's PremiumService). */
public final class PremiumService {
    // ------------------------------------------------------------------ models

    public static class Plan {
        public final String id, title, currency, interval, androidProductId, androidBasePlanId, androidOfferId;
        public final double price;
        public final int trialDays;
        public final boolean isBestValue;
        ProductDetails product;
        String offerToken;
        String storePrice;

        Plan(JsonObject o) {
            id = str(o, "id", "");
            title = str(o, "title", "");
            price = o.has("price") && !o.get("price").isJsonNull() ? o.get("price").getAsDouble() : 0;
            currency = str(o, "currency", "INR");
            interval = str(o, "interval", "year");
            trialDays = o.has("trialDays") && !o.get("trialDays").isJsonNull() ? o.get("trialDays").getAsInt() : 0;
            isBestValue = o.has("isBestValue") && !o.get("isBestValue").isJsonNull() && o.get("isBestValue").getAsBoolean();
            androidProductId = str(o, "androidProductId", "");
            androidBasePlanId = str(o, "androidBasePlanId", "");
            androidOfferId = str(o, "androidOfferId", "");
        }

        public String intervalLabel() {
            switch (interval) {
                case "month": return "month";
                case "lifetime": return "lifetime";
                default: return "year";
            }
        }

        /** Store-localized price when available, otherwise the backend price. */
        public String displayPrice() {
            if (storePrice != null) return storePrice;
            String symbol = currency.equals("INR") ? "₹" : currency + " ";
            String p = price == Math.floor(price) ? String.valueOf((long) price) : String.valueOf(price);
            return symbol + p;
        }
    }

    public static class Plans {
        public List<Plan> plans = new ArrayList<>();
        public List<String> benefits = new ArrayList<>();
        public List<String[]> terms = new ArrayList<>();
        public String trialOffer = "";
    }

    public static class PurchaseResult {
        public final boolean success;
        public final String message;
        public PurchaseResult(boolean success, String message) { this.success = success; this.message = message; }
    }

    public static class CancelResult {
        public final boolean success;
        public final String message, manageUrl;
        CancelResult(boolean success, String message, String manageUrl) { this.success = success; this.message = message; this.manageUrl = manageUrl; }
    }

    public interface Callback<T> { void done(T result); }

    // ------------------------------------------------------------------ state

    private static final PremiumService INSTANCE = new PremiumService();
    public static PremiumService get() { return INSTANCE; }

    private Context app;
    private BillingClient billing;
    private boolean storeAvailable = false;
    private boolean debuggable = false;
    private Callback<PurchaseResult> pending;
    private Plan pendingPlan;

    private boolean premium = false;
    private String expiresAt;
    private JsonObject activeSubscription;
    private JsonObject entitlements = new JsonObject();
    private final List<Runnable> listeners = new ArrayList<>();

    private final android.os.Handler main = new android.os.Handler(android.os.Looper.getMainLooper());

    private PremiumService() {}

    private static String str(JsonObject o, String k, String def) {
        return o.has(k) && !o.get(k).isJsonNull() ? o.get(k).getAsString() : def;
    }

    public boolean isPremium() { return premium; }
    public boolean autoRenewing() { return activeSubscription != null && activeSubscription.has("autoRenewing")
            && activeSubscription.get("autoRenewing").getAsBoolean(); }
    public boolean isTrial() { return activeSubscription != null && activeSubscription.has("isTrial")
            && activeSubscription.get("isTrial").getAsBoolean(); }
    public boolean can(String entitlement) { return entitlements.has(entitlement) && entitlements.get(entitlement).getAsBoolean(); }
    public String expiresAtFormatted() {
        if (expiresAt == null) return "";
        try {
            java.time.ZonedDateTime d = Instant.parse(expiresAt).atZone(java.time.ZoneId.systemDefault());
            String[] m = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
            return d.getDayOfMonth() + " " + m[d.getMonthValue() - 1] + " " + d.getYear();
        } catch (Exception e) { return ""; }
    }

    public void addListener(Runnable r) { if (!listeners.contains(r)) listeners.add(r); }
    public void removeListener(Runnable r) { listeners.remove(r); }
    private void notifyChanged() { for (Runnable r : new ArrayList<>(listeners)) r.run(); }

    /** Call once at app start. */
    public void init(Context context) {
        app = context.getApplicationContext();
        debuggable = (app.getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;
        billing = BillingClient.newBuilder(app)
                .setListener((result, purchases) -> main.post(() -> onPurchasesUpdated(result, purchases)))
                .enablePendingPurchases(PendingPurchasesParams.newBuilder().enableOneTimeProducts().build())
                .build();
        connect(null);
        refreshStatus(null);
    }

    private void connect(Runnable then) {
        if (billing == null) { if (then != null) then.run(); return; }
        if (billing.isReady()) { storeAvailable = true; if (then != null) then.run(); return; }
        // the store can fail to answer (no Play Store / unsupported device): carry on without it after a short wait
        final boolean[] fired = {false};
        final Runnable once = () -> {
            if (fired[0]) return;
            fired[0] = true;
            if (then != null) then.run();
        };
        main.postDelayed(once, 4000);
        billing.startConnection(new BillingClientStateListener() {
            @Override public void onBillingSetupFinished(BillingResult r) {
                storeAvailable = r.getResponseCode() == BillingClient.BillingResponseCode.OK;
                main.post(once);
            }

            @Override public void onBillingServiceDisconnected() { storeAvailable = false; }
        });
    }

    // ------------------------------------------------------------------ status

    public void refreshStatus(Runnable done) {
        ApiClient.get().get(ApiConstants.SUBSCRIPTION_STATUS, null, r -> {
            if (r.isOk() && r.data != null && r.data.isJsonObject()) applyStatus(r.data.getAsJsonObject());
            else if (r.statusCode == 401) applyStatus(new JsonObject());
            if (done != null) done.run();
        });
    }

    public void reset() { applyStatus(new JsonObject()); }

    private void applyStatus(JsonObject d) {
        premium = d.has("isPremium") && !d.get("isPremium").isJsonNull() && d.get("isPremium").getAsBoolean();
        expiresAt = d.has("expiresAt") && !d.get("expiresAt").isJsonNull() ? d.get("expiresAt").getAsString() : null;
        activeSubscription = d.has("activeSubscription") && d.get("activeSubscription").isJsonObject()
                ? d.getAsJsonObject("activeSubscription") : null;
        entitlements = d.has("entitlements") && d.get("entitlements").isJsonObject() ? d.getAsJsonObject("entitlements") : new JsonObject();
        notifyChanged();
    }

    // ------------------------------------------------------------------ plans

    /** Backend plans (with benefits and terms) matched with their store products. */
    public void loadPlans(Callback<Plans> cb) {
        ApiClient.get().get(ApiConstants.SUBSCRIPTION_PLANS, null, r -> {
            Plans out = new Plans();
            if (!r.isOk() || r.data == null || !r.data.isJsonObject()) { cb.done(out); return; }
            JsonObject d = r.data.getAsJsonObject();
            if (d.has("data") && d.get("data").isJsonObject()) d = d.getAsJsonObject("data");
            out.trialOffer = str(d, "trialOffer", "");
            if (d.has("plans") && d.get("plans").isJsonArray())
                for (JsonElement e : d.getAsJsonArray("plans")) if (e.isJsonObject()) out.plans.add(new Plan(e.getAsJsonObject()));
            if (d.has("benefits") && d.get("benefits").isJsonArray())
                for (JsonElement e : d.getAsJsonArray("benefits")) out.benefits.add(e.getAsString());
            if (d.has("terms") && d.get("terms").isJsonArray())
                for (JsonElement e : d.getAsJsonArray("terms")) if (e.isJsonObject())
                    out.terms.add(new String[]{str(e.getAsJsonObject(), "numberTitle", ""), str(e.getAsJsonObject(), "description", "")});
            attachProducts(out, () -> cb.done(out));
        });
    }

    private void attachProducts(Plans plans, Runnable done) {
        Set<String> ids = new HashSet<>();
        for (Plan p : plans.plans) if (!p.androidProductId.isEmpty()) ids.add(p.androidProductId);
        if (ids.isEmpty() || billing == null) { done.run(); return; }
        connect(() -> {
            if (!storeAvailable) { done.run(); return; }
            List<QueryProductDetailsParams.Product> products = new ArrayList<>();
            for (String id : ids) products.add(QueryProductDetailsParams.Product.newBuilder()
                    .setProductId(id).setProductType(BillingClient.ProductType.SUBS).build());
            billing.queryProductDetailsAsync(QueryProductDetailsParams.newBuilder().setProductList(products).build(),
                    (result, details) -> main.post(() -> {
                        if (result.getResponseCode() == BillingClient.BillingResponseCode.OK && details != null)
                            for (Plan p : plans.plans) match(p, details);
                        done.run();
                    }));
        });
    }

    /** Google returns one entry per base plan / offer; pick the one the backend plan names. */
    private void match(Plan plan, List<ProductDetails> details) {
        for (ProductDetails pd : details) {
            if (!pd.getProductId().equals(plan.androidProductId) || pd.getSubscriptionOfferDetails() == null) continue;
            ProductDetails.SubscriptionOfferDetails basePlanMatch = null;
            for (ProductDetails.SubscriptionOfferDetails offer : pd.getSubscriptionOfferDetails()) {
                if (!offer.getBasePlanId().equals(plan.androidBasePlanId)) continue;
                if (!plan.androidOfferId.isEmpty() && plan.androidOfferId.equals(offer.getOfferId())) { bind(plan, pd, offer); return; }
                if (offer.getOfferId() == null) basePlanMatch = offer;
            }
            if (basePlanMatch != null) { bind(plan, pd, basePlanMatch); return; }
        }
    }

    private void bind(Plan plan, ProductDetails pd, ProductDetails.SubscriptionOfferDetails offer) {
        plan.product = pd;
        plan.offerToken = offer.getOfferToken();
        List<ProductDetails.PricingPhase> phases = offer.getPricingPhases().getPricingPhaseList();
        if (!phases.isEmpty()) {
            ProductDetails.PricingPhase last = phases.get(phases.size() - 1);
            if (last.getPriceAmountMicros() > 0) plan.storePrice = last.getFormattedPrice();
        }
    }

    // ------------------------------------------------------------------ purchase

    public void buy(Activity activity, Plan plan, Callback<PurchaseResult> cb) {
        if (plan.product == null || plan.offerToken == null) {
            // Debug builds can test against a backend running with IAP_MOCK=true
            if (debuggable) { mockPurchase(plan, cb); return; }
            cb.done(new PurchaseResult(false, "This plan is not available in the store right now."));
            return;
        }
        if (pending != null) { cb.done(new PurchaseResult(false, "A purchase is already in progress.")); return; }
        pending = cb;
        pendingPlan = plan;
        BillingFlowParams params = BillingFlowParams.newBuilder()
                .setProductDetailsParamsList(Collections.singletonList(
                        BillingFlowParams.ProductDetailsParams.newBuilder()
                                .setProductDetails(plan.product).setOfferToken(plan.offerToken).build()))
                .build();
        BillingResult r = billing.launchBillingFlow(activity, params);
        if (r.getResponseCode() != BillingClient.BillingResponseCode.OK) finishPending(new PurchaseResult(false, "Could not start the purchase."));
    }

    private void mockPurchase(Plan plan, Callback<PurchaseResult> cb) {
        JsonObject body = new JsonObject();
        body.addProperty("platform", "android");
        body.addProperty("planId", plan.id);
        body.addProperty("productId", plan.androidProductId);
        body.addProperty("purchaseToken", "mock_" + System.currentTimeMillis());
        ApiClient.get().post(ApiConstants.VERIFY_PURCHASE, body, r -> {
            if (r.data != null && r.data.isJsonObject()) applyStatus(r.data.getAsJsonObject());
            cb.done(new PurchaseResult(r.isOk(), r.message));
        });
    }

    private void onPurchasesUpdated(BillingResult result, List<Purchase> purchases) {
        int code = result.getResponseCode();
        if (code == BillingClient.BillingResponseCode.USER_CANCELED) { finishPending(new PurchaseResult(false, "Purchase canceled.")); return; }
        if (code != BillingClient.BillingResponseCode.OK || purchases == null) {
            finishPending(new PurchaseResult(false, result.getDebugMessage() != null && !result.getDebugMessage().isEmpty()
                    ? result.getDebugMessage() : "Purchase failed."));
            return;
        }
        for (Purchase p : purchases) {
            if (p.getPurchaseState() != Purchase.PurchaseState.PURCHASED) continue; // pending: wait for the next update
            verify(p, false, res -> finishPending(res));
        }
    }

    private void verify(Purchase purchase, boolean restored, Callback<PurchaseResult> cb) {
        JsonObject item = new JsonObject();
        String productId = purchase.getProducts().isEmpty() ? "" : purchase.getProducts().get(0);
        item.addProperty("productId", productId);
        item.addProperty("purchaseToken", purchase.getPurchaseToken());
        JsonObject body;
        String path;
        if (restored) {
            body = new JsonObject();
            body.addProperty("platform", "android");
            JsonArray arr = new JsonArray();
            arr.add(item);
            body.add("purchases", arr);
            path = ApiConstants.RESTORE_PURCHASES;
        } else {
            body = item;
            body.addProperty("platform", "android");
            path = ApiConstants.VERIFY_PURCHASE;
        }
        ApiClient.get().post(path, body, r -> {
            if (r.data != null && r.data.isJsonObject()) applyStatus(r.data.getAsJsonObject());
            // Must always be acknowledged, otherwise Google refunds the purchase
            if (!purchase.isAcknowledged()) {
                billing.acknowledgePurchase(AcknowledgePurchaseParams.newBuilder().setPurchaseToken(purchase.getPurchaseToken()).build(),
                        ack -> { });
            }
            cb.done(new PurchaseResult(premium, r.message));
        });
    }

    private void finishPending(PurchaseResult r) {
        Callback<PurchaseResult> cb = pending;
        pending = null;
        pendingPlan = null;
        if (cb != null) cb.done(r);
    }

    /** Re-checks previous store purchases and sends them to the backend. */
    public void restore(Runnable done) {
        connect(() -> {
            if (!storeAvailable) { done.run(); return; }
            billing.queryPurchasesAsync(QueryPurchasesParams.newBuilder().setProductType(BillingClient.ProductType.SUBS).build(),
                    (result, purchases) -> main.post(() -> {
                        if (result.getResponseCode() != BillingClient.BillingResponseCode.OK || purchases == null || purchases.isEmpty()) {
                            done.run();
                            return;
                        }
                        final int[] left = {purchases.size()};
                        for (Purchase p : purchases) verify(p, true, r -> { if (--left[0] == 0) done.run(); });
                    }));
        });
    }

    /** Turns off auto-renew. */
    public void cancel(Callback<CancelResult> cb) {
        ApiClient.get().post(ApiConstants.CANCEL_SUBSCRIPTION, null, r -> {
            JsonObject d = r.data != null && r.data.isJsonObject() ? r.data.getAsJsonObject() : new JsonObject();
            boolean needsStore = d.has("manageUrl") && !d.has("isPremium");
            if (r.isOk() && !needsStore) applyStatus(d);
            cb.done(new CancelResult(r.isOk(), r.message, needsStore ? str(d, "manageUrl", null) : null));
        });
    }
}
