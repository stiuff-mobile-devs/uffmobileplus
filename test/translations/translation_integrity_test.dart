import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uffmobileplus/app/utils/translations/app_translations.dart';
import 'package:uffmobileplus/app/utils/translations/language_service.dart';

/// Static integrity checks over `assets/translations/*.json`.
///
/// These run on the host VM (no Flutter binding needed) and are the cheap
/// guard-rail for the JSON-backed i18n introduced on this branch: a key that
/// exists in code but not in the JSON renders the raw key string on screen,
/// and a locale missing a key silently falls back to pt_BR.
void main() {
  const baseLocale = 'pt_BR';

  late Map<String, Map<String, String>> translations;

  Map<String, String> load(String locale) {
    final file = File('assets/translations/$locale.json');
    expect(
      file.existsSync(),
      isTrue,
      reason: 'assets/translations/$locale.json is missing',
    );
    final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as String));
  }

  setUpAll(() {
    translations = {
      for (final locale in AppTranslation.supportedLocales)
        locale: load(locale),
    };
  });

  group('locale coverage', () {
    test('every supported locale has a JSON file that parses', () {
      expect(
        translations.keys.toSet(),
        AppTranslation.supportedLocales.toSet(),
      );
    });

    test('AppTranslation.supportedLocales matches LanguageService codes', () {
      final serviceCodes =
          LanguageService.supportedLanguages.map((l) => l.code).toList();
      expect(
        serviceCodes..sort(),
        AppTranslation.supportedLocales.toList()..sort(),
        reason:
            'A language offered in the selector with no JSON file would render '
            'every string as its raw key.',
      );
    });

    test('every locale defines exactly the pt_BR key set', () {
      final baseKeys = translations[baseLocale]!.keys.toSet();
      for (final entry in translations.entries) {
        if (entry.key == baseLocale) continue;
        final keys = entry.value.keys.toSet();
        expect(
          baseKeys.difference(keys),
          isEmpty,
          reason: '${entry.key} is missing keys present in $baseLocale',
        );
        expect(
          keys.difference(baseKeys),
          isEmpty,
          reason: '${entry.key} defines keys absent from $baseLocale',
        );
      }
    });
  });

  group('value hygiene', () {
    test('no empty or whitespace-only values', () {
      for (final entry in translations.entries) {
        final empty =
            entry.value.entries.where((e) => e.value.trim().isEmpty).map((e) => e.key);
        expect(empty, isEmpty, reason: '${entry.key} has empty values');
      }
    });

    test('no duplicate keys in the raw JSON source', () {
      final keyPattern = RegExp(r'^\s*"((?:[^"\\]|\\.)*)"\s*:', multiLine: true);
      for (final locale in AppTranslation.supportedLocales) {
        final raw = File('assets/translations/$locale.json').readAsStringSync();
        final keys = keyPattern.allMatches(raw).map((m) => m.group(1)!).toList();
        final seen = <String>{};
        final dupes = keys.where((k) => !seen.add(k)).toList();
        expect(
          dupes,
          isEmpty,
          reason: '$locale.json has duplicate keys (last one silently wins)',
        );
      }
    });

    test('@placeholders in a translation are a subset of the pt_BR set', () {
      final placeholder = RegExp(r'@(\w+)');
      Set<String> paramsOf(String s) =>
          placeholder.allMatches(s).map((m) => m.group(1)!).toSet();

      for (final entry in translations.entries) {
        if (entry.key == baseLocale) continue;
        for (final kv in entry.value.entries) {
          final base = paramsOf(translations[baseLocale]![kv.key]!);
          final got = paramsOf(kv.value);
          expect(
            got.difference(base),
            isEmpty,
            reason:
                '${entry.key}["${kv.key}"] uses @placeholders that $baseLocale '
                'never supplies — they would render literally',
          );
        }
      }
    });
  });

  group('code <-> JSON consistency', () {
    /// Every `'key'.tr`, `.trParams`, `.trArgs`, `.trPlural` literal in lib/.
    Map<String, List<String>> usedKeys() {
      final pattern = RegExp(
        r"""(['"])((?:[^'"\\]|\\.)*?)\1\s*\.\s*(tr|trParams|trArgs|trPlural)\b""",
      );
      final result = <String, List<String>>{};
      for (final file in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final src = file.readAsStringSync();
        for (final m in pattern.allMatches(src)) {
          final line = '\n'.allMatches(src.substring(0, m.start)).length + 1;
          result.putIfAbsent(m.group(2)!, () => []).add('${file.path}:$line');
        }
      }
      return result;
    }

    test('every translation key used in lib/ is defined in pt_BR.json', () {
      final defined = translations[baseLocale]!.keys.toSet();
      final missing = <String, List<String>>{};
      usedKeys().forEach((key, sites) {
        if (!defined.contains(key)) missing[key] = sites;
      });
      expect(
        missing,
        isEmpty,
        reason: 'These keys would render as their raw string on screen:\n'
            '${missing.entries.map((e) => '  ${e.key} <- ${e.value.first}').join('\n')}',
      );
    });
  });

  group('module list labels', () {
    // The dashboard/restaurant/library grids build their entries in `RxList`
    // FIELD INITIALISERS, which run once when the controller is constructed.
    // Resolving `.tr` there froze every button label in the language that was
    // active at startup, and the render site's second `.tr` then looked the
    // already-translated Portuguese text up as a key and fell through verbatim
    // — so the buttons never followed a language change. The keys must stay
    // raw here and be resolved at the render site.
    const controllers = [
      'lib/app/modules/internal_modules/dashboard/controller/external_modules_controller.dart',
      'lib/app/modules/external_modules/restaurante/controller/restaurant_modules_controller.dart',
      'lib/app/modules/external_modules/bibliotecas/controller/bibliotecas_controller.dart',
    ];

    test('no module list resolves .tr in its field initialiser', () {
      for (final path in controllers) {
        final src = File(path).readAsStringSync();
        final offenders = RegExp(r"subtitle:\s*'[^']*'\s*\.\s*tr\b")
            .allMatches(src)
            .map((m) => m.group(0))
            .toList();
        expect(
          offenders,
          isEmpty,
          reason: '$path resolves .tr at construction time, which freezes the '
              'label in the startup language. Store the key and call .tr where '
              'the label is rendered.',
        );
      }
    });

    test('every module subtitle key is defined in every locale', () {
      final pattern = RegExp(r"subtitle:\s*'([^']+)'");
      var checked = 0;

      for (final path in controllers) {
        final src = File(path).readAsStringSync();
        for (final m in pattern.allMatches(src)) {
          final key = m.group(1)!;
          checked++;
          for (final locale in AppTranslation.supportedLocales) {
            expect(
              translations[locale],
              contains(key),
              reason: '$path uses "$key", missing from $locale — the button '
                  'would render the raw key',
            );
          }
        }
      }

      expect(checked, greaterThan(20), reason: 'module lists were not found');
    });
  });
}
