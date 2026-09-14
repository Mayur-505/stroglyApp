import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_colors.dart';
import 'core/services/language_service.dart';
import 'features/splash/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await LanguageService.instance.init();
  runApp(const StronglyApp());
}

class StronglyApp extends StatelessWidget {
  const StronglyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.instance.currentLanguageNotifier,
      builder: (context, currentLanguage, _) {
        return MaterialApp(
          key: ValueKey(currentLanguage),
          title: 'Strongly',
          debugShowCheckedModeBanner: false,
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
