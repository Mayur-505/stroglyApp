import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ad_config.dart';
import '../ad_pacing.dart';
import '../ads_manager.dart';
import '../native_ad_pool.dart';

/// A banner or native ad slot for one screen, controlled entirely by
/// Remote Config: `<screen>_type` (0 off · 1 native · 2 banner) and
/// `<screen>_size` (0 off · 1 small · 2 medium · 3 big).
///
/// The slot reserves its final height while loading so content does not
/// jump, collapses to nothing if ads are off or every attempt fails, and
/// only loads while visible (hidden tabs in an IndexedStack wait).
class AdPlacement extends StatefulWidget {
  /// Remote Config prefix, e.g. `home` → `home_type` / `home_size`.
  final String screen;
  final EdgeInsetsGeometry padding;

  /// Adds the system gesture-bar inset below the ad, only while it shows.
  final bool bottomInset;

  const AdPlacement({
    super.key,
    required this.screen,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    this.bottomInset = false,
  });

  @override
  State<AdPlacement> createState() => _AdPlacementState();
}

enum _SlotState { idle, loading, loaded, failed }

class _AdPlacementState extends State<AdPlacement> {
  final AdsManager _ads = AdsManager.instance;

  PlacementType _type = PlacementType.off;
  PlacementSize _size = PlacementSize.off;
  _SlotState _state = _SlotState.idle;
  Ad? _ad;
  AdSize? _bannerSize;
  double? _availableWidth;
  bool _visible = true;
  Timer? _retryTimer;
  final RetryBackoff _backoff = RetryBackoff(maxAttempts: 2);

  @override
  void initState() {
    super.initState();
    _ads.placementsEnabled.addListener(_onAvailability);
  }

  @override
  void dispose() {
    _ads.placementsEnabled.removeListener(_onAvailability);
    _retryTimer?.cancel();
    _ad?.dispose();
    super.dispose();
  }

  void _onAvailability() {
    if (!mounted) return;
    if (!_ads.placementsEnabled.value) {
      _retryTimer?.cancel();
      _ad?.dispose();
      _ad = null;
      setState(() => _state = _SlotState.idle);
    } else {
      setState(() {});
    }
  }

  void _maybeLoad() {
    if (_state != _SlotState.idle) return;
    if (!_ads.placementsEnabled.value || !_ads.canRequestAds) return;
    if (!_visible) return;
    if (_availableWidth == null) return;

    final cfg = _ads.config;
    _type = cfg.placementType(widget.screen);
    _size = cfg.placementSize(widget.screen);
    if (_type == PlacementType.off || _size == PlacementSize.off) return;
    if (_type == PlacementType.native && !cfg.nativeEnabled) return;
    if (_type == PlacementType.banner && !cfg.bannerEnabled) return;

    _state = _SlotState.loading;
    if (_type == PlacementType.native) {
      _loadNative();
    } else {
      _loadBanner();
    }
  }

  // ---------------------------------------------------------------- native

  void _loadNative() {
    final template = NativeAdPool.templateFor(_size);
    final pooled = _ads.nativePool.take(template);
    if (pooled != null) {
      _onLoaded(pooled);
      return;
    }
    _ads.nativePool.loadNative(
      template: template,
      onLoaded: (ad) {
        if (!mounted) {
          ad.dispose();
          return;
        }
        _onLoaded(ad);
      },
      onFailed: _onFailed,
    );
  }

  // ---------------------------------------------------------------- banner

  Future<void> _loadBanner() async {
    final size = await _resolveBannerSize();
    if (!mounted) return;
    setState(() => _bannerSize = size);
    final units = _ads.unitsFor(AdFormat.banner);

    void attempt(int i) {
      if (!mounted) return;
      if (i >= units.length) {
        _onFailed();
        return;
      }
      final unit = units[i];
      final listener = BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          _onLoaded(ad);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          attempt(i + 1);
        },
      );
      final Ad ad = unit.isAdManager
          ? AdManagerBannerAd(
              adUnitId: unit.id,
              sizes: [size],
              request: const AdManagerAdRequest(),
              listener: AdManagerBannerAdListener(
                onAdLoaded: listener.onAdLoaded,
                onAdFailedToLoad: listener.onAdFailedToLoad,
              ),
            )
          : BannerAd(
              adUnitId: unit.id,
              size: size,
              request: const AdRequest(),
              listener: listener,
            );
      (ad as AdWithView).load().catchError((_) => attempt(i + 1));
    }

    attempt(0);
  }

  Future<AdSize> _resolveBannerSize() async {
    switch (_size) {
      case PlacementSize.medium:
        return AdSize.largeBanner;
      case PlacementSize.big:
        return AdSize.mediumRectangle;
      default:
        final width = _availableWidth!.truncate();
        try {
          final adaptive = await AdSize
              .getLargeAnchoredAdaptiveBannerAdSize(width);
          if (adaptive != null) return adaptive;
        } catch (_) {}
        return AdSize.banner;
    }
  }

  // ---------------------------------------------------------------- result

  void _onLoaded(Ad ad) {
    _backoff.reset();
    setState(() {
      _ad = ad;
      _state = _SlotState.loaded;
    });
  }

  void _onFailed() {
    if (!mounted) return;
    final delay = _backoff.next();
    if (delay == null) {
      setState(() => _state = _SlotState.failed);
      return;
    }
    _retryTimer = Timer(delay, () {
      if (!mounted) return;
      _state = _SlotState.idle;
      _maybeLoad();
    });
  }

  double get _reservedHeight {
    if (_type == PlacementType.native) {
      return switch (_size) {
        PlacementSize.small => 110,
        PlacementSize.medium => 340,
        PlacementSize.big => 380,
        PlacementSize.off => 0,
      };
    }
    final banner = _bannerSize;
    if (banner != null) return banner.height.toDouble();
    return switch (_size) {
      PlacementSize.medium => 100,
      PlacementSize.big => 250,
      _ => 60,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Hidden IndexedStack tabs run with tickers disabled — wait until shown.
    _visible = TickerMode.valuesOf(context).enabled;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedWidth) {
          final padding = widget.padding.resolve(Directionality.of(context));
          _availableWidth = constraints.maxWidth - padding.horizontal;
        }
        if (_state == _SlotState.idle) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _maybeLoad();
          });
        }

        final showSlot =
            _state == _SlotState.loading || _state == _SlotState.loaded;
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: showSlot ? _buildSlot() : const SizedBox(width: double.infinity),
        );
      },
    );
  }

  Widget _buildSlot() {
    final ad = _ad;
    final Widget child;
    if (ad is NativeAd) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AdWidget(ad: ad),
      );
    } else if (ad is AdWithView && _bannerSize != null) {
      child = Center(
        child: SizedBox(
          width: _bannerSize!.width.toDouble(),
          height: _bannerSize!.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      );
    } else {
      child = Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(_type == PlacementType.native ? 16 : 6),
        ),
        alignment: Alignment.center,
        child: Text(
          'Ad',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.25),
            fontSize: 11,
          ),
        ),
      );
    }
    return Padding(
      padding: widget.padding.add(EdgeInsets.only(
        bottom: widget.bottomInset ? MediaQuery.viewPaddingOf(context).bottom : 0,
      )),
      child: SizedBox(
        width: double.infinity,
        height: _reservedHeight,
        child: child,
      ),
    );
  }
}

/// [AdPlacement] pinned to the bottom of a screen (use as a Scaffold's
/// `bottomNavigationBar`). Adds the system gesture-bar inset and takes no
/// space at all when the placement is off.
class BottomAdPlacement extends StatelessWidget {
  final String screen;

  const BottomAdPlacement({super.key, required this.screen});

  @override
  Widget build(BuildContext context) {
    return AdPlacement(
      screen: screen,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      bottomInset: true,
    );
  }
}
