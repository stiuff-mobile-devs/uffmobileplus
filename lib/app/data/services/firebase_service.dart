import 'package:firebase_core/firebase_core.dart';
import 'package:uffmobileplus/firebase_options_uffmobileplus.dart';

class FirebaseService {
  static Future<void> init() async {
    await Firebase.initializeApp(
      name: 'uffmobileplus',
      options: FirebaseOptionsUffmobileplus.currentPlatform,
    );
    print('✅ Firebase default app initialized');

    
  }
}
