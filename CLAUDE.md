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

### Independência dos módulos
Os `external_modules` são independentes: não conversam com os `internal_modules` nem entre si.

| De → Para | Permitido? |
|---|---|
| módulo externo → `lib/app/utils` (kit de UI `AppBars`/`AppPopups`, cores, traduções, helpers) | ✅ |
| módulo externo → `lib/app/data` (serviços compartilhados, ex.: `ExternalModulesServices`, `sctm_service`) | ✅ |
| módulo externo → `internal_modules/...` | ❌ |
| módulo externo → outro `external_modules/...` | ❌ |
| `lib/app/utils` e `lib/app/data` → qualquer módulo | ❌ (a camada compartilhada nunca conhece módulos) |
| `internal_modules/dashboard` → módulos externos | ⚠️ exceção: a dashboard é a vitrine (cards da Home) e pode ler dos externos; nunca o contrário. Prefira navegar por rota (`Get.toNamed`) a importar páginas |

- Usar `AppBars`/`AppPopups` **não** quebra a independência: a dependência é só módulo → kit. Mantenha o kit livre de qualquer import de `modules/` e de modelos de módulos; textos chegam já traduzidos por quem chama.
- A URL de ajuda de telas de um módulo externo fica **dentro do módulo** (ex.: `restaurante/utils/restaurante_help.dart`) e é passada a `AppBars.helpAction(url)`; `HelpGuides` é só para telas internas.
- Dentro de um módulo com submódulos (ex.: `restaurante/modules/*`), compartilhar código é permitido, mas prefira colocar o que é comum no nível do módulo pai.

**Violações conhecidas (dívida, corrigir quando mexer na regra):**
- Restaurante importa `internal_modules/login` (`AuthGoogleService`, instanciado com `new` em pagar/recarga/extrato/catraca) e `internal_modules/user` (`UserData`, `UserDataController` registrado em `cardapio_bindings`).
- `cardapio/ui/pages/restaurants_page.dart` importa `HomePageController` da dashboard (dependência circular com a Home).
- `lib/app/data/connections/sctm_service.dart` e `lib/app/data/data_bases/hive_service.dart` importam modelos de `restaurante` (camada compartilhada conhecendo o módulo).
- DI fora do padrão no Restaurante: `cardapio_bindings` usa `Get.put` (não `lazyPut`); `menu_widget`/`meal_form_widget` e `RestaurantsController` fazem `Get.put` fora de bindings; `RestaurantModulesPage` usa `GetBuilder(init: ...)` duplicando a binding; `recharge_card_controller` cria `ExternalModulesServices()` novo.

### Módulos críticos: Restaurante e Carteirinha Digital
São os módulos mais usados do app. **Antes de alterar qualquer regra de negócio** neles — valores/preço, pagamento, saldo, extrato, recarga, catraca/validação de acesso (online/offline), QR code e validade da carteirinha, permissões por vínculo/grupo GDI — **pare, explique a mudança e espere aprovação explícita**.
- Mudanças só visuais (layout, AppBar, pop-ups, textos) seguem normalmente.
- Mudança de regra de negócio vai em **commit separado** da parte visual, para facilitar a revisão.
- Problemas de regra encontrados no caminho são **listados para o usuário**, não corrigidos por conta própria.

**Catraca (`restaurante/modules/catraca`) é ainda mais sensível:** controla a entrada no RU (validação online/offline, débito, transações salvas no Hive/Firebase). Ela **nunca entra em mudanças em lote** do Restaurante ou do app (migração de AppBar/pop-ups, troca de textos, refatorações, renomear chaves de tradução que ela usa). Só é alterada numa tarefa **dedicada e individual**, pedida explicitamente, com o plano explicado antes e aprovação do usuário — inclusive para mudanças só visuais. Em commit próprio, sem misturar com outros arquivos.

### Routing
`lib/app/routes/app_pages.dart` defines `AppPages.pages`, a `GetPage` list pairing each route with its page widget and binding(s). `lib/app/routes/app_routes.dart` defines route name constants (`abstract class Routes`). Standard GetX navigation (`Get.toNamed`, etc.) throughout.

### Dependency injection
GetX bindings (`Get.lazyPut` in each `<module>_binding.dart`, resolved via `Get.find()`) are the **sole** DI mechanism, used consistently across all modules. `get_it` is listed in `pubspec.yaml` but is unused anywhere in `lib/` — don't introduce `GetIt` for new code, stick to GetX bindings for consistency.

### Internationalization
Custom GetX-native i18n (`lib/app/utils/translations/`), **not** Flutter's `.arb`/`gen-l10n` tooling:
- Translations are flat key→value JSON files, one per locale: `assets/translations/{pt_BR,en_US,es_ES,fr_FR,it_IT,de_DE}.json`
- `app_translations.dart` — `AppTranslation extends Translations`; `AppTranslation.load()` reads every JSON into memory and must be awaited before `runApp`
- `language_service.dart` — `LanguageService`/`AppLanguage`: persists the chosen locale via `shared_preferences`, resolves the initial locale, and calls `Get.updateLocale()` on change
- Wired in `lib/main.dart` via `GetMaterialApp(translations: AppTranslation(), locale: <initial>, fallbackLocale: pt_BR)`
- Usage: `'chave'.tr` / `'chave'.trParams({...})` (placeholders as `@nome`)

To add a new translated string, add the key to **all 6** JSON files, not just one. `test/translations/translation_integrity_test.dart` checks that every locale has the same keys as `pt_BR`, no empty values, no duplicate keys, and that every `.tr` key used in `lib/` exists in `pt_BR.json`. Before checking for a new key, grep `pt_BR.json` — many texts already have a key.

### AppBars (`AppBars`)
Ponto único: `lib/app/utils/ui_components/app_bars.dart`. **Obrigatório nos `internal_modules`** (exceto a tela especial `lock_develop_mode`) e no `restaurante` (já migrado, **exceto a catraca**, que segue com o visual antigo até uma tarefa dedicada); os demais `external_modules` ainda usam `customAppBar`/blocos próprios — migre-os quando for mexer neles.
- Nunca use `AppBar(...)`/`SliverAppBar(...)` direto nas telas: `appBar: AppBars.build(title: ..., actions: [...])`.
- Visual único: degradê vertical `AppColors.mediumBlue()` → `AppColors.darkBlue()`, raio inferior 16, título centralizado, texto/ícones brancos, status bar clara.
- A seta de voltar e o ícone do menu (quando há drawer) são automáticos; passe `leading` só para comportamentos especiais (ex.: WebView volta no histórico). Filtros/abas vão em `bottom`.
- Dê ao `Scaffold` `backgroundColor: AppColors.darkBlue()`, senão os cantos arredondados da AppBar mostram o fundo branco padrão.
- Botão de ajuda: `AppBars.helpAction(url)`. Telas internas usam `HelpGuides.<tela>` (`lib/app/utils/help_guides.dart`); módulos externos guardam a URL no próprio módulo (ver "Independência dos módulos"). Enquanto for `null`, o botão avisa que o manual está em construção.
- Título reativo: `AppBars.build(titleWidget: Obx(() => Text(...)))`.

### Pop-ups e snackbars (`AppPopups`)
Ponto único: `lib/app/utils/ui_components/app_popups.dart`. **Obrigatório nos `internal_modules`** e no `restaurante` (já migrado, **exceto a catraca**); os demais `external_modules` ainda usam o padrão antigo (`Get.snackbar`, `customAlertDialog`/AwesomeDialog etc.) — migre-os para `AppPopups` quando for mexer neles.
- Nunca use `showDialog`, `Get.dialog`, `Get.defaultDialog`, `Get.snackbar`, `Get.bottomSheet`, `showModalBottomSheet`, `ScaffoldMessenger` ou `customAlertDialog` direto nas telas/controllers.
- Mensagem rápida: `AppPopups.success/error/warning/info(texto, title: opcional)` (snackbar flutuante via `ScaffoldMessenger`, não quebra o `Get.back()`).
- Confirmação: `await AppPopups.confirm(...)` → `bool` (bottom sheet; `destructive: true` para desconectar/excluir; `type:` para mudar a cor do ícone).
- Texto: `AppPopups.input(...)`; lista de opções: `AppPopups.choose<T>(...)`; conteúdo livre: `AppPopups.sheet(...)` ou `AppPopups.custom(widget)` com `AppSheet`/`AppSheetButton.primary/secondary` por dentro.
- Aviso centralizado: `AppPopups.alert(...)`; carregamento bloqueante: `AppPopups.showLoading()`/`hideLoading()`.
- Dentro das folhas, feche com `Navigator.of(ctx).pop(valor)` usando o `ctx` da folha, nunca `Get.back()`.
- Visual: sempre o azul-escuro da marca (`AppPopups.theme`), independente do `ThemeData` global (o app não define um).
- Mensagens ao usuário são amigáveis e traduzidas; o detalhe técnico (`$e`) vai só para `debugPrint`, nunca para o pop-up.
- Escrita: **título = o que aconteceu** (ex.: "Não foi possível carregar o cardápio"); **mensagem = o que fazer** (ex.: "Verifique sua internet e tente de novo."). Frases curtas, sem jargão, sem código HTTP.
- Use `withValues(alpha: x)` (não `withOpacity`) e `PopScope` (não `WillPopScope`) em código novo.

### App bootstrap (`lib/main.dart`)
Order matters: `WidgetsFlutterBinding.ensureInitialized()` → `AppTranslation.load()` → `FirebaseService.init()` → `HiveService.init()` → lock portrait orientation → `DeepLinkService().init()` → `LanguageService.getInitialLocale()` → `runApp(GetMaterialApp(initialRoute: Routes.SPLASH, getPages: AppPages.pages, ...))`.

### Platform/environment notes
- Single Firebase project, single build flavor on both Android (`br.uff.uffmobileplus`) and iOS — no dev/prod flavor split.
- Hive models use `@HiveType(typeId: ...)` + `part '<name>.g.dart'` (e.g. under `user`, `study_plan`, `transcript`, `restaurante/catraca`) — regenerate with the build_runner command above after editing any of these.

### Naming convention
Folders and files use `snake_case` throughout (per README.md).

### Convenção de commits
Mensagem em português, curta, minúscula, no formato `tipo: descrição` (seguindo o histórico do repositório):
- `feat:` funcionalidade nova ou melhoria visível — ex.: `feat: padroniza pop-ups e snackbars dos módulos internos com AppPopups`
- `fix:` correção de bug — ex.: `fix: login google somente ao continuar no banco de ideias`
- `beta: x.y.z` para marcar versões beta — ex.: `beta: 7.0.2`

Um commit por mudança coesa; não inclua arquivos gerados em `linux/flutter/ephemeral/` ou `macos/Flutter/ephemeral/`.
