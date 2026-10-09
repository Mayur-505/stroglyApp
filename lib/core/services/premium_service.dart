import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../network/api_client.dart';
import '../network/api_constants.dart';

/// A subscription plan from the backend, matched with its store product.
class PremiumPlan {
  final String id;
  final String title;
  final num price;
  final String currency;
  final String interval;
  final int trialDays;
  final bool isBestValue;
  final String androidProductId;
  final String androidBasePlanId;
  final String androidOfferId;
  final String iosProductId;
  ProductDetails? product;

  PremiumPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.interval,
    required this.trialDays,
    required this.isBestValue,
    required this.androidProductId,
    required this.androidBasePlanId,
    required this.androidOfferId,
    required this.iosProductId,
  });

  factory PremiumPlan.fromJson(Map<String, dynamic> json) => PremiumPlan(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        price: json['price'] as num? ?? 0,
        currency: json['currency']?.toString() ?? 'INR',
        interval: json['interval']?.toString() ?? 'year',
        trialDays: (json['trialDays'] as num?)?.toInt() ?? 0,
        isBestValue: json['isBestValue'] == true,
        androidProductId: json['androidProductId']?.toString() ?? '',
        androidBasePlanId: json['androidBasePlanId']?.toString() ?? '',
        androidOfferId: json['androidOfferId']?.toString() ?? '',
        iosProductId: json['iosProductId']?.toString() ?? '',
      );

  String get storeProductId => PremiumService.isIOS ? iosProductId : androidProductId;

  String get intervalLabel => switch (interval) {
        'month' => 'month',
        'lifetime' => 'lifetime',
        _ => 'year',
      };

  /// Store-localized price when available, otherwise the backend price.
  String get displayPrice {
    final p = product;
    if (p != null && p.rawPrice > 0) return p.price;
    final symbol = currency == 'INR' ? '₹' : '$currency ';
    return '$symbol${price.toString()}';
  }
}

/// Handles premium status, store purchases and backend verification.
class PremiumService extends ChangeNotifier {
  static final PremiumService instance = PremiumService._internal();
  factory PremiumService() => instance;
  PremiumService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  Completer<PurchaseResult>? _pendingPurchase;

  bool _isPremium = false;
  DateTime? _expiresAt;
  Map<String, dynamic>? _activeSubscription;
  Map<String, dynamic> _entitlements = {};
  bool _storeAvailable = false;

  bool get isPremium => _isPremium;
  DateTime? get expiresAt => _expiresAt;
  Map<String, dynamic>? get activeSubscription => _activeSubscription;
  bool get storeAvailable => _storeAvailable;
  bool get autoRenewing => _activeSubscription?['autoRenewing'] == true;
  bool can(String entitlement) => _entitlements[entitlement] == true;

  /// Call once at app start.
  Future<void> init() async {
    if (_supportsStore) {
      try {
        _storeAvailable = await _iap.isAvailable();
        _purchaseSub ??= _iap.purchaseStream.listen(
          _onPurchaseUpdates,
          onError: (Object e) => debugPrint('[PremiumService] purchase stream error: $e'),
        );
      } catch (e) {
        debugPrint('[PremiumService] store init failed: $e');
      }
    }
    await refreshStatus();
  }

  /// Reload premium status from the backend.
  Future<void> refreshStatus() async {
    final res = await ApiClient.instance.get(ApiConstants.subscriptionStatus);
    if (res.isOk && res.data is Map) {
      _applyStatus(Map<String, dynamic>.from(res.data as Map));
    } else if (res.statusCode == 401) {
      _applyStatus(const {});
    }
  }

  /// Clears premium state on logout.
  void reset() => _applyStatus(const {});

  void _applyStatus(Map<String, dynamic> data) {
    _isPremium = data['isPremium'] == true;
    _expiresAt = DateTime.tryParse(data['expiresAt']?.toString() ?? '');
    _activeSubscription =
        data['activeSubscription'] is Map ? Map<String, dynamic>.from(data['activeSubscription'] as Map) : null;
    _entitlements = data['entitlements'] is Map ? Map<String, dynamic>.from(data['entitlements'] as Map) : {};
    notifyListeners();
  }

  /// Backend plans matched with store products.
  Future<List<PremiumPlan>> loadPlans() async {
    final res = await ApiClient.instance.get(ApiConstants.subscriptionPlans);
    if (!res.isOk || res.data is! Map) return [];
    final raw = (res.data as Map)['plans'] as List<dynamic>? ?? [];
    final plans = raw.map((e) => PremiumPlan.fromJson(Map<String, dynamic>.from(e as Map))).toList();

    if (_storeAvailable) {
      final ids = plans.map((p) => p.storeProductId).where((id) => id.isNotEmpty).toSet();
      if (ids.isNotEmpty) {
        try {
          final response = await _iap.queryProductDetails(ids);
          for (final plan in plans) {
            plan.product = _matchProduct(plan, response.productDetails);
          }
        } catch (e) {
          debugPrint('[PremiumService] queryProductDetails failed: $e');
        }
      }
    }
    return plans;
  }

  ProductDetails? _matchProduct(PremiumPlan plan, List<ProductDetails> products) {
    final candidates = products.where((p) => p.id == plan.storeProductId).toList();
    if (candidates.isEmpty) return null;
    if (isIOS) return candidates.first;

    // Google returns one entry per base plan / offer
    ProductDetails? basePlanMatch;
    for (final p in candidates.whereType<GooglePlayProductDetails>()) {
      final index = p.subscriptionIndex;
      if (index == null) continue;
      final offer = p.productDetails.subscriptionOfferDetails![index];
      if (offer.basePlanId != plan.androidBasePlanId) continue;
      if (plan.androidOfferId.isNotEmpty && offer.offerId == plan.androidOfferId) return p;
      if (offer.offerId == null) basePlanMatch = p;
    }
    return basePlanMatch;
  }

  /// Starts the store purchase. Completes after the backend has verified it.
  Future<PurchaseResult> buy(PremiumPlan plan) async {
    final product = plan.product;
    if (product == null) {
      // Debug builds can test against a backend running with IAP_MOCK=true
      if (kDebugMode) return _mockPurchase(plan);
      return const PurchaseResult(false, 'This plan is not available in the store right now.');
    }
    if (_pendingPurchase != null) {
      return const PurchaseResult(false, 'A purchase is already in progress.');
    }

    _pendingPurchase = Completer<PurchaseResult>();
    try {
      final started = await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
      if (!started) _finishPending(const PurchaseResult(false, 'Could not start the purchase.'));
    } catch (e) {
      _finishPending(PurchaseResult(false, e.toString()));
    }
    return _pendingPurchase?.future ?? const PurchaseResult(false, 'Purchase failed.');
  }

  Future<PurchaseResult> _mockPurchase(PremiumPlan plan) async {
    final token = 'mock_${DateTime.now().millisecondsSinceEpoch}';
    final res = await ApiClient.instance.post(ApiConstants.verifyPurchase, {
      'platform': isIOS ? 'ios' : 'android',
      'planId': plan.id,
      'productId': plan.storeProductId,
      if (isIOS) 'transactionId': token else 'purchaseToken': token,
    });
    if (res.data is Map) _applyStatus(Map<String, dynamic>.from(res.data as Map));
    return PurchaseResult(res.isOk, res.message);
  }

  /// Asks the store for previous purchases; results arrive on the purchase stream.
  Future<void> restore() async {
    if (!_storeAvailable) return;
    await _iap.restorePurchases();
  }

  /// Turns off auto-renew. On iOS the user is sent to App Store settings (see [CancelResult.manageUrl]).
  Future<CancelResult> cancel() async {
    final res = await ApiClient.instance.post(ApiConstants.cancelSubscription);
    final data = res.data is Map ? Map<String, dynamic>.from(res.data as Map) : <String, dynamic>{};
    // iOS can't be canceled from the server: backend returns only { manageUrl }
    final requiresStoreAction = data.containsKey('manageUrl') && !data.containsKey('isPremium');
    if (res.isOk && !requiresStoreAction) _applyStatus(data);
    return CancelResult(
      success: res.isOk,
      message: res.message,
      manageUrl: requiresStoreAction ? data['manageUrl']?.toString() : null,
    );
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.error:
          _finishPending(PurchaseResult(false, purchase.error?.message ?? 'Purchase failed.'));
          break;
        case PurchaseStatus.canceled:
          _finishPending(const PurchaseResult(false, 'Purchase canceled.'));
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final result = await _verifyWithBackend(purchase, restored: purchase.status == PurchaseStatus.restored);
          _finishPending(result);
          break;
      }
      // Must always be completed, otherwise the store keeps re-sending it (and Google refunds it)
      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
        } catch (e) {
          debugPrint('[PremiumService] completePurchase failed: $e');
        }
      }
    }
  }

  Future<PurchaseResult> _verifyWithBackend(PurchaseDetails purchase, {required bool restored}) async {
    final platform = isIOS ? 'ios' : 'android';
    final item = <String, dynamic>{
      'productId': purchase.productID,
      if (isIOS)
        'transactionId': purchase.purchaseID
      else
        'purchaseToken': purchase.verificationData.serverVerificationData,
    };

    final res = restored
        ? await ApiClient.instance.post(ApiConstants.restorePurchases, {
            'platform': platform,
            'purchases': [item],
          })
        : await ApiClient.instance.post(ApiConstants.verifyPurchase, {'platform': platform, ...item});

    if (res.data is Map) _applyStatus(Map<String, dynamic>.from(res.data as Map));
    return PurchaseResult(_isPremium, res.message);
  }

  void _finishPending(PurchaseResult result) {
    final pending = _pendingPurchase;
    _pendingPurchase = null;
    if (pending != null && !pending.isCompleted) pending.complete(result);
  }

  /// True when the backend blocked a request because the user isn't premium.
  static bool isPremiumRequired(ApiResponse<dynamic> res) =>
      res.statusCode == 403 && res['code'] == 'PREMIUM_REQUIRED';

  static bool get _supportsStore {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  static bool get isIOS {
    if (kIsWeb) return false;
    try {
      return Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}

class PurchaseResult {
  final bool success;
  final String? message;
  const PurchaseResult(this.success, this.message);
}

class CancelResult {
  final bool success;
  final String? message;
  final String? manageUrl;
  const CancelResult({required this.success, this.message, this.manageUrl});
}

