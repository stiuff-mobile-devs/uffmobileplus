import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/hive_service.dart';
import 'package:uffmobileplus/app/routes/app_pages.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/translations.dart';
import 'package:uffmobileplus/firebase_options_catracaoffline.dart';
import 'package:uffmobileplus/firebase_options_cardapio_ru.dart';
import 'package:uffmobileplus/firebase_options_uffmobileplus.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'uffmobileplus',
    options: FirebaseOptionsUffmobileplus.currentPlatform,
  );
  await Firebase.initializeApp(
    name: 'catracaoffline',
    options: FirebaseOptionsCatracaoffline.currentPlatform,
  );
  await Firebase.initializeApp(
    name: 'cardapio_ru',
    options: FirebaseOptionsCardapioRU.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await HiveService.init();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: true,

      title: "UFF Mobile Plus",
      initialRoute: Routes.SPLASH,
      defaultTransition: Transition.fade,
      translations: International(),
      locale: Get.deviceLocale,
      fallbackLocale: Locale('pt', 'BR'),
      getPages: AppPages.pages,
    ),
  );
}

/*git branch
   85  git branch -a
   86  git switch testing 
   87  git branch
   88  git pull
   89  git switch -C feat/icones-radio-pop
   90  git branch
   91  git status
   92  git push
   93  git push --set-upstream origin feat/icones-radio-pop
*/
