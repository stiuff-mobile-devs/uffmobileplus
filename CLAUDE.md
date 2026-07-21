# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

UFF Mobile Plus (uffmobileplus) is a Flutter app for Universidade Federal Fluminense students/staff,
bundling many independent university services (dining hall payments, digital ID card, bus tracking,
transcripts, library access, radio, SOS, monitoring, etc.) behind a single dashboard. Built with
GetX for navigation, dependency injection, and state management.

## Commands

- Install dependencies: `flutter pub get`
- Run app (device/emulator required): `flutter run`
- Static analysis / lint: `flutter analyze`
- Regenerate Hive adapters / generated models after editing a `@HiveType` class or similar:
  `dart run build_runner build --delete-conflicting-outputs`
- There is no test suite in this repo (no `test/` directory) and no CI configuration.

### Required local setup
`lib/app/config/secrets.dart` is gitignored and **not present in a fresh checkout** — it holds
OAuth2/Keycloak client IDs, URLs, and other credentials referenced by `Secrets.*` (e.g. in
`lib/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart`). The app
will not compile without it; it must be obtained out-of-band and placed at that path.
Firebase config (`lib/firebase_options_*.dart`, `android/app/google-services.json`, etc.) is
similarly required for the three Firebase apps described below.

## Architecture

### Layering (per module)
Each feature is a self-contained module wired together with strict one-way dependencies:

`Provider → Repository → Service → Controller → UI`

- **Provider**: raw I/O (HTTP/Firebase/Hive) — no business logic.
- **Repository**: wraps one or more Providers, centralizes/organizes data access for a module.
- **Service**: business rules, auth, DB logic; can integrate data from other modules.
- **Controller** (`GetxController`): orchestrates a screen's flow, calls Services, exposes
  `.obs` reactive state for the UI.
- **UI**: `StatelessWidget`/`StatefulWidget` pages, read controller state via `Obx`/`Get.find()`.
- **Model**: plain data classes; Hive-persisted models use `@HiveType`/`@HiveField` codegen
  (`*.g.dart`, produced by `build_runner`).
- Module-local `utils/` may reference anything within that module. App-wide `lib/app/utils/`
  may only import other app-wide utils or external packages — never module code — to avoid
  circular/module-coupling.

Not every module implements every layer (e.g. `busuff` has no Repository, `radio`/`sos` skip
straight from binding to controller) — treat the full stack as the ideal, not a hard requirement.

### Module organization
- `lib/app/modules/internal_modules/` — modules core to the app shell itself: `login/` (with
  `google/` and `iduff/` sub-auth-modules), `dashboard/`, `splash/`, `choose_profile/`, `user/`
  (persisted user identity across auth providers), `web_view/`, `lock_develop_mode/`.
- `lib/app/modules/external_modules/` — the individual university services/features (one
  directory per feature: `restaurante/` (itself multi-module: `menu`, `catraca`, `pay_restaurant`,
  `recharge_card`, `balance_statement`), `busuff`, `carteirinha_digital`, `carteirinha_validador`,
  `monitora_uff`, `sos`, `study_plan`, `transcript`, `bibliotecas`, `cdc`, `uniteve`, `radio`,
  `papers`, `ead`, `internacional`, `repositorio_institucional`, `central_de_atendimento`,
  `connections`).
- `lib/app/data/` — cross-module concerns: `data_bases/` (Firebase + Hive bootstrap),
  `connections/` (clients for external UFF backend systems: SACI, SCTM, UMM, Google), `services/`
  (device info, deep links, foreground/background service, screen protection, QR scanning, etc.).
- `lib/app/routes/` — `app_routes.dart` (route name constants) and `app_pages.dart` (the single
  `GetPage` list mapping each route to a page + its `Bindings`).
- `lib/app/utils/` — app-wide shared utilities (color palette, translations, error messages,
  reusable UI components in `ui_components/`).

### GetX bindings & DI
A `Bindings` class registers a module's dependency chain with `Get.lazyPut`/`Get.put`, lowest
layer first (Provider → Repository → Service → Controller); the first `Get.find<T>()` call
triggers construction. Routes commonly attach *multiple* bindings (e.g. a page needing user data
and auth gets `[FeatureBindings(), UserDataBindings(), AuthIduffBindings()]`) since GetX bindings
compose per-route in `app_pages.dart` rather than each module re-declaring shared dependencies.
`UserDataController` and auth services are frequently registered as `permanent: true` since they
must survive across the whole session/navigation stack.

### Multi-tenant Firebase
The app initializes **three separate named Firebase apps** in `FirebaseService.init()`
(`lib/app/data/data_bases/firebase_service.dart`), each with its own options file:
`uffmobileplus` (default), `harpia`, and `catraca`. Code that touches Firebase must be explicit
about which named app it targets — there is no single implicit default beyond `'uffmobileplus'`.

### Authentication
Two independent identity providers, unified under `UserDataController`/`UserDataRepository`:
- **IdUFF (Keycloak/OAuth2)**: `lib/app/modules/internal_modules/login/modules/iduff/` —
  `flutter_appauth`-based authorization-code flow with refresh-token renewal
  (`AuthIduffService.authorize()`/`refreshToken()`), config from `Secrets`.
- **Google**: `lib/app/modules/internal_modules/login/modules/google/` — `google_sign_in`-based.

Auth/session data persists via Hive (`lib/app/modules/internal_modules/user/data/`), with
adapters centrally registered in `HiveService.init()`.

### Local persistence
Hive is the local datastore; every `@HiveType` model's `TypeAdapter` must be registered in
`lib/app/data/data_bases/hive_service.dart` (`HiveService.init()`) — adding a new persisted
model requires both generating its adapter (`build_runner`) and registering it there, or it will
silently fail to serialize.

## Conventions
- Files/folders: `snake_case`.
- Route names live only in `Routes` (`lib/app/routes/app_routes.dart`); navigate with
  `Get.toNamed(Routes.X, arguments: ...)`, never hardcoded path strings.
- Primary language in code comments, strings, and UI copy is Portuguese (pt_BR); translations
  also exist for en_US and it_IT in `lib/app/utils/translations/`.
