import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../services/remote_config_service.dart';
import 'ad_config.dart';
import 'ad_navigator_observer.dart';
import 'app_open_ad_manager.dart';
import 'consent_manager.dart';
import 'full_screen_ad_slot.dart';
import 'interstitial_ad_manager.dart';
import 'native_ad_pool.dart';
import 'rewarded_ad_manager.dart';

/// Single entry point for ads. Screens never talk to the SDK directly:
/// they use [AdPlacement] widgets, [rewarded], or the quiet-zone API.
///
/// Every public method is safe to call when ads are disabled, the user is
/// premium, consent was refused, Firebase failed, or the platform is not
/// Android/iOS — it simply does nothing.
class AdsManager {
  static final AdsManager instance = AdsManager._internal();
  factory AdsManager() => instance;
  AdsManager._internal();

  /// Lets ad code show dialogs without a BuildContext. Set on MaterialApp.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late final AdNavigatorObserver navigatorObserver = AdNavigatorObserver(this);

  final ConsentManager consent = ConsentManager();
  late final AppOpenAdManager appOpen = AppOpenAdManager(this);
  late final InterstitialAdManager interstitial = InterstitialAdManager(this);
  late final RewardedAdManager rewarded = RewardedAdManager(this);
  late final NativeAdPool nativePool = NativeAdPool(this);

  /// True when banner/native placements may load. Widgets listen to this.
  final ValueNotifier<bool> placementsEnabled = ValueNotifier(false);

  final Completer<void> _ready = Completer<void>();
  bool _initStarted = false;
  bool _sdkReady = false;
  bool _consentOk = false;
  bool _isPremium = false;
  bool _fullScreenShowing = false;
  DateTime? _lastFullScreenClosed;
  int _quietZones = 0;
  bool _pendingWorkoutInterstitial = false;

  static const _kPremium = 'ads_is_premium';

  bool get debugLogs => kDebugMode;

  /// Completes once consent + SDK init finished (successfully or not).
  Future<void> get ready => _ready.future;

  AdConfig get config => AdConfig(RemoteConfigService.instance.getString);

  bool get isPremium => _isPremium;

  bool get isSupported {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  bool get _platformAllowed {
    if (!isSupported) return false;
    // iOS needs its own AdMob app + unit ids. Until `ios_ads_status` is 1,
    // iOS only gets Google test ads in debug builds.
    if (Platform.isIOS && !kDebugMode && !config.iosAdsEnabled) return false;
    return true;
  }

  /// Any ad may be requested right now.
  bool get canRequestAds =>
      _sdkReady && _consentOk && _platformAllowed && !_isPremium && config.adsEnabled;

  /// A full-screen ad may be shown right now.
  bool get canShowFullScreen =>
      canRequestAds &&
      _quietZones == 0 &&
      !_fullScreenShowing &&
      !consent.formShowing;

  bool recentlyClosedFullScreen(Duration within) =>
      _lastFullScreenClosed != null &&
      DateTime.now().difference(_lastFullScreenClosed!) < within;

  // ------------------------------------------------------------------ init

  /// Call once after Firebase/Remote Config. Does not block the UI: run it
  /// unawaited and let the splash wait on [ready] with its own timeout.
  Future<void> init() async {
    if (_initStarted) return;
    _initStarted = true;
    try {
      await _loadPremium();
      if (!isSupported) {
        _log('unsupported platform, ads off');
        return;
      }
      unawaited(_refreshPremiumFromServer());
      if (!_platformAllowed || !config.adsEnabled) {
        _log('ads disabled by config/platform');
        return;
      }

      // Consent from the previous session lets us start the SDK right away
      // while the consent info refreshes in parallel.
      _consentOk = await consent.canRequestAds();
      final gather = consent.gatherConsent(underAgeOfConsent: config.childDirected);
      if (_consentOk) {
        await _startSdk();
        _consentOk = await gather;
      } else {
        _consentOk = await gather;
        if (_consentOk) await _startSdk();
      }
      if (!_consentOk) _log('consent not given, ads off');
      _onAvailabilityChanged();
    } catch (e) {
      _log('init failed: $e');
    } finally {
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  Future<void> _startSdk() async {
    if (_sdkReady) return;
    final cfg = config;
    await MobileAds.instance
        .initialize()
        .timeout(const Duration(seconds: 8), onTimeout: () => InitializationStatus({}));
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: cfg.testDeviceIds,
        maxAdContentRating: switch (cfg.maxAdContentRating) {
          'G' => MaxAdContentRating.g,
          'PG' => MaxAdContentRating.pg,
          'MA' => MaxAdContentRating.ma,
          'T' => MaxAdContentRating.t,
          _ => null,
        },
        ageRestrictedTreatment: cfg.childDirected
            ? AgeRestrictedTreatment.child
            : AgeRestrictedTreatment.unspecified,
      ),
    );
    _sdkReady = true;
    _log('SDK ready');
  }

  /// Re-evaluates availability: preloads or drops cached ads.
  void _onAvailabilityChanged() {
    final available = canRequestAds;
    placementsEnabled.value = available;
    if (available) {
      appOpen.startListening();
      appOpen.preload();
      interstitial.preload();
      if (config.rewardEnabled) rewarded.preload();
      nativePool.preload();
    } else {
      appOpen.clear();
      interstitial.clear();
      rewarded.clear();
      nativePool.clear();
    }
  }

  // --------------------------------------------------------------- unit ids

  /// Units to try for [format]. Debug builds always use Google's test
  /// units so live ids never get test traffic.
  List<AdUnit> unitsFor(AdFormat format) {
    if (kDebugMode) return [AdUnit(_testUnit(format))];
    return config.unitsFor(format);
  }

  static String _testUnit(AdFormat format) {
    final ios = !kIsWeb && Platform.isIOS;
    return switch (format) {
      AdFormat.appOpen => ios
          ? 'ca-app-pub-3940256099942544/5575463023'
          : 'ca-app-pub-3940256099942544/9257395921',
      AdFormat.interstitial => ios
          ? 'ca-app-pub-3940256099942544/4411468910'
          : 'ca-app-pub-3940256099942544/1033173712',
      AdFormat.rewarded => ios
          ? 'ca-app-pub-3940256099942544/1712485313'
          : 'ca-app-pub-3940256099942544/5224354917',
      AdFormat.banner => ios
          ? 'ca-app-pub-3940256099942544/2934735716'
          : 'ca-app-pub-3940256099942544/6300978111',
      AdFormat.native => ios
          ? 'ca-app-pub-3940256099942544/3986624511'
          : 'ca-app-pub-3940256099942544/2247696110',
    };
  }

  // ------------------------------------------------------------ full screen

  /// Shows a loaded full-screen ad and tracks that one is on screen.
  Future<bool> presentFullScreen(
    LoadedFullScreenAd ad, {
    VoidCallback? onReward,
    bool bypassQuietZone = false,
  }) async {
    final allowed = bypassQuietZone
        ? canRequestAds && !_fullScreenShowing
        : canShowFullScreen;
    if (!allowed) {
      ad.dispose();
      return false;
    }
    _fullScreenShowing = true;
    _log('showing ${ad.unit}');
    try {
      return await ad.present(onReward: onReward);
    } finally {
      _fullScreenShowing = false;
      _lastFullScreenClosed = DateTime.now();
      interstitial.pacer.markShown(DateTime.now());
    }
  }

  // ------------------------------------------------------------ quiet zones

  /// Blocks interstitials and app-open ads, e.g. during an active workout.
  /// Every call must be paired with [endQuietZone].
  void beginQuietZone(String reason) {
    _quietZones++;
    _log('quiet zone on ($reason)');
  }

  void endQuietZone(String reason) {
    if (_quietZones > 0) _quietZones--;
    _log('quiet zone off ($reason)');
    if (_quietZones == 0 && _pendingWorkoutInterstitial) {
      _pendingWorkoutInterstitial = false;
      // Let the screen rotate back to portrait before showing anything.
      Future.delayed(const Duration(milliseconds: 900), interstitial.showForWorkoutComplete);
    }
  }

  bool get inQuietZone => _quietZones > 0;

  /// Call when a workout day is completed. The interstitial is deferred
  /// until the workout screen has closed.
  void onWorkoutDayCompleted() {
    if (_quietZones > 0) {
      _pendingWorkoutInterstitial = true;
    } else {
      Future.delayed(const Duration(milliseconds: 500), interstitial.showForWorkoutComplete);
    }
  }

  // ---------------------------------------------------------------- premium

  Future<void> setPremium(bool value) async {
    if (_isPremium == value) return;
    _isPremium = value;
    _log('premium = $value');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kPremium, value);
    } catch (_) {}
    _onAvailabilityChanged();
  }

  Future<void> _loadPremium() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool(_kPremium) ?? false;
    } catch (_) {}
  }

  /// Syncs premium state with `/subscriptions/my-status`. Unknown response
  /// shapes leave the cached value untouched.
  Future<void> refreshPremium() => _refreshPremiumFromServer();

  Future<void> _refreshPremiumFromServer() async {
    try {
      final res = await ApiClient.instance
          .get(ApiConstants.subscriptionStatus)
          .timeout(const Duration(seconds: 10));
      if (!res.isOk) return;
      final premium = parsePremiumStatus(res.data);
      if (premium != null) await setPremium(premium);
    } catch (_) {}
  }

  /// Reads common subscription-status shapes; null when unrecognised.
  static bool? parsePremiumStatus(dynamic data) {
    if (data is! Map) return null;
    for (final key in ['isPremium', 'is_premium', 'premium', 'isActive', 'active']) {
      final v = data[key];
      if (v is bool) return v;
    }
    final status = data['status'];
    if (status is String) {
      return const {'active', 'trialing', 'trial'}.contains(status.toLowerCase());
    }
    final sub = data['subscription'];
    if (sub is Map) return parsePremiumStatus(sub);
    if (data.containsKey('subscription') && sub == null) return false;
    return null;
  }

  void _log(String msg) {
    if (debugLogs) debugPrint('[Ads] $msg');
  }
}
