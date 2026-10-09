import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';
import 'ads_manager.dart';
import 'full_screen_ad_slot.dart';
import 'widgets/ad_loading_dialog.dart';

/// Result of asking the user to watch a rewarded ad.
enum RewardOutcome {
  /// The user watched the ad and earned the reward.
  earned,

  /// The user closed the ad before earning the reward.
  skipped,

  /// No ad could be shown (ads off, premium, offline, no fill). Callers
  /// should grant the reward so the user is never blocked by a missing ad.
  unavailable,
}

class RewardedAdManager {
  final AdsManager _ads;
  late final FullScreenAdSlot _slot;

  RewardedAdManager(this._ads) {
    _slot = FullScreenAdSlot(
      name: 'Rewarded',
      maxAge: const Duration(minutes: 55),
      units: () => _ads.unitsFor(AdFormat.rewarded),
      canLoad: () => _ads.canRequestAds && _ads.config.rewardEnabled,
      loader: _load,
    );
  }

  bool get isReady => _slot.isReady;

  void _load(AdUnit unit, void Function(LoadedFullScreenAd) ok,
      void Function(LoadAdError) fail) {
    final callback = RewardedAdLoadCallback(
      onAdLoaded: (ad) => ok(LoadedFullScreenAd.rewarded(unit, ad)),
      onAdFailedToLoad: fail,
    );
    if (unit.isAdManager) {
      RewardedAd.loadWithAdManagerAdRequest(
        adUnitId: unit.id,
        adManagerRequest: const AdManagerAdRequest(),
        rewardedAdLoadCallback: callback,
      );
    } else {
      RewardedAd.load(
        adUnitId: unit.id,
        request: const AdRequest(),
        rewardedAdLoadCallback: callback,
      );
    }
  }

  /// Keeps one rewarded ad ready so "Watch video" starts instantly.
  void preload() => _slot.load();

  /// Shows a rewarded ad, waiting up to [timeout] behind a loading dialog
  /// if none is cached yet.
  Future<RewardOutcome> show({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (!_ads.canRequestAds || !_ads.config.rewardEnabled) {
      return RewardOutcome.unavailable;
    }
    if (!_slot.isReady) {
      final ready = await AdLoadingDialog.runWhile(
        _ads.navigatorKey,
        _slot.waitUntilReady(timeout),
      );
      if (!ready) {
        _log('no ad in ${timeout.inSeconds}s');
        return RewardOutcome.unavailable;
      }
    }
    final ad = _slot.take();
    if (ad == null) return RewardOutcome.unavailable;

    var earned = false;
    final shown = await _ads.presentFullScreen(
      ad,
      onReward: () => earned = true,
      bypassQuietZone: true,
    );
    preload();
    if (!shown) return RewardOutcome.unavailable;
    return earned ? RewardOutcome.earned : RewardOutcome.skipped;
  }

  void clear() => _slot.clear();

  void _log(String msg) {
    if (kDebugMode) debugPrint('[Ads][Rewarded] $msg');
  }
}
