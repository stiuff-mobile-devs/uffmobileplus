import 'package:external_app_launcher/external_app_launcher.dart';

class AppAvailabilityResult {
  final bool gmailInstalled;
  final bool meetInstalled;

  AppAvailabilityResult({
    required this.gmailInstalled,
    required this.meetInstalled,
  });

  bool get allInstalled => gmailInstalled && meetInstalled;
}

class AppAvailabilityService {
  // Package names and schemes
  static const _gmailPackage = 'com.google.android.gm';
  static const _meetPackage = 'com.google.android.apps.meetings';

  static const _gmailScheme = 'googlegmail';
  static const _meetScheme = 'comgooglemeet';

  /// Checks if Gmail is installed on the current device.
  static Future<bool> isGmailInstalled() async {
    try {
      final installed = await LaunchApp.isAppInstalled(
        iosUrlScheme: _gmailScheme,
        androidPackageName: _gmailPackage,
      );
      return installed == true;
    } catch (_) {
      return false;
    }
  }

  /// Checks if Google Meet is installed on the current device.
  static Future<bool> isMeetInstalled() async {
    try {
      final installed = await LaunchApp.isAppInstalled(
        iosUrlScheme: _meetScheme,
        androidPackageName: _meetPackage,
      );
      return installed == true;
    } catch (_) {
      return false;
    }
  }

  /// Returns both results.
  static Future<AppAvailabilityResult> checkBoth() async {
    final gmail = await isGmailInstalled();
    final meet = await isMeetInstalled();
    return AppAvailabilityResult(gmailInstalled: gmail, meetInstalled: meet);
  }
}
