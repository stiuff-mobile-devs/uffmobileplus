import 'dart:io';

import 'package:get/get.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:safe_device/safe_device.dart';
import 'package:uffmobileplus/app/config/secrets.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

class LockDevelopModeController extends GetxController {
  LockDevelopModeController();

  Future<bool> updateDevMode() async {
    if (!Platform.isAndroid) {
      return false;
    }
    return await SafeDevice.isDevelopmentModeEnable;
  }

  Future<void> refreshPage() async {
    Get.offAllNamed(Routes.SPLASH);
  }

  Future<void> openHelp() async {
    Get.toNamed(
      Routes.WEB_VIEW,
      arguments: {'url': Secrets.helpUrl, 'title': 'modo_desenvolvedor'.tr},
    );
  }

  Future<void> openSettings() async {
    try {
      switch (OpenSettingsPlus.shared) {
        case OpenSettingsPlusAndroid settings:
          await settings.applicationDevelopment();
          break;
        case OpenSettingsPlusIOS settings:
          await settings.general();
          break;
        default:
          throw Exception('Platform not supported');
      }
    } catch (e) {
      try {
        switch (OpenSettingsPlus.shared) {
          case OpenSettingsPlusAndroid settings:
            await settings.appSettings();
            break;
          case OpenSettingsPlusIOS settings:
            await settings.general();
            break;
          default:
            Get.snackbar(
              'erro'.tr,
              'plataforma_nao_suportada'.tr,
              backgroundColor: Get.theme.colorScheme.error,
              colorText: Get.theme.colorScheme.onError,
            );
        }
      } catch (e) {
        Get.snackbar(
          'erro'.tr,
          'nao_foi_possivel_abrir_as_configuracoes'.tr,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    }
  }
}
