import 'dart:math';

/// Exponential backoff with full jitter: 2s, 4s, 8s … capped at [max].
class RetryBackoff {
  final Duration base;
  final Duration max;
  final int maxAttempts;
  final Random _random;
  int _attempt = 0;

  RetryBackoff({
    this.base = const Duration(seconds: 2),
    this.max = const Duration(seconds: 64),
    this.maxAttempts = 6,
    Random? random,
  }) : _random = random ?? Random();

  int get attempt => _attempt;
  bool get exhausted => _attempt >= maxAttempts;

  /// Delay before the next attempt. Returns null once [maxAttempts] is hit.
  Duration? next() {
    if (exhausted) return null;
    final capMs = min(
      max.inMilliseconds,
      base.inMilliseconds * pow(2, _attempt).toInt(),
    );
    _attempt++;
    // Half fixed, half random, so retries from many devices don't line up.
    final half = capMs ~/ 2;
    return Duration(milliseconds: half + _random.nextInt(half + 1));
  }

  void reset() => _attempt = 0;
}

enum NavDirection { forward, backward }

/// Decides when a navigation tap may show an interstitial.
///
/// A direction fires on every `gap + 1`th tap, and only after that
/// direction's cooldown has passed since the last interstitial.
class InterstitialPacer {
  int _forwardClicks = 0;
  int _backwardClicks = 0;
  DateTime? _lastShown;

  int get forwardClicks => _forwardClicks;
  int get backwardClicks => _backwardClicks;
  DateTime? get lastShown => _lastShown;

  /// Counts a tap and returns true when an interstitial should be shown.
  bool registerClick({
    required NavDirection direction,
    required bool enabled,
    required int gap,
    required Duration cooldown,
    required DateTime now,
  }) {
    if (!enabled) return false;
    final count = direction == NavDirection.forward
        ? ++_forwardClicks
        : ++_backwardClicks;
    if (count < gap + 1) return false;
    return cooldownPassed(cooldown, now);
  }

  bool cooldownPassed(Duration cooldown, DateTime now) =>
      _lastShown == null || now.difference(_lastShown!) >= cooldown;

  /// Call after any full-screen ad, so counting restarts.
  void markShown(DateTime now) {
    _lastShown = now;
    _forwardClicks = 0;
    _backwardClicks = 0;
  }
}

/// Spreads at most [cap] app-open ads evenly across a day.
class AppOpenDailyCap {
  /// [cap] 0 means unlimited.
  static bool canShow({
    required int cap,
    required int shownToday,
    required DateTime? lastShown,
    required DateTime now,
  }) {
    if (cap <= 0) return true;
    if (shownToday >= cap) return false;
    if (lastShown == null) return true;
    final spacing = Duration(minutes: (24 * 60) ~/ cap);
    return now.difference(lastShown) >= spacing;
  }

  static String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
