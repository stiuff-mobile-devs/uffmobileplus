import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage {
  final String name;
  final String nativeName;
  final String code;
  final Locale locale;
  final String flagAsset;

  const AppLanguage({
    required this.name,
    required this.nativeName,
    required this.code,
    required this.locale,
    required this.flagAsset,
  });
}

class LanguageService {
  static const String _storageKey = 'selected_language_code';

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(
      name: 'Português (BR)',
      nativeName: 'Português',
      code: 'pt_BR',
      locale: Locale('pt', 'BR'),
      flagAsset: 'assets/icons/flags/flag_br.svg',
    ),
    AppLanguage(
      name: 'English (US)',
      nativeName: 'English',
      code: 'en_US',
      locale: Locale('en', 'US'),
      flagAsset: 'assets/icons/flags/flag_us.svg',
    ),
    AppLanguage(
      name: 'Español (ES)',
      nativeName: 'Español',
      code: 'es_ES',
      locale: Locale('es', 'ES'),
      flagAsset: 'assets/icons/flags/flag_es.svg',
    ),
    AppLanguage(
      name: 'Italiano (IT)',
      nativeName: 'Italiano',
      code: 'it_IT',
      locale: Locale('it', 'IT'),
      flagAsset: 'assets/icons/flags/flag_it.svg',
    ),
    AppLanguage(
      name: 'Français (FR)',
      nativeName: 'Français',
      code: 'fr_FR',
      locale: Locale('fr', 'FR'),
      flagAsset: 'assets/icons/flags/flag_fr.svg',
    ),
    AppLanguage(
      name: 'Deutsch (DE)',
      nativeName: 'Deutsch',
      code: 'de_DE',
      locale: Locale('de', 'DE'),
      flagAsset: 'assets/icons/flags/flag_de.svg',
    ),
  ];

  /// Retrieves stored locale or defaults to device/Portuguese locale
  static Future<Locale> getInitialLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_storageKey);
      if (savedCode != null && savedCode.isNotEmpty) {
        final found = supportedLanguages.firstWhereOrNull(
          (lang) => lang.code == savedCode,
        );
        if (found != null) {
          return found.locale;
        }
      }
    } catch (e) {
      debugPrint('Error reading stored language: $e');
    }

    final deviceLocale = Get.deviceLocale;
    if (deviceLocale != null) {
      final matchingLanguage = supportedLanguages.firstWhereOrNull(
        (lang) => lang.locale.languageCode == deviceLocale.languageCode,
      );
      if (matchingLanguage != null) {
        return matchingLanguage.locale;
      }
    }

    return const Locale('pt', 'BR');
  }

  /// Get current AppLanguage model based on Get.locale
  static AppLanguage getCurrentLanguage() {
    final currentLocale = Get.locale ?? const Locale('pt', 'BR');
    final match = supportedLanguages.firstWhereOrNull(
      (lang) =>
          lang.locale.languageCode == currentLocale.languageCode &&
          lang.locale.countryCode == currentLocale.countryCode,
    );
    return match ??
        supportedLanguages.firstWhere(
          (lang) => lang.locale.languageCode == currentLocale.languageCode,
          orElse: () => supportedLanguages.first,
        );
  }

  /// Updates app locale and persists preference
  static Future<void> changeLanguage(AppLanguage language) async {
    await Get.updateLocale(language.locale);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, language.code);
    } catch (e) {
      debugPrint('Error saving selected language: $e');
    }
  }
}
