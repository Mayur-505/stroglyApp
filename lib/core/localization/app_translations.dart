import 'languages/en.dart';
import 'languages/hi.dart';
import 'languages/gu.dart';
import 'languages/es.dart';
import 'languages/fr.dart';
import 'languages/de.dart';
import 'languages/ar.dart';
import 'languages/zh.dart';
import 'languages/pt.dart';
import 'languages/ja.dart';

class AppTranslations {
  static const Map<String, Map<String, String>> translations = {
    'en': enTranslations,
    'hi': hiTranslations,
    'gu': guTranslations,
    'es': esTranslations,
    'fr': frTranslations,
    'de': deTranslations,
    'ar': arTranslations,
    'zh': zhTranslations,
    'pt': ptTranslations,
    'ja': jaTranslations,
  };

  static Map<String, String> get(String langCode) {
    return translations[langCode] ?? enTranslations;
  }
}
