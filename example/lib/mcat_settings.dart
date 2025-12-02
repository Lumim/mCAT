import 'dart:ui';

class McatSettings {
  McatSettings._();

  static const String appName = "mCAT Example App";

  static const String appVersion = "1.0.0";
  // English (UK) word list
  static const List<String> _wordsEn = [
    'mountain',
    'city',
    'snowman',
    'coffee',
    'airport',
    'book',
    'cartoon',
    'sky',
    'garden',
    'house',
  ];

  // Danish word list
  static const List<String> _wordsDa = [
    'bjerg',
    'by',
    'snemand',
    'kaffe',
    'lufthavn',
    'bog',
    'tegneserie',
    'himmel',
    'have',
    'hus',
  ];

  /// Get the device locale (e.g., en_GB, da_DK)
  static Locale get deviceLocale => PlatformDispatcher.instance.locale;

  /// Normalize to app locale (we only support en_GB and da_DK here)
  static Locale get appLocale {
    final l = deviceLocale;
    if (l.languageCode == 'da') {
      return const Locale('da', 'DK');
    }
    // default
    return const Locale('en', 'GB');
  }

  /// Get word list based on locale
  static List<String> wordTaskWords(Locale? locale) {
    final l = locale ?? appLocale;
    if (l.languageCode == 'da') return _wordsDa;
    return _wordsEn;
  }

  /// Example localized strings
  static String wordTaskTitle(Locale? locale) {
    final l = locale ?? appLocale;
    if (l.languageCode == 'da') return 'Ordopgave';
    return 'Word Task';
  }

  static String wordRecallTitle(Locale? locale) {
    final l = locale ?? appLocale;
    if (l.languageCode == 'da') return 'Ordgenkaldelse';
    return 'Word Recall';
  }
}
