import 'dart:io';

import 'package:get/get.dart';
import 'package:safe_device/safe_device.dart';

class LockDevelopModeController extends GetxController {
  LockDevelopModeController();

  Future<bool> updateDevMode() async {
    if (!Platform.isAndroid) {
      return false;
    }
    return await SafeDevice.isDevelopmentModeEnable;
  }
}
