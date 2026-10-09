import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';
import 'ad_pacing.dart';
import 'ads_manager.dart';
import 'full_screen_ad_slot.dart';
import 'widgets/ad_loading_dialog.dart';

class InterstitialAdManager {
  final AdsManager _ads;
  final InterstitialPacer pacer = InterstitialPacer();
  late final FullScreenAdSlot _slot;

  InterstitialAdManager(this._ads) {
    _slot = FullScreenAdSlot(
      name: 'Interstitial',
      maxAge: const Duration(minutes: 55),
      units: () => _ads.unitsFor(AdFormat.interstitial),
      canLoad: () => _ads.canRequestAds && _ads.config.interEnabled,
      loader: _load,
    );
  }

  bool get isReady => _slot.isReady;

  void _load(AdUnit unit, void Function(LoadedFullScreenAd) ok,
      void Function(LoadAdError) fail) {
    if (unit.isAdManager) {
      AdManagerInterstitialAd.load(
        adUnitId: unit.id,
        request: const AdManagerAdRequest(),
        adLoadCallback: AdManagerInterstitialAdLoadCallback(
          onAdLoaded: (ad) => ok(LoadedFullScreenAd.adManagerInterstitial(unit, ad)),
          onAdFailedToLoad: fail,
        ),
      );
    } else {
      InterstitialAd.load(
        adUnitId: unit.id,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) => ok(LoadedFullScreenAd.interstitial(unit, ad)),
          onAdFailedToLoad: fail,
        ),
      );
    }
  }

  /// Preloads when `Inter_Ads_Status` = 1.
  void preload() {
    if (_ads.config.interPreload) _slot.load();
  }

  /// Called by the navigator observer on page pushes/pops.
  void onNavigation(NavDirection direction) {
    final cfg = _ads.config;
    if (!cfg.interEnabled || !_ads.canShowFullScreen) return;
    final forward = direction == NavDirection.forward;
    final shouldShow = pacer.registerClick(
      direction: direction,
      enabled: forward ? cfg.forwardClicksEnabled : cfg.backwardClicksEnabled,
      gap: forward ? cfg.forwardClickGap : cfg.backwardClickGap,
      cooldown: forward ? cfg.forwardCooldown : cfg.backwardCooldown,
      now: DateTime.now(),
    );
    if (shouldShow) {
      _log('${direction.name} click gap reached');
      show();
    }
  }

  /// Shows after a workout day is completed (`inter_workout_complete`).
  /// Skips the click gap but still respects the forward cooldown.
  Future<void> showForWorkoutComplete() async {
    final cfg = _ads.config;
    if (!cfg.interEnabled || !cfg.interOnWorkoutComplete) return;
    if (!pacer.cooldownPassed(cfg.forwardCooldown, DateTime.now())) {
      _log('workout complete: cooldown active, skipped');
      return;
    }
    await show();
  }

  /// Shows an interstitial if allowed. With `Inter_Ads_Status` = 2 (or no
  /// ad cached yet) it loads on demand behind a short "Loading ad" dialog,
  /// giving up after a few seconds so the user is never stuck.
  Future<bool> show({bool waitForLoad = false}) async {
    if (!_ads.canShowFullScreen) return false;
    final cfg = _ads.config;

    if (!_slot.isReady) {
      final loadOnDemand = cfg.interStatus == 2 || waitForLoad;
      if (!loadOnDemand) {
        _slot.load();
        _log('not ready, skipped this time');
        return false;
      }
      final ready = await AdLoadingDialog.runWhile(
        _ads.navigatorKey,
        _slot.waitUntilReady(const Duration(seconds: 5)),
        show: cfg.interDialog,
      );
      if (!ready || !_ads.canShowFullScreen) return false;
    } else if (cfg.interDialog) {
      await AdLoadingDialog.runWhile(
        _ads.navigatorKey,
        Future.delayed(const Duration(milliseconds: 600), () => true),
      );
      if (!_ads.canShowFullScreen) return false;
    }

    final ad = _slot.take();
    if (ad == null) return false;
    final shown = await _ads.presentFullScreen(ad);
    pacer.markShown(DateTime.now());
    preload();
    return shown;
  }

  void clear() => _slot.clear();

  void _log(String msg) {
    if (kDebugMode) debugPrint('[Ads][Interstitial] $msg');
  }
}
