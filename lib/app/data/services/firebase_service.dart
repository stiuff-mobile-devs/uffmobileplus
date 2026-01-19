import 'package:firebase_core/firebase_core.dart';
import 'package:uffmobileplus/firebase_options_cardapio_ru.dart';
import 'package:uffmobileplus/firebase_options_catracaoffline.dart';
import 'package:uffmobileplus/firebase_options_tracking.dart';
import 'package:uffmobileplus/firebase_options_uffmobileplus.dart';

class FirebaseService {
  static Future<void> init() async {
    try {
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
      await Firebase.initializeApp(
        name: 'tracking',
        options: FirebaseOptionsTracking.currentPlatform,
      );
    } catch (e, st) {
      print('Firebase init/register adapters error: $e\n$st');
    }
  }
}
