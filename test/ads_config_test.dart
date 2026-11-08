import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:strongly/core/ads/ad_config.dart';
import 'package:strongly/core/ads/ad_pacing.dart';
import 'package:strongly/core/ads/ads_manager.dart';
import 'package:strongly/core/ads/native_ad_pool.dart';
import 'package:flutter/material.dart';

/// Defaults exactly as shipped in firebase/remote_config_template.json.
Map<String, String> templateDefaults() {
  final json = jsonDecode(
    File('firebase/remote_config_template.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final out = <String, String>{};
  for (final group in (json['parameterGroups'] as Map).values) {
    (group['parameters'] as Map).forEach((k, v) {
      out[k as String] = '${v['defaultValue']['value']}';
    });
  }
  return out;
}

void main() {
  group('AdConfig from template defaults', () {
    final cfg = AdConfig.fromMap(templateDefaults());

    test('master switches', () {
      expect(cfg.adsEnabled, isTrue);
      expect(cfg.interEnabled, isTrue);
      expect(cfg.interPreload, isTrue);
      expect(cfg.rewardEnabled, isTrue);
      expect(cfg.nativeEnabled, isTrue);
      expect(cfg.bannerEnabled, isTrue);
      expect(cfg.iosAdsEnabled, isFalse);
      expect(cfg.maxAdContentRating, 'T');
    });

    test('unit ids: primary first, empty AdX skipped, no duplicates', () {
      final inter = cfg.unitsFor(AdFormat.interstitial);
      expect(inter.first.id, 'ca-app-pub-7817567654956813/7134312533');
      expect(inter.map((u) => u.id).toSet().length, inter.length);
      expect(inter.every((u) => u.id.isNotEmpty), isTrue);
      expect(cfg.unitsFor(AdFormat.banner).first.id,
          'ca-app-pub-7817567654956813/7979745487');
      expect(cfg.unitsFor(AdFormat.rewarded).first.id,
          'ca-app-pub-7817567654956813/5821230869');
      expect(cfg.unitsFor(AdFormat.appOpen).first.id,
          'ca-app-pub-7817567654956813/7270043904');
      expect(cfg.unitsFor(AdFormat.native).first.id,
          'ca-app-pub-7817567654956813/3195067528');
    });

    test('every screen placement has a type and size', () {
      for (final screen in [
        'language', 'onboarding', 'questionnaire', 'home', 'workouts',
        'category', 'search', 'plan', 'day_exercises', 'exercise_preview',
        'progress', 'profile',
      ]) {
        expect(cfg.placementType(screen), isNot(PlacementType.off), reason: screen);
        expect(cfg.placementSize(screen), isNot(PlacementSize.off), reason: screen);
      }
    });
  });

  group('AdConfig edge cases', () {
    test('missing / malformed values fall back safely', () {
      final cfg = AdConfig.fromMap({
        'inter_array': 'not json',
        'fail_array_list': '{"inter": "oops"}',
        'home_type': 'abc',
      });
      expect(cfg.adsEnabled, isFalse);
      expect(cfg.unitsFor(AdFormat.interstitial), isEmpty);
      expect(cfg.placementType('home'), PlacementType.off);
      expect(cfg.forwardClickGap, 2);
    });

    test('AdX ids are detected and fallbacks appended', () {
      final cfg = AdConfig.fromMap({
        'inter_array': '{"inter_admob_id": "a/1", "inter_adx_id": "/123/adx"}',
        'fail_array_list': '{"inter": [{"admob": "b/2"}, {"admob": "a/1"}]}',
      });
      final units = cfg.unitsFor(AdFormat.interstitial);
      expect(units.map((u) => u.id), ['a/1', '/123/adx', 'b/2']);
      expect(units[1].isAdManager, isTrue);
    });

    test('custom-only modes disable network ads', () {
      final cfg = AdConfig.fromMap({'Inter_Ads_Status': '1', 'inter_mode': '2'});
      expect(cfg.interEnabled, isFalse);
    });
  });

  group('InterstitialPacer', () {
    test('fires every gap+1 clicks and respects cooldown', () {
      final pacer = InterstitialPacer();
      final t0 = DateTime(2026, 1, 1);
      bool click(DateTime now) => pacer.registerClick(
            direction: NavDirection.forward,
            enabled: true,
            gap: 2,
            cooldown: const Duration(seconds: 45),
            now: now,
          );
      expect(click(t0), isFalse);
      expect(click(t0), isFalse);
      expect(click(t0), isTrue);
      pacer.markShown(t0);
      expect(click(t0), isFalse);
      expect(click(t0), isFalse);
      // Third click but still inside the cooldown.
      expect(click(t0.add(const Duration(seconds: 10))), isFalse);
      expect(click(t0.add(const Duration(seconds: 50))), isTrue);
    });

    test('disabled direction never fires', () {
      final pacer = InterstitialPacer();
      for (var i = 0; i < 10; i++) {
        expect(
          pacer.registerClick(
            direction: NavDirection.backward,
            enabled: false,
            gap: 0,
            cooldown: Duration.zero,
            now: DateTime(2026),
          ),
          isFalse,
        );
      }
    });
  });

  test('RetryBackoff grows, stays within cap, and stops', () {
    final backoff = RetryBackoff(
      base: const Duration(seconds: 2),
      max: const Duration(seconds: 10),
      maxAttempts: 4,
      random: Random(1),
    );
    final delays = [for (var i = 0; i < 4; i++) backoff.next()!];
    expect(delays[0].inMilliseconds, inInclusiveRange(1000, 2000));
    expect(delays[3].inMilliseconds, inInclusiveRange(5000, 10000));
    expect(backoff.next(), isNull);
    backoff.reset();
    expect(backoff.next(), isNotNull);
  });

  test('AppOpenDailyCap spreads ads across the day', () {
    final now = DateTime(2026, 1, 1, 12);
    expect(AppOpenDailyCap.canShow(cap: 0, shownToday: 99, lastShown: now, now: now), isTrue);
    expect(AppOpenDailyCap.canShow(cap: 3, shownToday: 3, lastShown: null, now: now), isFalse);
    // cap 4 → one every 6 hours.
    expect(AppOpenDailyCap.canShow(
        cap: 4, shownToday: 1, lastShown: now.subtract(const Duration(hours: 2)), now: now), isFalse);
    expect(AppOpenDailyCap.canShow(
        cap: 4, shownToday: 1, lastShown: now.subtract(const Duration(hours: 7)), now: now), isTrue);
  });

  test('parsePremiumStatus handles common shapes', () {
    expect(AdsManager.parsePremiumStatus({'isPremium': true}), isTrue);
    expect(AdsManager.parsePremiumStatus({'status': 'active'}), isTrue);
    expect(AdsManager.parsePremiumStatus({'status': 'expired'}), isFalse);
    expect(AdsManager.parsePremiumStatus({'subscription': {'isActive': false}}), isFalse);
    expect(AdsManager.parsePremiumStatus({'subscription': null}), isFalse);
    expect(AdsManager.parsePremiumStatus({'foo': 1}), isNull);
    expect(AdsManager.parsePremiumStatus('nope'), isNull);
  });

  test('parseHexColor', () {
    expect(parseHexColor('#A3D223', Colors.red), const Color(0xFFA3D223));
    expect(parseHexColor('80FFFFFF', Colors.red), const Color(0x80FFFFFF));
    expect(parseHexColor('bad', Colors.red), Colors.red);
  });
}
