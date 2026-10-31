import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/services/auth_google_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseAuth? appFirebaseAuth,
    AuthGoogleService? googleAuthService,
  }) : _firebaseAuth =
           firebaseAuth ??
           FirebaseAuth.instanceFor(app: Firebase.app('banco_de_ideias')),
       _appFirebaseAuth =
           appFirebaseAuth ??
           FirebaseAuth.instanceFor(app: Firebase.app('uffmobileplus')),
       _googleAuthService = googleAuthService;

  final FirebaseAuth _firebaseAuth;
  final FirebaseAuth _appFirebaseAuth;
  AuthGoogleService? _googleAuthService;
  late final Stream<User?> _authStateChanges = _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> authStateChanges() => _authStateChanges;

  Future<bool> hasValidGoogleSession(String? email) async {
    final expectedEmail = email?.trim().toLowerCase();
    if (expectedEmail == null || expectedEmail.isEmpty) return false;

    try {
      for (final auth in [_appFirebaseAuth, _firebaseAuth]) {
        final user = auth.currentUser;
        if (user == null ||
            user.isAnonymous ||
            user.email?.trim().toLowerCase() != expectedEmail) {
          return false;
        }
        final token = await user.getIdTokenResult(true);
        if (token.token?.isNotEmpty != true ||
            token.signInProvider != GoogleAuthProvider.PROVIDER_ID) {
          return false;
        }
      }
      return true;
    } on FirebaseAuthException catch (error) {
      if (const {
        'user-disabled',
        'user-not-found',
        'invalid-user-token',
        'user-token-expired',
        'invalid-credential',
      }.contains(error.code)) {
        return false;
      }
      rethrow;
    }
  }

  Future<UserGoogleModel?> signInGoogle() {
    return (_googleAuthService ??= AuthGoogleService()).signInGoogle();
  }

  Future<String?> getAppIdToken() async {
    return _appFirebaseAuth.currentUser?.getIdToken();
  }

  Future<void> signOut() => _firebaseAuth.signOut();
}
