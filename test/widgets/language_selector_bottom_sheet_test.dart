import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uffmobileplus/app/ui/widgets/language_selector_bottom_sheet.dart';
import 'package:uffmobileplus/app/utils/translations/app_translations.dart';
import 'package:uffmobileplus/app/utils/translations/language_service.dart';

/// UI behaviour of the language picker reachable from Settings and the drawer.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AppTranslation.load();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.locale = const Locale('pt', 'BR');
  });

  tearDown(() {
    Get.locale = null;
    // ignore: invalid_use_of_visible_for_testing_member
    Get.reset();
  });

  /// Pumps an app whose only screen opens the sheet, then opens it.
  Future<void> openSheet(WidgetTester tester, {Size? surface}) async {
    if (surface != null) {
      await tester.binding.setSurfaceSize(surface);
      addTearDown(() => tester.binding.setSurfaceSize(null));
    }
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslation(),
        locale: Get.locale,
        fallbackLocale: const Locale('pt', 'BR'),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => LanguageSelectorBottomSheet.show(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('rendering', () {
    testWidgets('lists every supported language with both names', (tester) async {
      await openSheet(tester);

      for (final language in LanguageService.supportedLanguages) {
        expect(
          find.text(language.nativeName),
          findsOneWidget,
          reason: '${language.code} native name missing from the picker',
        );
        expect(
          find.text(language.name),
          findsOneWidget,
          reason: '${language.code} display name missing from the picker',
        );
      }
    });

    testWidgets('renders one flag per language', (tester) async {
      await openSheet(tester);
      expect(
        find.byType(SvgPicture),
        findsNWidgets(LanguageService.supportedLanguages.length),
      );
    });

    testWidgets('marks exactly the active language as selected', (tester) async {
      Get.locale = const Locale('es', 'ES');
      await openSheet(tester);

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // The check must sit in the Español row, not any other.
      final selectedRow = find.ancestor(
        of: find.byIcon(Icons.check_rounded),
        matching: find.byType(Row),
      );
      expect(
        find.descendant(of: selectedRow.first, matching: find.text('Español')),
        findsOneWidget,
      );
    });

    testWidgets('header title is translated with the active locale',
        (tester) async {
      Get.locale = const Locale('en', 'US');
      await openSheet(tester);
      expect(find.text('ling_descricao'.tr), findsOneWidget);
      expect(
        find.text('ling_descricao'),
        findsNothing,
        reason: 'raw key leaked to the UI — the key is undefined',
      );
    });

    testWidgets('header subtitle is translated, not hardcoded English',
        (tester) async {
      Get.locale = const Locale('pt', 'BR');
      await openSheet(tester);
      expect(
        find.text('select_language'.tr),
        findsOneWidget,
        reason: 'the "select_language" key exists in every locale file but the '
            'subtitle renders a hardcoded English literal',
      );
    });
  });

  group('interaction', () {
    // NOTE: tapping a language row calls `LanguageService.changeLanguage`,
    // which routes through `Get.updateLocale` -> `engine.performReassemble()`.
    // That schedules a warm-up frame outside the test binding's guarded frame
    // loop and corrupts the binding for every later test in the file, so the
    // *switching* behaviour is covered on-device in
    // `integration_test/language_switching_test.dart` instead. What stays here
    // is everything observable without mutating the locale.
    testWidgets('every language row is tappable', (tester) async {
      await openSheet(tester);

      for (final language in LanguageService.supportedLanguages) {
        final row = find.ancestor(
          of: find.text(language.nativeName),
          matching: find.byType(InkWell),
        );
        expect(
          row,
          findsWidgets,
          reason: '${language.code} row has no tap target',
        );
        expect(
          tester.widget<InkWell>(row.first).onTap,
          isNotNull,
          reason: '${language.code} row is not tappable',
        );
      }
    });

    testWidgets('the back button dismisses without changing the locale',
        (tester) async {
      await openSheet(tester);
      expect(find.byType(LanguageSelectorBottomSheet), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSelectorBottomSheet), findsNothing);
      expect(Get.locale, const Locale('pt', 'BR'));
    });

    testWidgets('the selected row tracks Get.locale for every language',
        (tester) async {
      for (final language in LanguageService.supportedLanguages) {
        Get.locale = language.locale;
        await openSheet(tester);

        final selectedRow = find.ancestor(
          of: find.byIcon(Icons.check_rounded),
          matching: find.byType(Row),
        );
        expect(
          find.descendant(
            of: selectedRow.first,
            matching: find.text(language.nativeName),
          ),
          findsOneWidget,
          reason: '${language.code} is active but its row is not marked',
        );

        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pumpAndSettle();
      }
    });
  });

  group('responsiveness', () {
    // Small phone, tall phone, and tablet-ish widths.
    for (final size in const [
      Size(320, 568), // iPhone SE / small Android
      Size(411, 891), // Pixel-class
      Size(800, 1280), // tablet portrait
    ]) {
      testWidgets('renders without overflow at ${size.width}x${size.height}',
          (tester) async {
        await openSheet(tester, surface: size);

        expect(find.byType(LanguageSelectorBottomSheet), findsOneWidget);
        expect(find.text('Português'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
