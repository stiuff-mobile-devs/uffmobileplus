import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uffmobileplus/app/config/secrets.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_google_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_google_repository.dart';

class AuthGoogleService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  late final Future<void> _init = _googleSignIn.initialize(
    serverClientId: Secrets.googleServerClientId,
  );
  final UserGoogleRepository _userRepository = UserGoogleRepository();

  final FirebaseApp _uffMobileapp = Firebase.app('uffmobileplus');
  late final fb.FirebaseAuth _uffMobileAuth = fb.FirebaseAuth.instanceFor(
    app: _uffMobileapp,
  );

  final FirebaseApp _harpiaApp = Firebase.app('harpia');
  late final fb.FirebaseAuth _harpiaAuth = fb.FirebaseAuth.instanceFor(
    app: _harpiaApp,
  );

  AuthGoogleService();

  Future<UserGoogleModel?> signInGoogle() async {
    try {
      await _init;
      var account = await _googleSignIn.authenticate();
      return _signIn(account);
    } catch (e) {
      debugPrint('Error initializing GoogleSignIn: $e');
      return null;
    }
  }

  Future<UserGoogleModel?> _signIn(GoogleSignInAccount account) async {
    try {
      final GoogleSignInAuthentication googleAuth = account.authentication;
      final authCredential = fb.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      var userCredential = await _uffMobileAuth.signInWithCredential(
        authCredential,
      );
      //Loga nos outros firebaes
      try {
        var userCredentialHarpia = await _harpiaAuth.signInWithCredential(
          authCredential,
        );
        debugPrint(
          'Logado com sucesso no Firebase Harpia: ${userCredentialHarpia.user?.uid}',
        );
      } catch (e) {
        debugPrint('Error logging into other Firebase apps: $e');
      }

      return await _createUserDoc(userCredential);
    } catch (e) {
      debugPrint('Error during Google sign-in: $e');
      return null;
    }
  }

  Future<UserGoogleModel?> _createUserDoc(
    fb.UserCredential userCredential,
  ) async {
    try {
      final userDoc = await _userRepository.createUserDoc(
        userCredential.user!.email ?? '',
        userCredential.user!.displayName ?? '',
        userCredential.user!.uid,
        userCredential.user!.photoURL ?? '',
      );

      return userDoc;
    } catch (err) {
      debugPrint(err.toString());
      return null;
    }
  }

  Future<UserGoogleModel?> trySignInGoogle() async {
    try {
      final Future<GoogleSignInAccount?>? account = _googleSignIn
          .attemptLightweightAuthentication();
      if (account == null) {
        return null;
      }
      final googleUser = await account;
      return googleUser != null ? await _signIn(googleUser) : null;
    } catch (e) {
      debugPrint('Error initializing GoogleSignIn: $e');
      return null;
    }
  }

  Future<void> logoutGoogle() async {
    await _googleSignIn.signOut();
    await _uffMobileAuth.signOut();
    await _harpiaAuth.signOut();
  }

  Future<String?> getFirebaseIdToken() async {
    // Pega o usuário logado atualmente no Firebase
    final user = _uffMobileAuth.currentUser;

    if (user != null) {
      // getIdToken(true) força a atualização do token caso ele esteja expirado
      return await user.getIdToken(true);
    }
    return null;
  }
}
