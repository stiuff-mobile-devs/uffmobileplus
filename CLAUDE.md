# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

UFF Mobile Plus — a Flutter app for Universidade Federal Fluminense students/staff (student ID, restaurant/meal payments, library, bus tracking, transcripts, etc.). Dart SDK `^3.9.0`. Uses GetX for routing, state management, and dependency injection; Firebase (Auth, Firestore, Messaging, Remote Config) and Hive for storage.

## Commands

- `flutter pub get` — install dependencies
- `flutter run` — run the app
- `flutter analyze` — static analysis (uses `package:flutter_lints/flutter.yaml`, see `analysis_options.yaml`)
- `flutter test` — run all tests; `flutter test test/google_groups_unique_names_test.dart` for the single existing test
- `dart run build_runner build --delete-conflicting-outputs` — regenerate Hive `*.g.dart` adapters after changing any `@HiveType` model (hive_generator/build_runner are declared under `dependencies` in pubspec.yaml, not `dev_dependencies` — unusual placement, but the codegen works the same way)
- `dart run flutter_launcher_icons` — regenerate app icons (config lives in the `flutter_icons:` section of `pubspec.yaml`)

No CI is configured (no `.github/workflows`, no Codemagic/Bitrise/fastlane config) — `flutter analyze` and `flutter test` are the only automated checks available locally.

## Architecture

### Module layout
Code lives under `lib/app/modules/{internal_modules,external_modules}/<module_name>/`. Internal modules: `login`, `user`, `dashboard`, `choose_profile`, `splash`, `web_view`, `bibliotecas_web_view`, `lock_develop_mode`. External modules (one per app feature, e.g. `restaurante`, `busuff`, `carteirinha_digital`, `study_plan`, `transcript`, `sos`, `cdc`, `monitora_uff`, `radio`, `ead`, `international`, `repositorio_institucional`, `banco_de_ideias`, `central_de_atendimento`, `papers`, `uniteve`). Larger modules nest sub-modules, e.g. `restaurante/` contains `cardapio`, `catraca`, `pay_restaurant`, `balance_statement`, `recharge_card`.

The intended per-module layering (documented in README.md) is:
`Provider` (raw I/O: HTTP/Firebase/Hive) → `Repository` (wraps Providers, returns models) → `Service` (business rules) → `Controller` (GetxController, orchestrates for UI) → `ui/` (Page/widgets), wired together by a `<module>_binding.dart` using `Get.lazyPut` in that same bottom-up order.

**This is only partially real** — treat it as a target, not a guarantee, when reading or extending a module:
- `user` module implements the full chain, but its controller (`user_data_controller.dart`) calls its Repository directly, skipping Service.
- `carteirinha_digital` has no Provider/Repository/Service of its own at all; its controller calls the shared cross-module `ExternalModulesServices` (`lib/app/data/services/external_modules_services.dart`) and `ScreenProtectorService` directly.
- `login` mixes patterns across its `modules/google` and `modules/iduff` sub-modules — each has its own bindings/controller/services but no Provider/Repository, calling APIs straight from the service.

When adding to an existing module, match that module's existing pattern rather than the README's idealized one; when creating a new module, follow the full Provider→Repository→Service→Controller chain.

### Shared/general layer (`lib/app/data/`)
- `connections/` — external API clients: `google_service.dart`, `saci_service.dart`, `sctm_service.dart`, `umm_service.dart`
- `data_bases/` — `firebase_service.dart`, `hive_service.dart` (both initialized in `lib/main.dart`)
- `services/` — cross-module services: `external_modules_services.dart` (shared user/session data), `device_service.dart`, `deep_link_service.dart`, `foreground_service.dart`, `screen_protector_service.dart`, `update_version_service.dart`, `app_availability_service.dart`, `responsive_layout_service.dart`, `um_infos_service.dart`, `leitor_qr_code.dart`

`lib/app/utils/` holds general-purpose utilities shared app-wide. Convention (per README): a module's own `utils/` may reference anything in its module, but `lib/app/utils/` may only import other general utils or external packages — keep it free of module-specific imports.

### Routing
`lib/app/routes/app_pages.dart` defines `AppPages.pages`, a `GetPage` list pairing each route with its page widget and binding(s). `lib/app/routes/app_routes.dart` defines route name constants (`abstract class Routes`). Standard GetX navigation (`Get.toNamed`, etc.) throughout.

### Dependency injection
GetX bindings (`Get.lazyPut` in each `<module>_binding.dart`, resolved via `Get.find()`) are the **sole** DI mechanism, used consistently across all modules. `get_it` is listed in `pubspec.yaml` but is unused anywhere in `lib/` — don't introduce `GetIt` for new code, stick to GetX bindings for consistency.

### Internationalization
Added on this branch (`lib/app/utils/translations/`). Custom GetX-native i18n, **not** Flutter's `.arb`/`gen-l10n` tooling:
- `app_translations.dart` — `AppTranslation extends Translations`, maps locale codes to per-language dictionaries
- One file per locale: `pt_BR/`, `en_US/`, `es_ES/`, `fr_FR/`, `it_IT/`, `de_DE/`, each holding a `Map<String, String>` of translation keys
- `language_service.dart` — `LanguageService`/`AppLanguage`: persists the chosen locale via `shared_preferences`, resolves the initial locale, and calls `Get.updateLocale()` on change
- Wired in `lib/main.dart` via `GetMaterialApp(translations: AppTranslation(), locale: <initial>, fallbackLocale: pt_BR)`

To add a new translated string, add the key to every per-locale map file, not just one.

### App bootstrap (`lib/main.dart`)
Order matters: `WidgetsFlutterBinding.ensureInitialized()` → `RiveNative.init()` → `FirebaseService.init()` → `HiveService.init()` → lock portrait orientation → `DeepLinkService().init()` → `LanguageService.getInitialLocale()` → `runApp(GetMaterialApp(initialRoute: Routes.SPLASH, getPages: AppPages.pages, ...))`.

### Platform/environment notes
- Single Firebase project, single build flavor on both Android (`br.uff.uffmobileplus`) and iOS — no dev/prod flavor split.
- Hive models use `@HiveType(typeId: ...)` + `part '<name>.g.dart'` (e.g. under `user`, `study_plan`, `transcript`, `restaurante/catraca`) — regenerate with the build_runner command above after editing any of these.

### Naming convention
Folders and files use `snake_case` throughout (per README.md).
