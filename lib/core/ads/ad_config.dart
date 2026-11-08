import 'dart:convert';

/// Ad formats managed by the ads module.
enum AdFormat { appOpen, interstitial, rewarded, banner, native }

/// What a screen placement renders: 0 off · 1 native · 2 banner.
enum PlacementType { off, native, banner }

/// Placement size: 0 off · 1 small · 2 medium · 3 big.
enum PlacementSize { off, small, medium, big }

/// One ad unit to try. [isAdManager] is true for AdX / Ad Manager units
/// (they start with `/`), which need an `AdManagerAdRequest`.
class AdUnit {
  final String id;
  final bool isAdManager;

  const AdUnit(this.id, {this.isAdManager = false});

  factory AdUnit.parse(String id) =>
      AdUnit(id.trim(), isAdManager: id.trim().startsWith('/'));

  @override
  bool operator ==(Object other) =>
      other is AdUnit && other.id == id && other.isAdManager == isAdManager;

  @override
  int get hashCode => Object.hash(id, isAdManager);

  @override
  String toString() => id;
}

/// A typed, immutable snapshot of the ad keys in Remote Config.
///
/// Built from a key lookup so it can be unit tested without Firebase.
/// Every getter has a safe default, so a missing or malformed key never
/// throws — it just turns that feature off or falls back.
class AdConfig {
  final String Function(String key) _lookup;

  AdConfig(this._lookup);

  factory AdConfig.fromMap(Map<String, String> values) =>
      AdConfig((key) => values[key] ?? '');

  String _str(String key) => _lookup(key).trim();

  int _int(String key, [int fallback = 0]) =>
      int.tryParse(_str(key)) ?? double.tryParse(_str(key))?.toInt() ?? fallback;

  Map<String, dynamic> _json(String key) {
    try {
      final decoded = jsonDecode(_str(key));
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }

  // ---------------------------------------------------------------- general

  bool get adsEnabled => _int('Ads_status') == 1;
  bool get iosAdsEnabled => _int('ios_ads_status') == 1;

  List<String> get testDeviceIds => _str('test_device_ids')
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  /// G · PG · T · MA. Empty means no cap.
  String get maxAdContentRating => _str('max_ad_content_rating').toUpperCase();

  bool get childDirected => _int('child_directed') == 1;

  // ----------------------------------------------------------- interstitial

  /// 0 off · 1 on+preload · 2 on+load when shown.
  int get interStatus => _int('Inter_Ads_Status');

  /// 0 off · 1 network · 2 custom · 3/4 network + custom.
  /// Custom (house) ads are not implemented, so only the network part runs.
  int get interMode => _int('inter_mode');

  bool get interEnabled =>
      interStatus != 0 && (interMode == 1 || interMode == 3 || interMode == 4);

  bool get interPreload => interStatus == 1;

  /// 0 off · 1 forward · 2 back · 3 both.
  int get clickMode => _int('click_mode');
  bool get forwardClicksEnabled => clickMode == 1 || clickMode == 3;
  bool get backwardClicksEnabled => clickMode == 2 || clickMode == 3;

  int get forwardClickGap => _int('forward_click_gap', 2).clamp(0, 100);
  int get backwardClickGap => _int('backward_click_gap', 3).clamp(0, 100);

  Duration get forwardCooldown =>
      Duration(seconds: _int('forward_timer', 45).clamp(0, 3600));
  Duration get backwardCooldown =>
      Duration(seconds: _int('backward_timer', 30).clamp(0, 3600));

  bool get interDialog => _int('inter_dialog') == 1;
  bool get interOnWorkoutComplete => _int('inter_workout_complete') == 1;

  // --------------------------------------------------------------- app open

  /// Splash: 0 off · 1 app-open · 2 interstitial.
  int get appOpenSplashMode => _int('appopen_mode');
  bool get appOpenOnResume => _int('appopen_resume') == 1;

  /// Max app-open ads per day, spread evenly. 0 = no cap.
  int get appOpenDailyCap => _int('timer_app_open').clamp(0, 1000);

  bool get appOpenNeeded => appOpenSplashMode == 1 || appOpenOnResume;

  // --------------------------------------------------------------- rewarded

  bool get rewardEnabled => _int('reward_mode') == 1;

  // ----------------------------------------------------------------- native

  /// 0 off · 1 on+preload · 2 on+load when shown.
  int get nativeStatus => _int('Native_Ads_Status');
  int get nativeMode => _int('native_mode');
  bool get nativeEnabled =>
      nativeStatus != 0 &&
      (nativeMode == 1 || nativeMode == 3 || nativeMode == 4);
  bool get nativePreload => nativeStatus == 1;

  PlacementSize get defaultNativeSize =>
      _sizeFromName(_str('native_type'), PlacementSize.medium);

  String get nativeBgColor => _str('native_bg_color');
  String get nativeButtonColor => _str('native_button_color');
  String get nativeTextColor => _str('native_text_color');
  String get nativeButtonTextColor => _str('native_button_text_color');

  // ----------------------------------------------------------------- banner

  int get bannerStatus => _int('Banner_Ads_Status');
  int get bannerMode => _int('banner_mode');
  bool get bannerEnabled =>
      bannerStatus != 0 &&
      (bannerMode == 1 || bannerMode == 3 || bannerMode == 4);

  // -------------------------------------------------------------- unit ids

  /// Ordered, de-duplicated list of units to try for [format]:
  /// primary AdMob → primary AdX → format fallback id → `fail_array_list`.
  List<AdUnit> unitsFor(AdFormat format) {
    final ids = <String>[];
    switch (format) {
      case AdFormat.appOpen:
        final j = _json('app_open_id_array');
        ids..add('${j['app_open_admob_id'] ?? ''}')..add('${j['app_open_adx_id'] ?? ''}');
      case AdFormat.interstitial:
        final j = _json('inter_array');
        ids..add('${j['inter_admob_id'] ?? ''}')..add('${j['inter_adx_id'] ?? ''}');
      case AdFormat.rewarded:
        final j = _json('reward_array');
        ids..add('${j['reward_admob_id'] ?? ''}')..add('${j['reward_adx_id'] ?? ''}');
      case AdFormat.banner:
        final j = _json('banner_array');
        ids..add('${j['banner_admob_id'] ?? ''}')..add('${j['banner_adx_id'] ?? ''}');
      case AdFormat.native:
        final j = _json('native_array');
        ids..add('${j['native_admob_id'] ?? ''}')..add('${j['native_adx_id'] ?? ''}');
        if (_str('native_fallback') != 'off') ids.add(_str('native_fallback_id'));
    }
    ids.addAll(_failIds(format));

    final seen = <String>{};
    return [
      for (final id in ids.map((e) => e.trim()))
        if (id.isNotEmpty && seen.add(id)) AdUnit.parse(id),
    ];
  }

  List<String> _failIds(AdFormat format) {
    final key = switch (format) {
      AdFormat.appOpen => 'appopen',
      AdFormat.interstitial => 'inter',
      AdFormat.rewarded => 'reward',
      AdFormat.banner => 'banner',
      AdFormat.native => 'native',
    };
    final list = _json('fail_array_list')[key];
    if (list is! List) return const [];
    return [
      for (final entry in list)
        if (entry is Map)
          for (final v in entry.values) '$v',
    ];
  }

  // ------------------------------------------------------------- placements

  /// Reads `<screen>_type`, e.g. `home_type`.
  PlacementType placementType(String screen) =>
      switch (_int('${screen}_type')) {
        1 => PlacementType.native,
        2 => PlacementType.banner,
        _ => PlacementType.off,
      };

  /// Reads `<screen>_size`, e.g. `home_size`.
  PlacementSize placementSize(String screen) =>
      switch (_int('${screen}_size')) {
        1 => PlacementSize.small,
        2 => PlacementSize.medium,
        3 => PlacementSize.big,
        _ => PlacementSize.off,
      };

  static PlacementSize _sizeFromName(String name, PlacementSize fallback) =>
      switch (name.toLowerCase()) {
        'small' => PlacementSize.small,
        'medium' => PlacementSize.medium,
        'big' => PlacementSize.big,
        _ => fallback,
      };
}
