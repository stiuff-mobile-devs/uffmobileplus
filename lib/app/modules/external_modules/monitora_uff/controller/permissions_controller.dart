import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class PermissionsController extends GetxController with WidgetsBindingObserver {
  final hasWhenInUseLocationPermission = false.obs;
  final hasAlwaysLocationPermission = false.obs;
  final hasNotificationPermission = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    hasWhenInUseLocationPermission.value =
        await Permission.locationWhenInUse.isGranted;
    hasAlwaysLocationPermission.value =
        await Permission.locationAlways.isGranted;
    hasNotificationPermission.value = await Permission.notification.isGranted;
  }

  /// Esta função realiza trabalho quando o usuário volta para o aplicativo
  /// após ter saído do mesmo (neste caso, quando ele volta das configurações).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      hasWhenInUseLocationPermission.value =
          await Permission.locationWhenInUse.isGranted;
      hasAlwaysLocationPermission.value =
          await Permission.locationAlways.isGranted;
      hasNotificationPermission.value = await Permission.notification.isGranted;
    }
  }

  Future<void> requestWhenInUsePermission() async {
    if (await Permission.locationWhenInUse.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      await Permission.locationWhenInUse.request();
    }

    hasWhenInUseLocationPermission.value = await Permission.locationWhenInUse.isGranted;
  }

  Future<void> requestAlwaysPermission() async {
    PermissionStatus locationWhenInUseStatus = await Permission
        .locationWhenInUse
        .request();

    if (locationWhenInUseStatus.isGranted) {
      bool userAgreed = await _showBackgroundDisclosure();

      if (userAgreed) {
        PermissionStatus locationAlwaysStatus = await Permission.locationAlways
            .request();

        if (locationAlwaysStatus.isPermanentlyDenied) await openAppSettings();
      }
    } else if (locationWhenInUseStatus.isPermanentlyDenied) {
      await openAppSettings();
    }

    hasAlwaysLocationPermission.value =
        await Permission.locationAlways.isGranted;
  }

  /// Precisamos de permissão para exibibir notificações pois serviços de
  /// localização em segundo plano são críticos tanto para a privacidade do
  /// usuário quanto para o consumo de bateria. Sem notificações, o SO pode
  /// matar esses serviços.
  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      final result = await Permission.notification.request();

      if (result.isPermanentlyDenied) {
        await openAppSettings();
      }
    }

    hasNotificationPermission.value = await Permission.notification.isGranted;
  }

  /// Verifica se todas as permissões necessárias para o monitora funcionar
  /// adequadamente já foram concedidas ao aplicativo pelo usuário.
  bool arePermissionsGranted() {
    return hasAlwaysLocationPermission.value && hasNotificationPermission.value;
  }

  /// Aviso requerido pela Google Play.
  Future<bool> _showBackgroundDisclosure() async {
    return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            title: Row(
              children: [
                Icon(Icons.security, color: AppColors.darkBlue()),
                const SizedBox(width: 10),
                Text('atencao'.tr),
              ],
            ),
            content: Text(
              'monitora_disclosure_localizacao'.tr,
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.darkBlue(),
                ),
                child: Text('agora_nao'.tr),
              ),
              TextButton(
                onPressed: () async {
                  Get.back(result: true);
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.darkBlue(),
                ),
                child: Text('prosseguir'.tr),
              ),
            ],
          ),
          barrierDismissible: false, // Impede fechar clicando fora
        ) ??
        false;
  }

  Future<void> notifyGpsDisabled() async {
    await Get.dialog(
      AlertDialog(
        title: Text('gps_desligado'.tr),
        content: Text('ative_gps_continuar'.tr),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.darkBlue()),
            child: Text('entendi'.tr),
            onPressed: () {
              Get.back(); // Fecha o diálogo
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
