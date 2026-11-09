import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';

const String _supportEmail = 'atendimento@id.uff.br';

class AuthIduffController extends GetxController {
  late final AuthIduffService _authIduffService;

  final UserDataRepository _userDataRepository = UserDataRepository();

  RxBool isLoading = false.obs;
  late final bool isLogin;
  final int _timeoutSeconds = 5;

  @override
  void onInit() {
    _authIduffService = Get.find<AuthIduffService>();
    isLogin = Get.arguments as bool? ?? false;
    if (isLogin) {
      _login();
    }
    super.onInit();
  }

  void backToLogin() {
    Get.offAndToNamed(Routes.LOGIN);
  }

  Future<void> loginFailed(String message) async {
    isLoading.value = false;

    await AppPopups.alert(
      title: 'erro_login_titulo'.tr,
      type: PopupType.error,
      dismissible: false,
      confirmText: 'ok'.tr,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 16),
          Text(
            'suporte_iduff_copiar_email'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          const _CopyEmailChip(email: _supportEmail),
        ],
      ),
    );

    await _userDataRepository.deleteUserIduffModel();
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> loginSuccessful() async {
    isLoading.value = false;
    await _registerTokenCdc();
    
      Get.offAllNamed(Routes.CHOOSE_PROFILE);
  }

  Future<void> _login() async {
    isLoading.value = true;
    try {
      AuthResult result = await _authIduffService.authenticate(Get.context);

      if (result.success) {
        await loginSuccessful();
      } else {
        await loginFailed(result.message);
      }
    } catch (e) {
      debugPrint('Erro no login IdUFF: $e');
      await loginFailed('erro_desconhecido_login_msg'.tr);
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

  Future<void> _registerTokenCdc() async {
    try {
      UserData user = await _userDataRepository.getUserData() ?? UserData();

      bool isSameMethod = user.lastRegisteredTokenCdcMethod == 'iduff';
      bool isRecent = user.lastRegisteredTokenCdcUpdate != null &&
          DateTime.now()
                  .difference(user.lastRegisteredTokenCdcUpdate as DateTime)
                  .inDays <
              90;

      if (isSameMethod && isRecent) {
        debugPrint(
          "Token CDC já atualizado recentemente (IdUFF). Não é necessário atualizar.",
        );
        return;
      }

      bool isAndroid = Platform.isAndroid;
      String device = isAndroid ? 'android' : 'ios';
      String? tokenDevice = await _getTokenDevice(isAndroid);
      String? iduffAccessToken = await _authIduffService.getAccessToken();

      if (iduffAccessToken != null && tokenDevice != null) {
        bool success = await _userDataRepository.registerTokenCdc(
          iduffAccessToken,
          tokenDevice,
          device,
        );
        if (success) {
          await _userDataRepository.lastRegisteredTokenCdcUpdate(
            DateTime.now(),
            'iduff',
          );
        }
      }
    } catch (e) {
      debugPrint("Erro ao registrar token CDC (IdUFF): $e");
    }
  }

  Future<String?> _getTokenDevice(bool isAndroid) async {
    try {
      if (isAndroid) {
        return await FirebaseMessaging.instance.getToken();
      } else {
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          return await messaging.getAPNSToken();
        }
      }
    } catch (e) {
      debugPrint("Erro ao obter token do dispositivo: $e");
    }
    return null;
  }
}

/// Chip que copia o e-mail do suporte e mostra a confirmação no próprio chip
/// (um snackbar ficaria escondido atrás do diálogo).
class _CopyEmailChip extends StatefulWidget {
  final String email;
  const _CopyEmailChip({required this.email});

  @override
  State<_CopyEmailChip> createState() => _CopyEmailChipState();
}

class _CopyEmailChipState extends State<_CopyEmailChip> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.email));
    if (!mounted) return;
    setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _copy,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _copied ? Icons.check_rounded : Icons.copy_rounded,
                color: _copied ? Colors.greenAccent : Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _copied ? 'email_copiado_area_transferencia'.tr : widget.email,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
