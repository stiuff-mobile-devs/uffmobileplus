import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_google_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_google_repository.dart';

class AuthGoogleService {
  /* final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final UserGoogleRepository _userRepository = UserGoogleRepository();

  final FirebaseAuth _auth = FirebaseAuth.instanceFor(
    app: Firebase.app('uffmobileplus'),
  );
  AuthGoogleService();

  Future<UserGoogleModel?> signInGoogle() async {
    var account = await _googleSignIn.signIn();
    var b = await account!.authentication;
    final authCredential = GoogleAuthProvider.credential(
      accessToken: b.accessToken,
      idToken: b.idToken,
    );
    try {
      var userCredential = await _auth.signInWithCredential(authCredential);

      return await _userRepository.createUserDoc(
        userCredential.user!.email!,
        userCredential.user!.displayName!,
        userCredential.user!.uid,
        userCredential.user!.photoURL!,
      );
    } catch (err) {
      debugPrint(err.toString());
    }
    return null;
  }

  Future<UserGoogleModel?> trySignInGoogle() async {
    var account = await _googleSignIn.signInSilently();
    if (account == null) {
      return null;
    }
    var b = await account.authentication;
    final authCredential = GoogleAuthProvider.credential(
      accessToken: b.accessToken,
      idToken: b.idToken,
    );
    try {
      var userCredential = await _auth.signInWithCredential(authCredential);
      return await _userRepository.createUserDoc(
        userCredential.user!.email!,
        userCredential.user!.displayName!,
        userCredential.user!.uid,
        userCredential.user!.photoURL!,
      );
    } catch (err) {
      debugPrint(err.toString());
    }
    return null;
  }

  logoutGoogle() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }*/
}
