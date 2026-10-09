import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase config for project `strongly-4771a`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase is not configured for web.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase is not configured for $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC4GvTkzqnYyFa2n_CKvvSJIPZvi3o5meo',
    appId: '1:922853512120:android:35861252a7ecabc53b754d',
    messagingSenderId: '922853512120',
    projectId: 'strongly-4771a',
    storageBucket: 'strongly-4771a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAKlwrdtibdGsnvSK9V18DrIiVVkGttO4A',
    appId: '1:922853512120:ios:4233c62b661ee2af3b754d',
    messagingSenderId: '922853512120',
    projectId: 'strongly-4771a',
    storageBucket: 'strongly-4771a.firebasestorage.app',
    iosBundleId: 'com.strongly.strongly',
  );
}
