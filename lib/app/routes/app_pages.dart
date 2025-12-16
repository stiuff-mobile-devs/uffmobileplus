import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/carteirinha_digital/binding/carteirinha_digital_bindings.dart';
import 'package:uffmobileplus/app/modules/external_modules/carteirinha_digital/ui/carteirinha_digital_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/bindings/restaurante_bindings.dart';
import 'package:uffmobileplus/app/modules/external_modules/papers/bindings/papers_bindings.dart';
import 'package:uffmobileplus/app/modules/external_modules/papers/ui/papers_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/bindings/balance_statement_bindings.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/ui/balance_statement_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/bindings/pay_restaurant_bindings.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/ui/pages/pay_help_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/ui/pages/pay_ticket_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/ui/pay_restaurant_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/recharge_card/bindings/recharge_card_bindings.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/recharge_card/ui/pages/recharge_card_pay.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/recharge_card/ui/recharge_card_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/binding/transcript_bindings.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/ui/transcript_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/radio/bindings/radio_bindings.dart';
import 'package:uffmobileplus/app/modules/external_modules/radio/ui/radio_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/bindings/catraca_online_bindings.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/ui/catraca_online_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/ui/pages/resultado_detalhado_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/ui/pages/resultado_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/ui/pages/validar_manualmente_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/ui/pages/validar_pagamento_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/utils/leitor_qr_code.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/bindings/menu_bindings.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/ui/pages/restaurants_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/ui/restaurant_modules_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/uniteve/bindings/uniteve_bindings.dart';
import 'package:uffmobileplus/app/modules/external_modules/uniteve/ui/uniteve_contato_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/uniteve/ui/uniteve_historia_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/uniteve/ui/uniteve_page.dart';
import 'package:uffmobileplus/app/modules/internal_modules/choose_profile/bindings/choose_profile_bindings.dart';
import 'package:uffmobileplus/app/modules/internal_modules/choose_profile/ui/choose_profile_page.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/bindings/dashboard_binding.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/pages/settings/about_page.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/pages/settings/settings_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/binding/study_plan_bindings.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/ui/study_plan_page.dart';
import 'package:uffmobileplus/app/modules/internal_modules/lock_develop_mode/bindings/lock_develop_mode_binding.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/binding/login_bindings.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/bindings/auth_google_bindings.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/bindings/auth_iduff_bindings.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/ui/auth_iduff_page.dart';
import 'package:uffmobileplus/app/modules/internal_modules/splash/bindings/splash_bindings.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/bindings/user_data_bindings.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/bindings/user_iduff_bindings.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/bindings/user_umm_bindings.dart';
import 'package:uffmobileplus/app/modules/internal_modules/web_view/bindings/webview_bindings.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/bindings/monitora_uff_bindings.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/ui/monitora_uff_page.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/dashboard.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/ui/login_page.dart';
import 'package:uffmobileplus/app/modules/internal_modules/splash/ui/splash_page.dart';
import 'package:uffmobileplus/app/modules/internal_modules/lock_develop_mode/ui/lock_develop_mode_page.dart';
import 'package:uffmobileplus/app/modules/internal_modules/web_view/ui/webview_page.dart';

abstract class AppPages {
  static final pages = [
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashPage(),
      bindings: [
        SplashBindings(),
        LockDevelopModeBinding(),
        AuthIduffBindings(),
        UserIduffBindings(),
        UserUmmBindings(),
        AuthGoogleBindings(),
        UserDataBindings(),
      ],
    ),

    GetPage(
      name: Routes.YOU_SHALL_NOT_PASS,
      page: () => LockDevelopModePage(),
      binding: LockDevelopModeBinding(),
    ),

    GetPage(
      name: Routes.LOGIN,
      page: () => LoginPage(),
      bindings: [LoginBindings(), AuthGoogleBindings()],
    ),

    GetPage(
      name: Routes.AUTH,
      page: () => AuthIduffPage(),
      bindings: [AuthIduffBindings(), UserUmmBindings(), UserIduffBindings()],
    ),

    GetPage(
      name: Routes.WEB_VIEW,
      page: () => WebViewPage(),
      binding: WebViewBindings(),
    ),

    GetPage(
      name: Routes.HOME,
      page: () => Dashboard(),
      bindings: [DashboardBinding(), UserIduffBindings()],
    ),

    //Restaurante
    GetPage(
      name: Routes.RESTAURANT_MODULES,
      page: () => RestaurantModulesPage(),
      bindings: [RestauranteBindings()],
    ),

    GetPage(
      name: Routes.CATRACA_ONLINE,
      page: () => CatracaOnlinePage(),
      bindings: [CatracaOnlineBindings()],
    ),

    GetPage(
      name: Routes.VALIDAR_PAGAMENTO,
      page: () => ValidarPagamentoPage(),
      bindings: [CatracaOnlineBindings()],
    ),

    GetPage(
      name: Routes.RESULTADO_PAGE,
      page: () => ResultadoPage(),
      bindings: [CatracaOnlineBindings()],
    ),

    GetPage(
      name: Routes.LEITOR_QRCODE,
      page: () => LeitorQrCodePage(),
      bindings: [CatracaOnlineBindings()],
    ),

    GetPage(
      name: Routes.RESULTADO_DETALHADO_PAGE,
      page: () => ResultadoDetalhadoPage(),
      bindings: [CatracaOnlineBindings()],
    ),

    GetPage(
      name: Routes.VALIDAR_MANUALMENTE,
      page: () => ValidarManualmentePage(),
      bindings: [CatracaOnlineBindings()],
    ),

    GetPage(
      name: Routes.BANDEJAPP,
      page: () => RestaurantsPage(),
      bindings: [MenuBindings()],
    ),

    // Pay Restaurant
    GetPage(
      name: Routes.PAY_RESTAURANT,
      page: () => PayRestaurantPage(),
      bindings: [
        UserDataBindings(),
        AuthIduffBindings(),
        PayRestaurantBindings(),
      ],
    ),

    GetPage(
      name: Routes.PAY_RESTAURANT_HELP,
      page: () => PayHelpPage(),
      bindings: [PayRestaurantBindings()],
    ),

    GetPage(
      name: Routes.PAY_RESTAURANT_TICKET,
      page: () => PayTicketPage(),
      bindings: [PayRestaurantBindings()],
    ),

    GetPage(
      name: Routes.RECHARGE_CARD,
      page: () => RechargeCardPage(),
      bindings: [
        UserDataBindings(),
        AuthIduffBindings(),
        RechargeCardBindings(),
      ],
    ),

    GetPage(
      name: Routes.RECHARGE_CARD_PAY,
      page: () => RechargeCardPay(),
      bindings: [RechargeCardBindings()],
    ),

    GetPage(
      name: Routes.BALANCE_STATEMENT,
      page: () => BalanceStatementPage(),
      bindings: [UserDataBindings(),
        AuthIduffBindings(),BalanceStatementBindings()],
    ),

    GetPage(name: Routes.SETTINGS, page: () => SettingsPage()),

    GetPage(name: Routes.ABOUT, page: () => AboutPage()),

    //Carteirinha Digital - Externa
    GetPage(
      name: Routes.CARTEIRINHA_DIGITAL,
      page: () => CarteirinhaDigitalPage(),
      bindings: [
        AuthIduffBindings(),
        UserUmmBindings(),
        UserIduffBindings(),
        CarteirinhaDigitalBindings(),
        UserDataBindings(),
      ],
    ),
    // Plano de Estudos - Externo
    GetPage(
      name: Routes.STUDY_PLAN,
      page: () => StudyPlanPage(),
      bindings: [StudyPlanBindings()],
    ),

    // Radio
    GetPage(
      name: Routes.RADIO,
      page: () => Radio(), // TODO: trocar nome para RadioPage
      bindings: [RadioBindings()],
    ),

    GetPage(
      name: Routes.HISTORICO,
      page: () => TranscriptPage(),
      bindings: [TranscriptBindings()],
    ),

    GetPage(
      name: Routes.CHOOSE_PROFILE,
      page: () => ChooseProfilePage(),
      bindings: [
        UserIduffBindings(),
        ChooseProfileBindings(),
        UserUmmBindings(),
      ],
    ),

    GetPage(
      name: Routes.UNITEVE,
      page: () => UnitevePage(),
      bindings: [UniteveBindings()],
    ),
    GetPage(
      name: Routes.UNITEVE_HISTORIA,
      page: () => UniteveHistoriaPage(),
      bindings: [UniteveBindings()],
    ),
    GetPage(
      name: Routes.UNITEVE_CONTATO,
      page: () => UniteveContatoPage(),
      bindings: [UniteveBindings()],
    ),

    GetPage(
      name: Routes.PAPERS,
      page: () => PapersPage(),
      bindings: [PeriodicosBindings()],
    ),

    GetPage(
      name: Routes.MONITORA_UFF,
      page: () => MonitoraUffPage(),
      bindings: [MonitoraUffBindings()],
    ),
  ];
}
