import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uffmobileplus/app/utils/translations/language_service.dart';

/// Behaviour of the locale resolution / persistence introduced on this branch.
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
    test('exposes six languages with unique codes and locales', () {
      final langs = LanguageService.supportedLanguages;
      expect(langs, hasLength(6));
      expect(langs.map((l) => l.code).toSet(), hasLength(6));
      expect(
        langs.map((l) => '${l.locale.languageCode}_${l.locale.countryCode}').toSet(),
        hasLength(6),
      );
    });

    test('each code is `lang_COUNTRY` and agrees with its Locale', () {
      for (final lang in LanguageService.supportedLanguages) {
        expect(
          lang.code,
          '${lang.locale.languageCode}_${lang.locale.countryCode}',
          reason: '${lang.name}: code and Locale disagree, so the persisted '
              'preference would not resolve back to this language',
        );
      }
    });

    test('pt_BR is first so it is the orElse fallback', () {
      expect(LanguageService.supportedLanguages.first.code, 'pt_BR');
    });
  });

  group('getInitialLocale', () {
    test('restores a previously saved language', () async {
      SharedPreferences.setMockInitialValues({storageKey: 'de_DE'});
      expect(await LanguageService.getInitialLocale(), const Locale('de', 'DE'));
    });

    test('ignores an unknown saved code and falls back', () async {
      SharedPreferences.setMockInitialValues({storageKey: 'xx_XX'});
      final locale = await LanguageService.getInitialLocale();
      expect(
        LanguageService.supportedLanguages.map((l) => l.locale),
        contains(locale),
      );
    });

    test('ignores an empty saved code', () async {
      SharedPreferences.setMockInitialValues({storageKey: ''});
      final locale = await LanguageService.getInitialLocale();
      expect(
        LanguageService.supportedLanguages.map((l) => l.locale),
        contains(locale),
      );
    });

    // NOTE: `LanguageService.getInitialLocale` reads `Get.deviceLocale`, which
    // GetX defines as `PlatformDispatcher.instance.locale` — the real platform
    // singleton, not the binding's overridable `tester.platformDispatcher`.
    // The device-locale branch therefore cannot be driven from a test; only the
    // saved-preference branch and the shape of the result are assertable here.
    test('with no preference, resolves to a supported locale', () async {
      SharedPreferences.setMockInitialValues({});
      final locale = await LanguageService.getInitialLocale();
      expect(
        LanguageService.supportedLanguages.map((l) => l.locale),
        contains(locale),
        reason: 'the device-locale branch must never yield an unsupported '
            'locale, or every string would fall back to pt_BR',
      );
    });

    test('a saved preference is honoured for every supported language', () async {
      for (final language in LanguageService.supportedLanguages) {
        SharedPreferences.setMockInitialValues({storageKey: language.code});
        expect(
          await LanguageService.getInitialLocale(),
          language.locale,
          reason: '${language.code} did not resolve back to its Locale',
        );
      }
    });
  });

  group('getCurrentLanguage', () {
    test('defaults to pt_BR when Get.locale is unset', () {
      Get.locale = null;
      expect(LanguageService.getCurrentLanguage().code, 'pt_BR');
    });

    test('returns the exact match for a supported locale', () {
      Get.locale = const Locale('es', 'ES');
      expect(LanguageService.getCurrentLanguage().code, 'es_ES');
    });

    test('falls back to a language-only match', () {
      Get.locale = const Locale('de', 'AT');
      expect(LanguageService.getCurrentLanguage().code, 'de_DE');
    });

    test('falls back to the first language for an unknown locale', () {
      Get.locale = const Locale('ja', 'JP');
      expect(LanguageService.getCurrentLanguage().code, 'pt_BR');
    });
  });

  group('changeLanguage', () {
    testWidgets('updates Get.locale and persists the choice', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        const GetMaterialApp(locale: Locale('pt', 'BR'), home: SizedBox()),
      );

      final english = LanguageService.supportedLanguages
          .firstWhere((l) => l.code == 'en_US');
      // `Get.updateLocale` awaits `engine.performReassemble()`, which only
      // completes once a frame is pumped — so pump while it is in flight.
      final pending = LanguageService.changeLanguage(english);
      await tester.pumpAndSettle();
      await pending;

      expect(Get.locale, const Locale('en', 'US'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(storageKey), 'en_US');
      expect(LanguageService.getCurrentLanguage().code, 'en_US');
    });

    testWidgets('a saved choice round-trips through getInitialLocale',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        const GetMaterialApp(locale: Locale('pt', 'BR'), home: SizedBox()),
      );

      for (final language in LanguageService.supportedLanguages) {
        final pending = LanguageService.changeLanguage(language);
        await tester.pumpAndSettle();
        await pending;
        expect(
          await LanguageService.getInitialLocale(),
          language.locale,
          reason: '${language.code} did not survive a save/restore cycle',
        );
      }
    });
  });
}
