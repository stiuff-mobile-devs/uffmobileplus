import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/firebase_service.dart';
import 'package:uffmobileplus/app/data/services/hive_service.dart';
import 'package:uffmobileplus/app/routes/app_pages.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/translations/app_translations.dart';

import 'package:uffmobileplus/app/data/services/location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocationService().init();
  await FirebaseService.init();
  await HiveService.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: true,

      title: "UFF Mobile Plus",
      initialRoute: Routes.SPLASH,
      defaultTransition: Transition.fade,
      translations: AppTranslation(),
      locale: Get.deviceLocale,
      fallbackLocale: Locale('pt', 'BR'),
      getPages: AppPages.pages,
    ),
  );
}
