import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get_navigation/src/root/internacionalization.dart';

/// GetX [Translations] implementation backed by flat key-value JSON files
/// under `assets/translations/<locale>.json` (one file per supported locale).
///
/// [load] must be awaited once, before `runApp`, so [keys] can stay
/// synchronous as required by GetX.
class AppTranslation extends Translations {
  static const List<String> supportedLocales = [
    'pt_BR',
    'en_US',
    'es_ES',
    'it_IT',
    'fr_FR',
    'de_DE',
  ];

  static final Map<String, Map<String, String>> _data = {};

  /// Loads every locale's JSON translation file into memory. Must be awaited
  /// before `runApp` (needs `WidgetsFlutterBinding.ensureInitialized()`).
  static Future<void> load() async {
    for (final locale in supportedLocales) {
      final raw = await rootBundle.loadString(
        'assets/translations/$locale.json',
      );
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _data[locale] = decoded.map((key, value) => MapEntry(key, value as String));
    }
  }

  @override
  Map<String, Map<String, String>> get keys => _data;
}
