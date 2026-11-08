import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';
import 'ad_pacing.dart';
import 'ads_manager.dart';

/// Loads native ads with Google's built-in templates (no platform code)
/// and keeps one preloaded ad per template so screens fill instantly.
class NativeAdPool {
  final AdsManager _ads;
  final Map<TemplateType, _PooledNative> _ready = {};
  final Set<TemplateType> _loading = {};
  final Map<TemplateType, RetryBackoff> _backoff = {};
  final Map<TemplateType, Timer> _retry = {};

  static const _maxAge = Duration(minutes: 55);

  NativeAdPool(this._ads);

  static TemplateType templateFor(PlacementSize size) =>
      size == PlacementSize.small ? TemplateType.small : TemplateType.medium;

  /// Preloads the default native size (`native_type`) when
  /// `Native_Ads_Status` = 1.
  void preload() {
    final cfg = _ads.config;
    if (!cfg.nativeEnabled || !cfg.nativePreload) return;
    _fill(templateFor(cfg.defaultNativeSize));
  }

  /// Returns a ready ad for [template] if one is cached, and starts loading
  /// the next one so the pool stays warm.
  NativeAd? take(TemplateType template) {
    final pooled = _ready.remove(template);
    if (_ads.config.nativePreload) _fill(template);
    if (pooled == null) return null;
    if (DateTime.now().difference(pooled.loadedAt) > _maxAge) {
      pooled.ad.dispose();
      return null;
    }
    return pooled.ad;
  }

  void _fill(TemplateType template) {
    if (_ready.containsKey(template) || _loading.contains(template)) return;
    if (!_ads.canRequestAds || !_ads.config.nativeEnabled) return;
    _loading.add(template);
    loadNative(
      template: template,
      onLoaded: (ad) {
        _loading.remove(template);
        _backoff[template]?.reset();
        _ready[template] = _PooledNative(ad);
      },
      onFailed: () {
        _loading.remove(template);
        final backoff = _backoff.putIfAbsent(
            template, () => RetryBackoff(maxAttempts: 4));
        final delay = backoff.next();
        if (delay != null) {
          _retry[template]?.cancel();
          _retry[template] = Timer(delay, () => _fill(template));
        } else {
          backoff.reset();
        }
      },
    );
  }

  /// Loads one native ad, walking primary → fallback ids.
  void loadNative({
    required TemplateType template,
    required void Function(NativeAd ad) onLoaded,
    required VoidCallback onFailed,
  }) {
    final units = _ads.unitsFor(AdFormat.native);
    void attempt(int i) {
      if (i >= units.length) {
        onFailed();
        return;
      }
      final unit = units[i];
      final listener = NativeAdListener(
        onAdLoaded: (ad) {
          _log('loaded $unit (${template.name})');
          onLoaded(ad as NativeAd);
        },
        onAdFailedToLoad: (ad, error) {
          _log('failed $unit: ${error.code} ${error.message}');
          ad.dispose();
          attempt(i + 1);
        },
      );
      final style = _style(template);
      final ad = unit.isAdManager
          ? NativeAd.fromAdManagerRequest(
              adUnitId: unit.id,
              listener: listener,
              adManagerRequest: const AdManagerAdRequest(),
              nativeTemplateStyle: style,
            )
          : NativeAd(
              adUnitId: unit.id,
              listener: listener,
              request: const AdRequest(),
              nativeTemplateStyle: style,
            );
      ad.load().catchError((_) => attempt(i + 1));
    }

    attempt(0);
  }

  NativeTemplateStyle _style(TemplateType template) {
    final cfg = _ads.config;
    final bg = parseHexColor(cfg.nativeBgColor, const Color(0xFF1A1A1A));
    final button = parseHexColor(cfg.nativeButtonColor, const Color(0xFFA3D223));
    final text = parseHexColor(cfg.nativeTextColor, Colors.white);
    final buttonText = parseHexColor(cfg.nativeButtonTextColor, Colors.black);
    return NativeTemplateStyle(
      templateType: template,
      mainBackgroundColor: bg,
      cornerRadius: 16,
      callToActionTextStyle: NativeTemplateTextStyle(
        textColor: buttonText,
        backgroundColor: button,
        style: NativeTemplateFontStyle.bold,
        size: 15,
      ),
      primaryTextStyle: NativeTemplateTextStyle(
        textColor: text,
        backgroundColor: bg,
        style: NativeTemplateFontStyle.bold,
        size: 15,
      ),
      secondaryTextStyle: NativeTemplateTextStyle(
        textColor: text.withValues(alpha: 0.7),
        backgroundColor: bg,
        size: 13,
      ),
      tertiaryTextStyle: NativeTemplateTextStyle(
        textColor: text.withValues(alpha: 0.6),
        backgroundColor: bg,
        size: 12,
      ),
    );
  }

  void clear() {
    for (final t in _retry.values) {
      t.cancel();
    }
    _retry.clear();
    for (final p in _ready.values) {
      p.ad.dispose();
    }
    _ready.clear();
  }

  void _log(String msg) {
    if (_ads.debugLogs) debugPrint('[Ads][Native] $msg');
  }
}

class _PooledNative {
  final NativeAd ad;
  final DateTime loadedAt = DateTime.now();
  _PooledNative(this.ad);
}

/// `#RRGGBB` or `#AARRGGBB` → [Color]; [fallback] on anything else.
Color parseHexColor(String hex, Color fallback) {
  var h = hex.trim().replaceFirst('#', '');
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return fallback;
  final v = int.tryParse(h, radix: 16);
  return v == null ? fallback : Color(v);
}
