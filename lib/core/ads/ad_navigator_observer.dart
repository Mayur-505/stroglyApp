import 'package:flutter/widgets.dart';
import 'ad_pacing.dart';
import 'ads_manager.dart';

/// Turns full-page navigation into forward/back "clicks" for interstitial
/// pacing (`click_mode`, `*_click_gap`, `*_timer`). Bottom sheets, dialogs
/// and the ad loading dialog are ignored.
///
/// The decision runs after the frame, so a screen that opens a quiet zone
/// in `initState` (the active workout) is already protected.
class AdNavigatorObserver extends NavigatorObserver {
  final AdsManager _ads;

  AdNavigatorObserver(this._ads);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // The first route (splash) is not a user tap.
    if (route is PageRoute && previousRoute != null) {
      _schedule(NavDirection.forward);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) _schedule(NavDirection.backward);
  }

  void _schedule(NavDirection direction) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_ads.inQuietZone) return;
      _ads.interstitial.onNavigation(direction);
    });
  }
}
