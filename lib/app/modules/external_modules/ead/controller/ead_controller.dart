import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class EadController extends GetxController {

  Future<void> openClassroom() async {
    final uri = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.google.android.apps.classroom',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Erro', 'Não foi possível abrir o Google Classroom');
    }
  }

  Future<void> openMoodle() async {
    final uri = Uri.parse(
      'https://play.google.com/store/apps/details?id=org.moodle.moodlemobile',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Erro', 'Não foi possível abrir o Moodle');
    }
  }
}
