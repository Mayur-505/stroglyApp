import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/ads/ads_manager.dart';
import 'core/services/remote_config_service.dart';
import 'core/constants/app_colors.dart';
import 'core/services/language_service.dart';
import 'core/network/auth_session_manager.dart';
import 'features/splash/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await LanguageService.instance.init();
  await AuthSessionManager.instance.init();
  await RemoteConfigService.instance.loadDefaults();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 5));
    await RemoteConfigService.instance.init();
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }
  runApp(const StronglyApp());
  // Consent + Mobile Ads start in the background; the splash screen waits
  // for them with its own timeout.
  unawaited(AdsManager.instance.init());
}

class StronglyApp extends StatelessWidget {
  const StronglyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.instance.currentLanguageNotifier,
      builder: (context, currentLanguage, _) {
        return MaterialApp(
          title: 'Strongly',
          debugShowCheckedModeBanner: false,
          navigatorKey: AdsManager.instance.navigatorKey,
          navigatorObservers: [AdsManager.instance.navigatorObserver],
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.backgroundBlack,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryLime,
              surface: AppColors.backgroundBlack,
            ),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
