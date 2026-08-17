import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uffmobileplus/firebase_options_cardapio.dart';
import 'package:uffmobileplus/firebase_options_catraca.dart';
import 'package:uffmobileplus/firebase_options_banco_de_ideias.dart';
import 'package:uffmobileplus/firebase_options_harpia.dart';
import 'package:uffmobileplus/firebase_options_uffmobileplus.dart';

class FirebaseService {
  static Future<void> init() async {
    await Firebase.initializeApp(
      name: 'uffmobileplus',
      options: FirebaseOptionsUffmobileplus.currentPlatform,
    );
    debugPrint('✅ Firebase default app initialized');

    await Firebase.initializeApp(
      name: 'harpia',
      options: FirebaseOptionsHarpia.currentPlatform,
    );
    debugPrint('✅ Firebase harpia app initialized');

    await Firebase.initializeApp(
      name: 'catraca',
      options: FirebaseOptionsCatraca.currentPlatform,
    );
    debugPrint('✅ Firebase catraca app initialized');

    await Firebase.initializeApp(
      name: 'cardapio',
      options: FirebaseOptionsCardapio.currentPlatform,
    );
    debugPrint('✅ Firebase cardapio app initialized');
    await Firebase.initializeApp(
      name: 'banco_de_ideias',
      options: FirebaseOptionsBancoDeIdeias.currentPlatform,
    );
    debugPrint('✅ Firebase Banco de Ideias app initialized');
  }
}
