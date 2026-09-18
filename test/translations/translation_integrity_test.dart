import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uffmobileplus/app/utils/translations/app_translations.dart';
import 'package:uffmobileplus/app/utils/translations/language_service.dart';

/// Testes de integridade estática sobre `assets/translations/*.json`.
void main() {
  const baseLocale = 'pt_BR';

  late Map<String, Map<String, String>> translations;

  Map<String, String> load(String locale) {
    final file = File('assets/translations/$locale.json');
    expect(
      file.existsSync(),
      isTrue,
      reason: 'assets/translations/$locale.json não foi encontrado',
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
    test('Happy Path: todo locale suportado possui arquivo JSON correspondente e parseável', () {
      // 1. Arrange
      final supportedLocales = AppTranslation.supportedLocales.toSet();

      // 2. Act
      final loadedLocales = translations.keys.toSet();

      // 3. Assert
      expect(loadedLocales, supportedLocales);
    });

    test('Happy Path: AppTranslation.supportedLocales coincide com os códigos de LanguageService', () {
      // 1. Arrange
      final expectedCodes = AppTranslation.supportedLocales.toList()..sort();

      // 2. Act
      final serviceCodes = LanguageService.supportedLanguages.map((l) => l.code).toList()..sort();

      // 3. Assert
      expect(
        serviceCodes,
        expectedCodes,
        reason: 'Uma linguagem exposta sem arquivo JSON renderizaria chave bruta.',
      );
    });

    test('Sad Path: nenhum locale deve apresentar divergência de chaves em relação a pt_BR', () {
      // 1. Arrange
      final baseKeys = translations[baseLocale]!.keys.toSet();

      // 2. Act
      final divergences = <String, String>{};
      for (final entry in translations.entries) {
        if (entry.key == baseLocale) continue;
        final keys = entry.value.keys.toSet();
        final missing = baseKeys.difference(keys);
        final extra = keys.difference(baseKeys);
        if (missing.isNotEmpty || extra.isNotEmpty) {
          divergences[entry.key] = 'faltando: $missing, extras: $extra';
        }
      }

      // 3. Assert
      expect(divergences, isEmpty, reason: 'Locales com chaves divergentes de $baseLocale');
    });
  });

  group('value hygiene', () {
    test('Edge Case: nenhum valor de tradução deve ser vazio ou conter apenas espaços', () {
      // 1. Arrange
      final allTranslations = translations.entries;

      // 2. Act
      final emptyValuesFound = allTranslations.expand(
        (entry) => entry.value.entries
            .where((e) => e.value.trim().isEmpty)
            .map((e) => '${entry.key}: ${e.key}'),
      ).toList();

      // 3. Assert
      expect(emptyValuesFound, isEmpty, reason: 'Existem valores vazios nas traduções');
    });

    test('Sad Path: arquivos JSON não devem conter chaves duplicadas', () {
      // 1. Arrange
      final keyPattern = RegExp(r'^\s*"((?:[^"\\]|\\.)*)"\s*:', multiLine: true);

      // 2. Act
      final duplicates = <String, List<String>>{};
      for (final locale in AppTranslation.supportedLocales) {
        final raw = File('assets/translations/$locale.json').readAsStringSync();
        final keys = keyPattern.allMatches(raw).map((m) => m.group(1)!).toList();
        final seen = <String>{};
        final dupes = keys.where((k) => !seen.add(k)).toList();
        if (dupes.isNotEmpty) {
          duplicates[locale] = dupes;
        }
      }

      // 3. Assert
      expect(duplicates, isEmpty, reason: 'Chaves duplicadas no JSON detectadas');
    });

    test('Edge Case: @placeholders na tradução devem ser estritamente um subconjunto de pt_BR', () {
      // 1. Arrange
      final placeholderRegex = RegExp(r'@(\w+)');
      Set<String> paramsOf(String s) =>
          placeholderRegex.allMatches(s).map((m) => m.group(1)!).toSet();

      // 2. Act
      final invalidPlaceholders = <String>[];
      for (final entry in translations.entries) {
        if (entry.key == baseLocale) continue;
        for (final kv in entry.value.entries) {
          final base = paramsOf(translations[baseLocale]![kv.key] ?? '');
          final got = paramsOf(kv.value);
          final diff = got.difference(base);
          if (diff.isNotEmpty) {
            invalidPlaceholders.add('${entry.key}["${kv.key}"]: $diff');
          }
        }
      }

      // 3. Assert
      expect(invalidPlaceholders, isEmpty, reason: 'Placeholders desconhecidos encontrados');
    });
  });

  group('code <-> JSON consistency', () {
    test('Happy Path: toda chave de tradução utilizada no código lib/ está definida em pt_BR.json', () {
      // 1. Arrange
      final definedKeys = translations[baseLocale]!.keys.toSet();
      final usagePattern = RegExp(
        r"""(['"])((?:[^'"\\]|\\.)*?)\1\s*\.\s*(tr|trParams|trArgs|trPlural)\b""",
      );

      // 2. Act
      final missingKeys = <String, List<String>>{};
      for (final file in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final src = file.readAsStringSync();
        for (final m in usagePattern.allMatches(src)) {
          final key = m.group(2)!;
          if (!definedKeys.contains(key)) {
            final line = '\n'.allMatches(src.substring(0, m.start)).length + 1;
            missingKeys.putIfAbsent(key, () => []).add('${file.path}:$line');
          }
        }
      }

      // 3. Assert
      expect(missingKeys, isEmpty, reason: 'Chaves no código sem tradução em pt_BR');
    });
  });

  group('module list labels', () {
    const controllers = [
      'lib/app/modules/internal_modules/dashboard/controller/external_modules_controller.dart',
      'lib/app/modules/external_modules/restaurante/controller/restaurant_modules_controller.dart',
      'lib/app/modules/external_modules/bibliotecas/controller/bibliotecas_controller.dart',
    ];

    test('Sad Path: nenhuma lista de módulo deve resolver .tr em inicializador de campo', () {
      // 1. Arrange
      final fieldResolutionPattern = RegExp(r"subtitle:\s*'[^']*'\s*\.\s*tr\b");

      // 2. Act
      final earlyResolutions = <String>[];
      for (final path in controllers) {
        final src = File(path).readAsStringSync();
        final matches = fieldResolutionPattern.allMatches(src);
        for (final match in matches) {
          earlyResolutions.add('$path: ${match.group(0)}');
        }
      }

      // 3. Assert
      expect(earlyResolutions, isEmpty, reason: 'Chaves resolvidas prematuramente no inicializador');
    });

    test('Edge Case: toda chave de subtítulo de módulo deve estar definida em todos os idiomas', () {
      // 1. Arrange
      final subtitleKeyPattern = RegExp(r"subtitle:\s*'([^']+)'");

      // 2. Act
      final missingModuleKeys = <String>[];
      for (final path in controllers) {
        final src = File(path).readAsStringSync();
        for (final m in subtitleKeyPattern.allMatches(src)) {
          final key = m.group(1)!;
          for (final locale in AppTranslation.supportedLocales) {
            if (!translations[locale]!.containsKey(key)) {
              missingModuleKeys.add('$path: "$key" ausente em $locale');
            }
          }
        }
      }

      // 3. Assert
      expect(missingModuleKeys, isEmpty, reason: 'Chaves de módulo ausentes em algum locale');
    });
  });
}
