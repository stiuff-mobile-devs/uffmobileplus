import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_iduff_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_umm_controller.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';

class AuthIduffController extends GetxController {
  final AuthIduffService _authIduffService = Get.find<AuthIduffService>();

  late final UserUmmController _userUmmController;
  late final UserDataController _userDataController;
  late final UserIduffController _userIduffController;
  RxBool isLoading = false.obs;
  late final bool isLogin;
  final int _timeoutSeconds = 5;

  @override
  void onInit() {
    _userUmmController = Get.find<UserUmmController>();
    _userDataController = Get.find<UserDataController>();
    _userIduffController = Get.find<UserIduffController>();
    isLogin = Get.arguments as bool? ?? false;
    if (isLogin) {
      login();
    }
    super.onInit();
  }

  backToLogin() {
    Get.offAndToNamed(Routes.LOGIN);
  }

  loginFailed(String message) {
    isLoading.value = false;
    const email = 'atendimento@id.uff.br';

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.darkBlueToBlackGradient(),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: const [
                      Icon(
                        CupertinoIcons.exclamationmark_circle,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white70, fontSize: 30),
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(const ClipboardData(text: email));
                      Get.snackbar(
                        'Copiado',
                        'E-mail copiado para a área de transferência',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.black.withOpacity(0.75),
                        colorText: Colors.white,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            CupertinoIcons.mail_solid,
                            color: Colors.white70,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'atendimento@id.uff.br',
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 8),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white24,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          _userIduffController.deleteUserIduffModel();
                          Get.offAllNamed(Routes.LOGIN);
                        },
                        child: const Text(
                          'OK',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  loginSuccessful() async {
    String? iduff = await _userIduffController.getIduff();
    isLoading.value = false;
    Get.offAllNamed(Routes.CHOOSE_PROFILE, arguments: iduff);
  }

  login() async {
    isLoading.value = true;
    try {
      final result = await _authIduffService.authenticate(Get.context);

      if (result.success) {
        await loginSuccessful();
      } else {
        await loginFailed(result.message);
      }
    } catch (e) {
      await loginFailed(
        "Erro desconhecido. Tente novamente mais tarde. Se o problema persistir, entre em contato com o suporte:",
      );
    }
  }

  Future<bool> tryLogin() async {
    return await _authIduffService.tryLogin().timeout(
      Duration(seconds: _timeoutSeconds),
      onTimeout: () {
        return false;
      },
    );
  }
}
