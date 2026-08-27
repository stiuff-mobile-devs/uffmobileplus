import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart' as rive;
import 'package:uffmobileplus/app/data/data_bases/firebase_service.dart';
import 'package:uffmobileplus/app/data/data_bases/hive_service.dart';
import 'package:uffmobileplus/app/data/services/deep_link_service.dart';
import 'package:uffmobileplus/app/routes/app_pages.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/translations/app_translations.dart';
import 'package:uffmobileplus/app/utils/translations/language_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await rive.RiveNative.init();

  await FirebaseService.init();
  await HiveService.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Inicializa Deep Linking (App Links e Universal Links)
  await DeepLinkService().init();

  // Carrega idioma salvo ou padrão do dispositivo
  final initialLocale = await LanguageService.getInitialLocale();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: true,
      title: "UFF Mobile Plus",
      initialRoute: Routes.SPLASH,
      defaultTransition: Transition.fade,
      translations: AppTranslation(),
      locale: initialLocale,
      fallbackLocale: const Locale('pt', 'BR'),
      getPages: AppPages.pages,
    ),
  );
}
