import 'package:firebase_core/firebase_core.dart';
import 'package:uffmobileplus/firebase_options_cardapio_ru.dart';
import 'package:uffmobileplus/firebase_options_catracaoffline.dart';
import 'package:uffmobileplus/firebase_options_tracking.dart';
import 'package:uffmobileplus/firebase_options_uffmobileplus.dart';

class FirebaseService {
  static Future<void> init() async {
    await Firebase.initializeApp(
      name: 'uffmobileplus',
      options: FirebaseOptionsUffmobileplus.currentPlatform,
    );
    print('✅ Firebase default app initialized');

    await Firebase.initializeApp(
      name: 'catracaoffline',
      options: FirebaseOptionsCatracaoffline.currentPlatform,
    );
    print('✅ Firebase catracaoffline initialized');

    await Firebase.initializeApp(
      name: 'cardapio_ru',
      options: FirebaseOptionsCardapioRU.currentPlatform,
    );
    print('✅ Firebase cardapio_ru initialized');

    await Firebase.initializeApp(
      name: 'tracking',
      options: FirebaseOptionsTracking.currentPlatform,
    );
    print('✅ Firebase tracking initialized');
  }
}
