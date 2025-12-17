import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/data/services/hive_service.dart';
import 'package:uffmobileplus/app/routes/app_pages.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/translations/app_translations.dart';
import 'package:uffmobileplus/firebase_options_catracaoffline.dart';
import 'package:uffmobileplus/firebase_options_cardapio_ru.dart';
import 'package:uffmobileplus/firebase_options_uffmobileplus.dart';
import 'package:uffmobileplus/firebase_options_tracking.dart';

import 'package:uffmobileplus/app/data/services/location_service.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocationService().initializeService();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        name: 'uffmobileplus',
        options: FirebaseOptionsUffmobileplus.currentPlatform,
      );
    } else {
        // If default app exists, we might want to use it or check if others are initialized?
        // But here we are initializing named apps.
        // Let's just wrap each in try-catch independently.
        await Firebase.initializeApp(
            name: 'uffmobileplus',
            options: FirebaseOptionsUffmobileplus.currentPlatform,
        );
    }
  } catch (e) {
      print("Error initializing uffmobileplus: $e");
  }

  try {
    await Firebase.initializeApp(
        name: 'catracaoffline',
        options: FirebaseOptionsCatracaoffline.currentPlatform,
    );
  } catch (e) {
      print("Error initializing catracaoffline: $e");
  }

  try {
    await Firebase.initializeApp(
        name: 'cardapio_ru',
        options: FirebaseOptionsCardapioRU.currentPlatform,
    );
  } catch (e) {
      print("Error initializing cardapio_ru: $e");
  }

  try {
    await Firebase.initializeApp(
        name: 'tracking',
        options: FirebaseOptionsTracking.currentPlatform,
    );
  } catch (e) {
      print("Error initializing tracking: $e");
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await HiveService.init();


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
