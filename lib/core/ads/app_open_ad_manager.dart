import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ad_config.dart';
import 'ad_pacing.dart';
import 'ads_manager.dart';
import 'full_screen_ad_slot.dart';

class AppOpenAdManager {
  final AdsManager _ads;
  late final FullScreenAdSlot _slot;
  StreamSubscription<AppState>? _stateSub;

  static const _kDay = 'ads_appopen_day';
  static const _kCount = 'ads_appopen_count';
  static const _kLast = 'ads_appopen_last';

  /// Resume ads only start after the splash flow has finished.
  bool _splashDone = false;
  DateTime? _backgroundedAt;

  AppOpenAdManager(this._ads) {
    _slot = FullScreenAdSlot(
      name: 'AppOpen',
      // Google: app-open ads expire after 4 hours.
      maxAge: const Duration(hours: 3, minutes: 50),
      units: () => _ads.unitsFor(AdFormat.appOpen),
      canLoad: () => _ads.canRequestAds && _ads.config.appOpenNeeded,
      loader: _load,
    );
  }

  void _load(AdUnit unit, void Function(LoadedFullScreenAd) ok,
      void Function(LoadAdError) fail) {
    final callback = AppOpenAdLoadCallback(
      onAdLoaded: (ad) => ok(LoadedFullScreenAd.appOpen(unit, ad)),
      onAdFailedToLoad: fail,
    );
    if (unit.isAdManager) {
      AppOpenAd.loadWithAdManagerAdRequest(
        adUnitId: unit.id,
        adManagerAdRequest: const AdManagerAdRequest(),
        adLoadCallback: callback,
      );
    } else {
      AppOpenAd.load(
        adUnitId: unit.id,
        request: const AdRequest(),
        adLoadCallback: callback,
      );
    }
  }

  void preload() => _slot.load();

  void startListening() {
    if (_stateSub != null) return;
    AppStateEventNotifier.startListening();
    _stateSub = AppStateEventNotifier.appStateStream.listen((state) {
      if (state == AppState.background) {
        _backgroundedAt = DateTime.now();
      } else if (state == AppState.foreground) {
        _onResume();
      }
    });
  }

  Future<void> _onResume() async {
    final cfg = _ads.config;
    if (!_splashDone || !cfg.appOpenOnResume) return;
    // Very short trips away (permission dialogs, ad click-throughs, share
    // sheets) should not trigger an ad when the user comes back.
    final away = _backgroundedAt == null
        ? Duration.zero
        : DateTime.now().difference(_backgroundedAt!);
    if (away < const Duration(seconds: 3)) return;
    if (_ads.recentlyClosedFullScreen(const Duration(seconds: 10))) return;
    if (!_ads.canShowFullScreen) return;
    if (!await _capAllows(cfg.appOpenDailyCap)) return;
    if (!_slot.isReady) {
      preload();
      return;
    }
    await _present();
  }

  /// Splash ad. Waits up to [maxWait] for an ad, shows it and completes
  /// when it is closed — or right away if there is nothing to show.
  Future<void> showOnSplash({Duration maxWait = const Duration(seconds: 4)}) async {
    try {
      if (!_ads.isSupported || _ads.isPremium) return;
      final deadline = DateTime.now().add(maxWait);
      Duration remaining() {
        final left = deadline.difference(DateTime.now());
        return left.isNegative ? Duration.zero : left;
      }

      await _ads.ready.timeout(maxWait, onTimeout: () {});
      final cfg = _ads.config;
      if (!_ads.canShowFullScreen) return;
      if (cfg.appOpenSplashMode == 2) {
        await _ads.interstitial.show(waitForLoad: true);
        return;
      }
      if (cfg.appOpenSplashMode != 1) return;
      if (!await _capAllows(cfg.appOpenDailyCap)) return;
      if (!await _slot.waitUntilReady(remaining())) return;
      if (!_ads.canShowFullScreen) return;
      await _present();
    } finally {
      _splashDone = true;
      preload();
    }
  }

  Future<void> _present() async {
    final ad = _slot.take();
    if (ad == null) return;
    final shown = await _ads.presentFullScreen(ad);
    if (shown) await _recordShown();
    preload();
  }

  Future<bool> _capAllows(int cap) async {
    if (cap <= 0) return true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = AppOpenDailyCap.dayKey(DateTime.now());
      final count = prefs.getString(_kDay) == today ? prefs.getInt(_kCount) ?? 0 : 0;
      final lastMs = prefs.getInt(_kLast);
      final allowed = AppOpenDailyCap.canShow(
        cap: cap,
        shownToday: count,
        lastShown: lastMs == null ? null : DateTime.fromMillisecondsSinceEpoch(lastMs),
        now: DateTime.now(),
      );
      if (!allowed && kDebugMode) debugPrint('[Ads][AppOpen] daily cap reached');
      return allowed;
    } catch (_) {
      return true;
    }
  }

  Future<void> _recordShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = AppOpenDailyCap.dayKey(DateTime.now());
      final count = prefs.getString(_kDay) == today ? prefs.getInt(_kCount) ?? 0 : 0;
      await prefs.setString(_kDay, today);
      await prefs.setInt(_kCount, count + 1);
      await prefs.setInt(_kLast, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  void clear() => _slot.clear();
}
