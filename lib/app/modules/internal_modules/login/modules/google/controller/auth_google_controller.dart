import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/services/auth_google_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_google_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

class AuthGoogleController extends GetxController {
  AuthGoogleController();

  late final AuthGoogleService _authGoogle = AuthGoogleService();
  late final UserGoogleRepository _userRepository = UserGoogleRepository();

  @override
  void onInit() {
    super.onInit();
  }

  void loginGoogle() async {
    try {
      final user = await _authGoogle.signInGoogle();

      if (user != null) {
        _userRepository.saveUserGoogleModel(user);
        Get.offNamed(Routes.HOME);
      } else {
        Get.snackbar(
          "Erro de Login",
          "Falha ao autenticar o usuário.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Erro de Login externo",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  tryLogin() async {
    var hasLogged = await _authGoogle.trySignInGoogle();
    if (hasLogged != null) {
      Get.offNamed(Routes.HOME);
    } else {
      Get.offNamed(Routes.LOGIN);
    }
  }

  void logout() {
    _authGoogle.logoutGoogle();
    _userRepository.deleteUserGoogleModel();
    Get.offAllNamed(Routes.LOGIN);
  }
}
