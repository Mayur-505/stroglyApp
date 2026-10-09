import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google UMP consent (GDPR/EEA, US states). Ads are only requested once
/// [canRequestAds] is true.
class ConsentManager {
  bool _formShowing = false;
  bool _privacyOptionsRequired = false;

  bool get formShowing => _formShowing;
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  /// Consent from a previous session, available immediately on launch.
  Future<bool> canRequestAds() async {
    try {
      return await ConsentInformation.instance.canRequestAds();
    } catch (_) {
      return false;
    }
  }

  /// Refreshes consent info and shows the form if the user needs one.
  /// Never throws and never waits longer than [timeout] for the network.
  Future<bool> gatherConsent({
    bool underAgeOfConsent = false,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final updated = Completer<bool>();
    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(tagForUnderAgeOfConsent: underAgeOfConsent),
        () => updated.complete(true),
        (error) {
          _log('info update failed: ${error.message}');
          updated.complete(false);
        },
      );
      final ok = await updated.future.timeout(timeout, onTimeout: () => false);
      if (ok) {
        final dismissed = Completer<void>();
        _formShowing = true;
        ConsentForm.loadAndShowConsentFormIfRequired((formError) {
          if (formError != null) _log('form error: ${formError.message}');
          if (!dismissed.isCompleted) dismissed.complete();
        });
        await dismissed.future;
        _formShowing = false;
        _privacyOptionsRequired =
            await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
                PrivacyOptionsRequirementStatus.required;
      }
    } catch (e) {
      _formShowing = false;
      _log('consent flow error: $e');
    }
    return canRequestAds();
  }

  /// Opens the privacy options form so users can change their choice.
  Future<void> showPrivacyOptions() async {
    final done = Completer<void>();
    try {
      _formShowing = true;
      ConsentForm.showPrivacyOptionsForm((formError) {
        if (formError != null) _log('privacy form error: ${formError.message}');
        if (!done.isCompleted) done.complete();
      });
      await done.future;
    } catch (e) {
      _log('privacy form error: $e');
    } finally {
      _formShowing = false;
    }
  }

  void _log(String msg) {
    if (kDebugMode) debugPrint('[Ads][Consent] $msg');
  }
}
