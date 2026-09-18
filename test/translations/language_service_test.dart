import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uffmobileplus/app/utils/translations/language_service.dart';

/// Testes unitários do serviço de internacionalização e resolução de Locale (LanguageService).
void main() {
  const storageKey = 'selected_language_code';

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.locale = null;
  });

  tearDown(() {
    Get.locale = null;
    // ignore: invalid_use_of_visible_for_testing_member
    Get.reset();
  });

  group('supportedLanguages catalogue', () {
    test('Happy Path: expõe exatamente seis idiomas com códigos e locales únicos', () {
      // 1. Arrange
      const expectedCount = 6;

      // 2. Act
      final langs = LanguageService.supportedLanguages;

      // 3. Assert
      expect(langs.map((l) => l.code).toSet().length, expectedCount);
    });

    test('Happy Path: cada código de idioma coincide com o padrão lang_COUNTRY do seu Locale', () {
      // 1. Arrange
      final langs = LanguageService.supportedLanguages;

      // 2. Act
      final invalidMappings = langs.where(
        (l) => l.code != '${l.locale.languageCode}_${l.locale.countryCode}',
      ).toList();

      // 3. Assert
      expect(invalidMappings, isEmpty);
    });

    test('Edge Case: pt_BR é o primeiro idioma da lista para atuar como fallback padrão', () {
      // 1. Arrange
      final langs = LanguageService.supportedLanguages;

      // 2. Act
      final firstLanguageCode = langs.first.code;

      // 3. Assert
      expect(firstLanguageCode, 'pt_BR');
    });
  });

  group('getInitialLocale', () {
    test('Happy Path: restaura preferência de idioma salva anteriormente', () async {
      // 1. Arrange
      SharedPreferences.setMockInitialValues({storageKey: 'de_DE'});

      // 2. Act
      final initialLocale = await LanguageService.getInitialLocale();

      // 3. Assert
      expect(initialLocale, const Locale('de', 'DE'));
    });

    test('Edge Case: ignora preferência salva com código vazio e recai para idioma suportado', () async {
      // 1. Arrange
      SharedPreferences.setMockInitialValues({storageKey: ''});

      // 2. Act
      final initialLocale = await LanguageService.getInitialLocale();

      // 3. Assert
      expect(
        LanguageService.supportedLanguages.map((l) => l.locale),
        contains(initialLocale),
      );
    });

    test('Edge Case: sem preferência salva prévia, resolve para um locale suportado', () async {
      // 1. Arrange
      SharedPreferences.setMockInitialValues({});

      // 2. Act
      final initialLocale = await LanguageService.getInitialLocale();

      // 3. Assert
      expect(
        LanguageService.supportedLanguages.map((l) => l.locale),
        contains(initialLocale),
      );
    });

    test('Sad Path: ignora código salvo desconhecido ou inválido e recai para fallback suportado', () async {
      // 1. Arrange
      SharedPreferences.setMockInitialValues({storageKey: 'xx_XX'});

      // 2. Act
      final initialLocale = await LanguageService.getInitialLocale();

      // 3. Assert
      expect(
        LanguageService.supportedLanguages.map((l) => l.locale),
        contains(initialLocale),
      );
    });
  });

  group('getCurrentLanguage', () {
    test('Happy Path: retorna a correspondência exata para um Locale suportado ativo', () {
      // 1. Arrange
      Get.locale = const Locale('es', 'ES');

      // 2. Act
      final currentLang = LanguageService.getCurrentLanguage();

      // 3. Assert
      expect(currentLang.code, 'es_ES');
    });

    test('Happy Path: recai para correspondência por idioma base quando país difere', () {
      // 1. Arrange
      Get.locale = const Locale('de', 'AT');

      // 2. Act
      final currentLang = LanguageService.getCurrentLanguage();

      // 3. Assert
      expect(currentLang.code, 'de_DE');
    });

    test('Edge Case: recai para pt_BR quando Get.locale for nulo', () {
      // 1. Arrange
      Get.locale = null;

      // 2. Act
      final currentLang = LanguageService.getCurrentLanguage();

      // 3. Assert
      expect(currentLang.code, 'pt_BR');
    });

    test('Sad Path: recai para pt_BR quando Get.locale contiver idioma desconhecido', () {
      // 1. Arrange
      Get.locale = const Locale('ja', 'JP');

      // 2. Act
      final currentLang = LanguageService.getCurrentLanguage();

      // 3. Assert
      expect(currentLang.code, 'pt_BR');
    });
  });

  group('changeLanguage', () {
    testWidgets('Happy Path: changeLanguage atualiza o Get.locale', (tester) async {
      // 1. Arrange
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        const GetMaterialApp(locale: Locale('pt', 'BR'), home: SizedBox()),
      );
      final english = LanguageService.supportedLanguages
          .firstWhere((l) => l.code == 'en_US');

      // 2. Act
      final pending = LanguageService.changeLanguage(english);
      await tester.pumpAndSettle();
      await pending;

      // 3. Assert
      expect(Get.locale, const Locale('en', 'US'));
    });

    testWidgets('Happy Path: changeLanguage persiste o idioma escolhido no SharedPreferences', (tester) async {
      // 1. Arrange
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        const GetMaterialApp(locale: Locale('pt', 'BR'), home: SizedBox()),
      );
      final spanish = LanguageService.supportedLanguages
          .firstWhere((l) => l.code == 'es_ES');

      // 2. Act
      final pending = LanguageService.changeLanguage(spanish);
      await tester.pumpAndSettle();
      await pending;

      // 3. Assert
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(storageKey), 'es_ES');
    });

    testWidgets('Happy Path: idioma salvo via changeLanguage é recuperado por getInitialLocale', (tester) async {
      // 1. Arrange
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        const GetMaterialApp(locale: Locale('pt', 'BR'), home: SizedBox()),
      );
      final english = LanguageService.supportedLanguages
          .firstWhere((l) => l.code == 'en_US');
      final pending = LanguageService.changeLanguage(english);
      await tester.pumpAndSettle();
      await pending;

      // 2. Act
      final restoredLocale = await LanguageService.getInitialLocale();

      // 3. Assert
      expect(restoredLocale, english.locale);
    });
  });
}
