import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class FirebaseOptionsBancoDeIdeias {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD1c2znnXPprwwg6hCfcgJ-YYY9C_qFmjc',
    appId: '1:505074004649:web:c79d70d3765ef4b7d96fb8',
    messagingSenderId: '505074004649',
    projectId: 'banco-de-ideias-17a40',
    authDomain: 'banco-de-ideias-17a40.firebaseapp.com',
    storageBucket: 'banco-de-ideias-17a40.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQ0iGaPjtaiSnREsadgcuZB_Yhl95IDGQ',
    appId: '1:505074004649:android:63abc7f35688f06ed96fb8',
    messagingSenderId: '505074004649',
    projectId: 'banco-de-ideias-17a40',
    storageBucket: 'banco-de-ideias-17a40.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBvUWDgdoBd6jUBnqqgygVcVyBp190B7O4',
    appId: '1:505074004649:ios:a58f048c4c8db9c5d96fb8',
    messagingSenderId: '505074004649',
    projectId: 'banco-de-ideias-17a40',
    storageBucket: 'banco-de-ideias-17a40.firebasestorage.app',
    androidClientId:
        '505074004649-6ef8e9at3gg66ia8dtjer1agee9m0bsa.apps.googleusercontent.com',
    iosBundleId: 'br.uff.sti.uffmobileplus',
  );
}
