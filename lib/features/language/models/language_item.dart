class LanguageItem {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final String sublabel;

  const LanguageItem({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.sublabel,
  });

  static const List<LanguageItem> supportedLanguages = [
    LanguageItem(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
      sublabel: 'Default Language',
    ),
    LanguageItem(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '🇮🇳',
      sublabel: 'Hindi Language',
    ),
    LanguageItem(
      code: 'gu',
      name: 'Gujarati',
      nativeName: 'ગુજરાતી',
      flag: '🇮🇳',
      sublabel: 'Gujarati Language',
    ),
    LanguageItem(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      flag: '🇪🇸',
      sublabel: 'Idioma español',
    ),
    LanguageItem(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
      sublabel: 'Langue française',
    ),
    LanguageItem(
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
      flag: '🇩🇪',
      sublabel: 'Deutsche Sprache',
    ),
    LanguageItem(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      flag: '🇸🇦',
      sublabel: 'اللغة العربية',
    ),
    LanguageItem(
      code: 'zh',
      name: 'Chinese',
      nativeName: '中文',
      flag: '🇨🇳',
      sublabel: '普通话 / 华语',
    ),
    LanguageItem(
      code: 'pt',
      name: 'Portuguese',
      nativeName: 'Português',
      flag: '🇧🇷',
      sublabel: 'Língua portuguesa',
    ),
    LanguageItem(
      code: 'ja',
      name: 'Japanese',
      nativeName: '日本語',
      flag: '🇯🇵',
      sublabel: 'にほんご',
    ),
  ];
}
