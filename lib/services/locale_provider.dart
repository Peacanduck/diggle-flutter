/// locale_provider.dart
/// Manages the app's locale selection with persistence via SharedPreferences.
///
/// Supports:
///   - System default (null locale → follows device language)
///   - Explicit locale override (user picks from settings)
///
/// Usage:
///   final provider = context.read<LocaleProvider>();
///   provider.setLocale(const Locale('es'));  // switch to Spanish
///   provider.clearLocale();                  // back to system default

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _prefKey = 'app_locale';

  Locale? _locale;

  /// Current locale override. `null` means follow system default.
  Locale? get locale => _locale;

  /// Initialize from persisted preference. Call once at app startup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
    }
    notifyListeners();
  }

  /// Set explicit locale override and persist.
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }

  /// Clear override → follow system language.
  Future<void> clearLocale() async {
    _locale = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  // ── Supported languages ────────────────────────────────────────
  // Add entries here as you create new .arb files.
  // The first entry is the fallback.

  static const supportedLocales = <Locale>[
    Locale('en'), // English  (template)
    // Locale('es'), // Spanish  — uncomment when app_es.arb exists
    // Locale('pt'), // Portuguese
    // Locale('fr'), // French
    // Locale('de'), // German
    // Locale('ja'), // Japanese
    // Locale('zh'), // Chinese
    // Locale('ko'), // Korean
    // Locale('ru'), // Russian
    // Locale('ar'), // Arabic
  ];

  /// Human-readable labels for the language picker.
  static const localeLabels = <String, String>{
    'en': 'English',
    'es': 'Español',
    'pt': 'Português',
    'fr': 'Français',
    'de': 'Deutsch',
    'ja': '日本語',
    'zh': '中文',
    'ko': '한국어',
    'ru': 'Русский',
    'ar': 'العربية',
  };

  /// Flag emoji for each locale (optional visual flair).
  static const localeFlags = <String, String>{
    'en': '🇬🇧',
    'es': '🇪🇸',
    'pt': '🇧🇷',
    'fr': '🇫🇷',
    'de': '🇩🇪',
    'ja': '🇯🇵',
    'zh': '🇨🇳',
    'ko': '🇰🇷',
    'ru': '🇷🇺',
    'ar': '🇸🇦',
  };
}