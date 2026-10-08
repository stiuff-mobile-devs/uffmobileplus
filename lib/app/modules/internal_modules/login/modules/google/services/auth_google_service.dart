import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uffmobileplus/app/config/secrets.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';

class AuthGoogleService {
  static GoogleSignInAccount? currentAccount;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  late final Future<void> _init = _googleSignIn.initialize(
    serverClientId: Secrets.googleServerClientId,
  );
  final UserDataRepository _userDataRepository = UserDataRepository();

  final FirebaseApp _uffMobileapp = Firebase.app('uffmobileplus');
  late final fb.FirebaseAuth _uffMobileAuth = fb.FirebaseAuth.instanceFor(
    app: _uffMobileapp,
  );

  final FirebaseApp _harpiaApp = Firebase.app('harpia');
  late final fb.FirebaseAuth _harpiaAuth = fb.FirebaseAuth.instanceFor(
    app: _harpiaApp,
  );

  final FirebaseApp _catracaApp = Firebase.app('catraca');
  late final fb.FirebaseAuth _catracaAuth = fb.FirebaseAuth.instanceFor(
    app: _catracaApp,
  );

  final FirebaseApp _cardapioApp = Firebase.app('cardapio');
  late final fb.FirebaseAuth _cardapioAuth = fb.FirebaseAuth.instanceFor(
    app: _cardapioApp,
  );

  final FirebaseApp _bancoDeIdeiasApp = Firebase.app('banco_de_ideias');
  late final fb.FirebaseAuth _bancoDeIdeiasAuth = fb.FirebaseAuth.instanceFor(
    app: _bancoDeIdeiasApp,
  );

  AuthGoogleService();

  Future<UserGoogleModel?> signInGoogle() async {
    try {
      await _init;

      var account = await _googleSignIn.authenticate(
          scopeHint: ['https://www.googleapis.com/auth/drive.file']
      );
      
      if (account != null) {
        currentAccount = account;
        await account.authorizationClient.authorizeScopes([
          'https://www.googleapis.com/auth/drive.file',
        ]);
      }

      return await _signIn(account);
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

      try{
         var userCredentialHarpia = await _harpiaAuth.signInWithCredential(
          authCredential,
        );
        debugPrint(
          'Logado com sucesso no Firebase Harpia: ${userCredentialHarpia.user?.uid}',
        );
      }
      catch(e){
        debugPrint('Error logging into other Harpia Firebase app: $e');
      }

      try {
        var userCredentialBancoDeIdeias = await _bancoDeIdeiasAuth.signInWithCredential(
          authCredential,
        );
        debugPrint(
          'Logado com sucesso no Firebase Banco de Ideias: ${userCredentialBancoDeIdeias.user?.uid}',
        );
      } catch (e) {
        debugPrint('Error logging into Banco de Ideias Firebase apps: $e');
      }

      try {
        var userCredentialCatraca = await _catracaAuth.signInWithCredential(
          authCredential,
        );
        debugPrint(
          'Logado com sucesso no Firebase Catraca: ${userCredentialCatraca.user?.uid}',
        );
      } catch (e) {
        debugPrint('Error logging into Catraca Firebase apps: $e');
      }

      try {
        var userCredentialCardapio = await _cardapioAuth.signInWithCredential(
          authCredential,
        );
        debugPrint(
          'Logado com sucesso no Firebase Cardapio: ${userCredentialCardapio.user?.uid}',
        );
      } catch (e) {
        debugPrint('Error logging into cardapio Firebase apps: $e');
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
      final userDoc = await _userDataRepository.createUserDoc(
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
      await _init;

     
      final googleUser = await _googleSignIn.attemptLightweightAuthentication(); 

      if (googleUser == null) {
        debugPrint("Nenhum usuário encontrado durante login silencioso.");
        throw Exception("Nenhum usuário logado anteriormente");
      } 
        
      debugPrint("Usuário encontrado durante login silencioso: ${googleUser.email}");
      return await _signIn(googleUser);
      
    } catch (e) {
      debugPrint('Error initializing GoogleSignIn: $e');
      throw Exception("Erro ao tentar fazer login silenciosamente: $e");
    }
  }

  Future<void> logoutGoogle() async {
    await _googleSignIn.signOut();
    await _uffMobileAuth.signOut();
    await _harpiaAuth.signOut();
    await _catracaAuth.signOut();
    await _cardapioAuth.signOut();
    await _bancoDeIdeiasAuth.signOut();
    debugPrint('✅ User logged out from all Firebase apps');
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

  Future<GoogleSignInAccount?> getDriveAccount() async {
    await _init; 
    
    if (currentAccount != null) {
      return currentAccount;
    }

    final accountFuture = _googleSignIn.attemptLightweightAuthentication();
    if (accountFuture != null) {
      final account = await accountFuture;
      if (account != null) {
        currentAccount = account;
        return account;
      }
    }
    
    try {
      final account = await _googleSignIn.authenticate(
        scopeHint: ['https://www.googleapis.com/auth/drive.file']
      );
      if (account != null) {
        currentAccount = account;
      }
      return account;
    } catch (e) {
      debugPrint('AuthGoogleService: Falha na autenticação interativa - $e');
      return null;
    }
  }
}
