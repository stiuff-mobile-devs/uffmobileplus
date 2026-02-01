import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceService {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  /// Obtém o número de build do dispositivo atual
  static Future<String> getBuildNumber() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidBuildNumber();
      } else if (Platform.isIOS) {
        return await _getIOSBuildNumber();
      }
      return 'Desconhecido';
    } catch (e) {
      return 'Erro ao obter build number: $e';
    }
  }

  /// Obtém o build number do Android
  static Future<String> _getAndroidBuildNumber() async {
    final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    return androidInfo.display;
  }

  /// Obtém o build number do iOS
  static Future<String> _getIOSBuildNumber() async {
    final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
    return iosInfo.systemVersion;
  }
}
