import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_translations.dart';

class LanguageService {
  static final LanguageService instance = LanguageService._internal();
  factory LanguageService() => instance;
  LanguageService._internal();

  static const String _prefKey = 'strongly_selected_language';
  final ValueNotifier<String> currentLanguageNotifier = ValueNotifier<String>('en');

  String get currentLanguage => currentLanguageNotifier.value;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);
      if (savedCode != null && AppTranslations.translations.containsKey(savedCode)) {
        currentLanguageNotifier.value = savedCode;
      }
    } catch (_) {}
  }

  Future<void> setLanguage(String languageCode) async {
    if (!AppTranslations.translations.containsKey(languageCode)) return;
    currentLanguageNotifier.value = languageCode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, languageCode);
    } catch (_) {}
  }

  static String tr(String key) {
    return instance.translate(key);
  }

  String translate(String key) {
    final lang = currentLanguageNotifier.value;
    final map = AppTranslations.get(lang);
    final fallbackMap = AppTranslations.get('en');
    return map[key] ?? fallbackMap[key] ?? key;
  }
}

extension TranslationExtension on String {
  String get tr => LanguageService.tr(this);
}
