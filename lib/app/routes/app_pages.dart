import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/carteirinha_digital/binding/carteirinha_digital_bindings.dart';
import 'package:uffmobileplus/app/modules/external_modules/carteirinha_digital/ui/carteirinha_digital_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/radio/bindings/radio_bindings.dart';
import 'package:uffmobileplus/app/modules/external_modules/radio/ui/radio_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/online_turnstile/ui/online_turnstile_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/ui/restaurant_modules_page.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/bindings/home_page_binding.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/pages/about_page.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/pages/settings_page.dart';
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
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/home_page.dart';
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
      bindings: [LoginBindings(), AuthGoogleBindings(), UserDataBindings(),
],
    ),

    GetPage(
      name: Routes.AUTH,
      page: () => AuthIduffPage(),
      bindings: [AuthIduffBindings(), UserUmmBindings(), UserIduffBindings(), UserDataBindings(),
],
    ),

    GetPage(
      name: Routes.WEB_VIEW,
      page: () => WebViewPage(),
      binding: WebViewBindings(),
    ),

    GetPage(
      name: Routes.HOME,
      page: () => HomePage(),
      bindings: [HomePageBinding(), UserIduffBindings()],
    ),

    //Restaurante
    GetPage(
      name: Routes.RESTAURANT_MODULES,
      page: () => RestaurantModulesPage(),
    ),

    GetPage(
      name: Routes.ONLINE_TURNSTILE, 
      page: () => OnlineTurnstilePage()
    ),

    GetPage(
      name: Routes.SETTINGS,
      page: () => SettingsPage()
    ),

    GetPage(
      name: Routes.ABOUT,
      page: () => AboutPage()
    ),

    //Carteirinha Digital - Externa
    GetPage(
      name: Routes.CARTEIRINHA_DIGITAL,
      page: () => CarteirinhaDigitalPage(),
      bindings: [AuthIduffBindings(), UserUmmBindings(), UserIduffBindings(), CarteirinhaDigitalBindings(), UserDataBindings()],
    ),

    // Radio
    GetPage(
      name: Routes.RADIO,
      page:() => Radio(),
      bindings: [
        RadioBindings()
      ]
    ),
  ];
}
