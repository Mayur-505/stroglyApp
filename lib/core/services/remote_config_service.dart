import 'dart:async';
import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Loads the ads/app config from Firebase Remote Config at app start.
///
/// Defaults come from `firebase/remote_config_template.json` (the same file
/// deployed to Firebase), so the app behaves the same when offline or when
/// Firebase fails to start.
class RemoteConfigService {
  static final RemoteConfigService instance = RemoteConfigService._internal();
  factory RemoteConfigService() => instance;
  RemoteConfigService._internal();

  static const String _templateAsset = 'firebase/remote_config_template.json';

  FirebaseRemoteConfig? _remoteConfig;
  final Map<String, String> _defaults = {};

  /// Bundled defaults. Safe to call before (or without) Firebase.
  Future<void> loadDefaults() async {
    if (_defaults.isNotEmpty) return;
    try {
      final template =
          jsonDecode(await rootBundle.loadString(_templateAsset)) as Map;
      final groups = (template['parameterGroups'] as Map?) ?? {};
      for (final group in groups.values) {
        final params = ((group as Map)['parameters'] as Map?) ?? {};
        params.forEach((key, param) {
          _defaults[key as String] =
              (param['defaultValue']?['value'] ?? '').toString();
        });
      }
    } catch (e) {
      debugPrint('RemoteConfig: could not load bundled defaults ($e)');
    }
  }

  /// Activates the last fetched values right away, then fetches fresh ones.
  /// Waits at most [maxWait] so a slow network never delays startup.
  Future<void> init({Duration maxWait = const Duration(seconds: 3)}) async {
    try {
      await loadDefaults();
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 15),
          minimumFetchInterval:
              kDebugMode ? Duration.zero : const Duration(hours: 1),
        ),
      );
      await remoteConfig.setDefaults(_defaults);
      await remoteConfig.activate();
      _remoteConfig = remoteConfig;
      await remoteConfig.fetchAndActivate().timeout(maxWait);
      debugPrint('RemoteConfig: fetched ${remoteConfig.getAll().length} keys');
    } on TimeoutException {
      debugPrint('RemoteConfig: slow network, using cached values for now');
    } catch (e) {
      debugPrint('RemoteConfig: using defaults ($e)');
    }
  }

  String getString(String key) {
    final rc = _remoteConfig;
    if (rc != null) {
      final value = rc.getValue(key);
      if (value.source != ValueSource.valueStatic) return value.asString();
    }
    return _defaults[key] ?? '';
  }

  int getInt(String key) => int.tryParse(getString(key)) ?? 0;

  bool getFlag(String key) => getInt(key) == 1;

  Map<String, dynamic> getJson(String key) {
    try {
      final decoded = jsonDecode(getString(key));
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }
}
