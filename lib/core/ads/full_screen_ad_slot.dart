import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';
import 'ad_pacing.dart';

/// A loaded app-open, interstitial or rewarded ad behind one interface.
class LoadedFullScreenAd {
  final AdUnit unit;
  final DateTime loadedAt;
  final Ad _ad;
  final void Function({
    required VoidCallback onShown,
    required VoidCallback onClosed,
    required VoidCallback onFailed,
  }) _attach;
  final void Function(VoidCallback? onReward) _show;

  LoadedFullScreenAd._(this.unit, this._ad, this._attach, this._show)
      : loadedAt = DateTime.now();

  factory LoadedFullScreenAd.interstitial(AdUnit unit, InterstitialAd ad) =>
      LoadedFullScreenAd._(unit, ad, ({required onShown, required onClosed, required onFailed}) {
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (_) => onShown(),
          onAdDismissedFullScreenContent: (a) { a.dispose(); onClosed(); },
          onAdFailedToShowFullScreenContent: (a, _) { a.dispose(); onFailed(); },
        );
      }, (_) => ad.show());

  factory LoadedFullScreenAd.adManagerInterstitial(
          AdUnit unit, AdManagerInterstitialAd ad) =>
      LoadedFullScreenAd._(unit, ad, ({required onShown, required onClosed, required onFailed}) {
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (_) => onShown(),
          onAdDismissedFullScreenContent: (a) { a.dispose(); onClosed(); },
          onAdFailedToShowFullScreenContent: (a, _) { a.dispose(); onFailed(); },
        );
      }, (_) => ad.show());

  factory LoadedFullScreenAd.appOpen(AdUnit unit, AppOpenAd ad) =>
      LoadedFullScreenAd._(unit, ad, ({required onShown, required onClosed, required onFailed}) {
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (_) => onShown(),
          onAdDismissedFullScreenContent: (a) { a.dispose(); onClosed(); },
          onAdFailedToShowFullScreenContent: (a, _) { a.dispose(); onFailed(); },
        );
      }, (_) => ad.show());

  factory LoadedFullScreenAd.rewarded(AdUnit unit, RewardedAd ad) =>
      LoadedFullScreenAd._(unit, ad, ({required onShown, required onClosed, required onFailed}) {
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (_) => onShown(),
          onAdDismissedFullScreenContent: (a) { a.dispose(); onClosed(); },
          onAdFailedToShowFullScreenContent: (a, _) { a.dispose(); onFailed(); },
        );
      }, (onReward) => ad.show(onUserEarnedReward: (_, _) => onReward?.call()));

  bool isExpired(Duration maxAge) => DateTime.now().difference(loadedAt) > maxAge;

  /// Shows the ad; completes with true when the user closes it, false if it
  /// could not be shown.
  Future<bool> present({VoidCallback? onShown, VoidCallback? onReward}) {
    final result = Completer<bool>();
    _attach(
      onShown: () => onShown?.call(),
      onClosed: () { if (!result.isCompleted) result.complete(true); },
      onFailed: () { if (!result.isCompleted) result.complete(false); },
    );
    try {
      _show(onReward);
    } catch (_) {
      _ad.dispose();
      if (!result.isCompleted) result.complete(false);
    }
    return result.future;
  }

  void dispose() => _ad.dispose();
}

typedef FullScreenLoader = void Function(
  AdUnit unit,
  void Function(LoadedFullScreenAd ad) onLoaded,
  void Function(LoadAdError error) onFailed,
);

/// Keeps one full-screen ad loaded: walks the unit list on failure
/// (primary → fallbacks), then retries with backoff + jitter, and drops
/// ads that are older than [maxAge] so a stale ad is never shown.
class FullScreenAdSlot {
  final String name;
  final Duration maxAge;
  final List<AdUnit> Function() units;
  final bool Function() canLoad;
  final FullScreenLoader loader;

  FullScreenAdSlot({
    required this.name,
    required this.maxAge,
    required this.units,
    required this.canLoad,
    required this.loader,
  });

  LoadedFullScreenAd? _ad;
  bool _loading = false;
  Timer? _retryTimer;
  final RetryBackoff _backoff = RetryBackoff();
  final List<Completer<bool>> _waiters = [];

  bool get isLoading => _loading;

  bool get isReady {
    final ad = _ad;
    if (ad == null) return false;
    if (ad.isExpired(maxAge)) {
      _log('cached ad expired, reloading');
      ad.dispose();
      _ad = null;
      return false;
    }
    return true;
  }

  /// Starts a load unless one is ready or in flight.
  void load() {
    if (isReady || _loading) return;
    if (!canLoad()) return;
    final list = units();
    if (list.isEmpty) {
      _log('no ad unit ids configured');
      return;
    }
    _retryTimer?.cancel();
    _loading = true;
    _tryUnit(list, 0);
  }

  void _tryUnit(List<AdUnit> list, int index) {
    if (index >= list.length) {
      _loading = false;
      _completeWaiters(false);
      final delay = _backoff.next();
      if (delay == null) {
        _log('all units failed, giving up until next trigger');
        _backoff.reset();
        return;
      }
      _log('all units failed, retry #${_backoff.attempt} in ${delay.inSeconds}s');
      _retryTimer = Timer(delay, load);
      return;
    }
    final unit = list[index];
    _log('loading $unit');
    try {
      loader(unit, (ad) {
        _loading = false;
        _backoff.reset();
        _ad = ad;
        _log('loaded $unit');
        _completeWaiters(true);
      }, (error) {
        _log('failed $unit: ${error.code} ${error.message}');
        _tryUnit(list, index + 1);
      });
    } catch (e) {
      _log('loader threw for $unit: $e');
      _tryUnit(list, index + 1);
    }
  }

  /// Waits up to [timeout] for an ad, starting a load if needed.
  Future<bool> waitUntilReady(Duration timeout) {
    if (isReady) return Future.value(true);
    load();
    if (!_loading) return Future.value(false);
    final c = Completer<bool>();
    _waiters.add(c);
    return c.future.timeout(timeout, onTimeout: () {
      _waiters.remove(c);
      return false;
    });
  }

  /// Hands the ready ad to the caller; the slot is empty afterwards.
  LoadedFullScreenAd? take() {
    if (!isReady) return null;
    final ad = _ad;
    _ad = null;
    return ad;
  }

  void _completeWaiters(bool value) {
    for (final w in List.of(_waiters)) {
      if (!w.isCompleted) w.complete(value);
    }
    _waiters.clear();
  }

  void clear() {
    _retryTimer?.cancel();
    _ad?.dispose();
    _ad = null;
    _completeWaiters(false);
  }

  void _log(String msg) {
    if (kDebugMode) debugPrint('[Ads][$name] $msg');
  }
}
