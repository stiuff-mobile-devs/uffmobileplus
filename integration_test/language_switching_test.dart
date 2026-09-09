import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uffmobileplus/app/ui/widgets/language_selector_bottom_sheet.dart';
import 'package:uffmobileplus/app/ui/widgets/responsive_uff_logo.dart';
import 'package:uffmobileplus/app/utils/translations/app_translations.dart';
import 'package:uffmobileplus/app/utils/translations/language_service.dart';

/// On-device UI tests for the i18n work.
///
/// These run against a real Android device/emulator, so they exercise things a
/// host widget test cannot: loading the translation JSON out of the real APK
/// asset bundle, decoding the flag SVGs, the real `shared_preferences` store,
/// and — crucially — `Get.updateLocale`, whose `performReassemble()` corrupts
/// the fake-async binding used by `flutter test` but works correctly here.
///
/// Run with:
///   flutter test integration_test/language_switching_test.dart -d `device-id`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const storageKey = 'selected_language_code';

  setUpAll(() async {
    await AppTranslation.load();
  });

  setUp(() async {
    // Real on-device preference store: wipe so each test starts clean.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
    Get.locale = const Locale('pt', 'BR');
  });

  /// The harness mirrors how the app actually uses the picker: a translated
  /// screen plus a button that opens the real bottom sheet.
  Widget harness() => GetMaterialApp(
        translations: AppTranslation(),
        locale: Get.locale,
        fallbackLocale: const Locale('pt', 'BR'),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ResponsiveUffLogo(animate: false, width: 160),
                  Text('configuracoes'.tr, key: const Key('title')),
                  Text('ling_descricao'.tr, key: const Key('subtitle')),
                  Text('cancelar'.tr, key: const Key('cancel')),
                  ElevatedButton(
                    onPressed: () => LanguageSelectorBottomSheet.show(context),
                    child: const Text('open', key: Key('open')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  String textOf(Key key) =>
      (find.byKey(key).evaluate().single.widget as Text).data!;

  group('translation bundle on device', () {
    testWidgets('every locale JSON loads from the real asset bundle',
        (tester) async {
      for (final locale in AppTranslation.supportedLocales) {
        final map = AppTranslation().keys[locale];
        expect(map, isNotNull, reason: '$locale did not load on device');
        expect(map!, isNotEmpty, reason: '$locale loaded empty');
      }
    });

    testWidgets('all locales expose the same key set on device',
        (tester) async {
      final keys = AppTranslation().keys;
      final baseline = keys['pt_BR']!.keys.toSet();
      for (final locale in AppTranslation.supportedLocales) {
        expect(keys[locale]!.keys.toSet(), baseline, reason: '$locale differs');
      }
    });

    testWidgets('the flag SVG of every language decodes on device',
        (tester) async {
      for (final language in LanguageService.supportedLanguages) {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SvgPicture.asset(language.flagAsset, width: 48),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${language.flagAsset} failed to decode',
        );
      }
    });
  });

  group('switching language through the picker', () {
    testWidgets('each language re-renders the screen in that language',
        (tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      final seenTitles = <String, String>{};

      for (final language in LanguageService.supportedLanguages) {
        await tester.tap(find.byKey(const Key('open')));
        await tester.pumpAndSettle();

        expect(
          find.byType(LanguageSelectorBottomSheet),
          findsOneWidget,
          reason: 'picker did not open before selecting ${language.code}',
        );

        await tester.tap(find.text(language.nativeName));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(
          find.byType(LanguageSelectorBottomSheet),
          findsNothing,
          reason: 'picker stayed open after choosing ${language.code}',
        );
        expect(
          Get.locale,
          language.locale,
          reason: '${language.code} was not applied to Get.locale',
        );

        // The visible copy must match this locale's dictionary, not a fallback.
        final expected = AppTranslation().keys[language.code]!['configuracoes']!;
        expect(
          textOf(const Key('title')),
          expected,
          reason: 'screen text did not switch to ${language.code}',
        );
        seenTitles[language.code] = textOf(const Key('title'));
      }

      // Sanity: the six locales must not all render identical copy, or the
      // switch would be a no-op that the per-locale assertions could not catch.
      expect(
        seenTitles.values.toSet().length,
        greaterThan(1),
        reason: 'every locale rendered the same string',
      );
    });

    testWidgets('the choice is persisted and survives a restart',
        (tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deutsch'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      expect(prefs.getString(storageKey), 'de_DE');

      // What the next cold start would resolve to.
      expect(await LanguageService.getInitialLocale(), const Locale('de', 'DE'));

      // Rebuild the app from scratch, as a relaunch would.
      Get.locale = await LanguageService.getInitialLocale();
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(
        textOf(const Key('title')),
        AppTranslation().keys['de_DE']!['configuracoes'],
        reason: 'the saved language was not applied on restart',
      );
    });

    testWidgets('dismissing the picker leaves the language untouched',
        (tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();
      final before = textOf(const Key('title'));

      await tester.tap(find.byKey(const Key('open')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(Get.locale, const Locale('pt', 'BR'));
      expect(textOf(const Key('title')), before);

      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      expect(prefs.getString(storageKey), isNull);
    });

    testWidgets('no raw translation key ever reaches the screen',
        (tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      for (final language in LanguageService.supportedLanguages) {
        await tester.tap(find.byKey(const Key('open')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(language.nativeName));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        for (final key in const ['title', 'subtitle', 'cancel']) {
          final rendered = textOf(Key(key));
          expect(
            rendered,
            isNot(anyOf('configuracoes', 'ling_descricao', 'cancelar')),
            reason: 'raw key leaked in ${language.code}: $rendered',
          );
        }
      }
    });
  });

  group('picker rendering on the real screen', () {

    testWidgets('every language row is fully visible, including the last one',
        (tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open')));
      await tester.pumpAndSettle();

      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      // The system navigation bar / gesture area used to cover the bottom of
      // the half-height sheet, hiding the last entry (Deutsch).
      final safeBottom =
          tester.view.viewPadding.bottom / tester.view.devicePixelRatio;

      for (final language in LanguageService.supportedLanguages) {
        final tile = find.text(language.nativeName);
        expect(tile, findsOneWidget, reason: '${language.code} row missing');

        final rect = tester.getRect(tile);
        expect(
          rect.bottom,
          lessThanOrEqualTo(screen.height - safeBottom),
          reason: '${language.nativeName} is clipped by the system navigation '
              'bar (bottom ${rect.bottom}, usable ${screen.height - safeBottom})',
        );
        expect(rect.top, greaterThanOrEqualTo(0.0));
      }
    });

    testWidgets('the picker fills the screen and offers a back button',
        (tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open')));
      await tester.pumpAndSettle();

      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      final sheet = tester.getRect(find.byType(LanguageSelectorBottomSheet));
      expect(
        sheet.height,
        closeTo(screen.height, 1.0),
        reason: 'the picker should occupy the full screen',
      );

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(LanguageSelectorBottomSheet), findsNothing);
    });
    testWidgets('renders all six languages without overflowing the device',
        (tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open')));
      await tester.pumpAndSettle();

      for (final language in LanguageService.supportedLanguages) {
        expect(find.text(language.nativeName), findsOneWidget);
      }
      expect(find.byType(SvgPicture), findsAtLeastNWidgets(6));
      expect(tester.takeException(), isNull);

      // The sheet must fit inside the real viewport.
      final sheet = tester.getRect(find.byType(LanguageSelectorBottomSheet));
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      expect(sheet.height, lessThanOrEqualTo(screen.height + 0.5));
      expect(sheet.width, lessThanOrEqualTo(screen.width + 0.5));
    });

    testWidgets('exactly one language is marked selected at a time',
        (tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      for (final language in LanguageService.supportedLanguages) {
        await tester.tap(find.byKey(const Key('open')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(language.nativeName));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await tester.tap(find.byKey(const Key('open')));
        await tester.pumpAndSettle();
        expect(
          find.byIcon(Icons.check_rounded),
          findsOneWidget,
          reason: 'wrong number of selection marks after ${language.code}',
        );
        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pumpAndSettle();
      }
    });
  });
}
