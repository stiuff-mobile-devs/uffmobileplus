import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uffmobileplus/app/ui/widgets/responsive_uff_logo.dart';
import 'package:uffmobileplus/app/utils/translations/app_translations.dart';
import 'package:uffmobileplus/app/utils/translations/language_service.dart';
import 'package:uffmobileplus/main.dart' as app;

/// Cold-boot smoke test for the real `main()` on a device.
///
/// Covers the bootstrap order changed on this branch — `AppTranslation.load()`
/// now runs before `FirebaseService.init()` and `runApp` — and proves the app
/// comes up in the language the user last picked.
///
/// The named Firebase apps in `FirebaseService.init()` cannot be initialised
/// twice in one process, so `app.main()` is invoked exactly once here and every
/// assertion is made against that single boot.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold boot honours the saved language and renders the splash',
      (tester) async {
    // Seed the preference a returning user would already have.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language_code', 'de_DE');

    await app.main();

    // The splash logo animates forever, so pump discrete frames rather than
    // settling (pumpAndSettle would never return).
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    expect(
      tester.takeException(),
      isNull,
      reason: 'the app threw during bootstrap',
    );

    // Bootstrap loaded every dictionary out of the real APK bundle.
    final keys = AppTranslation().keys;
    for (final locale in AppTranslation.supportedLocales) {
      expect(keys[locale], isNotEmpty, reason: '$locale missing after boot');
    }

    // The saved language won over the device locale.
    expect(
      Get.locale,
      const Locale('de', 'DE'),
      reason: 'the persisted language was not applied at startup',
    );
    expect(LanguageService.getCurrentLanguage().code, 'de_DE');

    // Translations actually resolve in the booted app.
    expect('configuracoes'.tr, keys['de_DE']!['configuracoes']);
    expect(
      'configuracoes'.tr,
      isNot('configuracoes'),
      reason: 'raw key returned — the dictionary is not wired into GetX',
    );

    // The splash screen is up and using the new animated logo.
    expect(find.byType(ResponsiveUffLogo), findsWidgets);

    // Keep the app running a while longer: the splash controller routes on
    // from here, and anything that throws during that hand-off should surface.
    // (`integration_test` tears the tree down between tests, so the whole boot
    // lifecycle has to be asserted inside this one test.)
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(
      tester.takeException(),
      isNull,
      reason: 'the app threw while leaving the splash screen',
    );
    expect(
      find.byType(GetMaterialApp),
      findsOneWidget,
      reason: 'the app tree was torn down',
    );
    expect(Get.currentRoute, isNotEmpty, reason: 'no route is active');
    expect(
      Get.locale,
      const Locale('de', 'DE'),
      reason: 'the language was lost while navigating off the splash',
    );
    debugPrint('route after boot: ${Get.currentRoute}');
  });
}
