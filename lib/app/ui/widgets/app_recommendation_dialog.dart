import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uffmobileplus/app/data/services/app_availability_service.dart';

class AppRecommendationDialog {
  static Future<void> show(AppAvailabilityResult result) async {
    if (result.allInstalled) return;

    await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.black87,
        title: Text('recomendacao'.tr, style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!result.gmailInstalled)
              Text(
                'recomendamos_instalar_gmail'.tr,
                style: TextStyle(color: Colors.white70),
              ),
            if (!result.meetInstalled) ...[
              const SizedBox(height: 8),
              Text(
                'recomendamos_instalar_meet'.tr,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ],
        ),
        actions: [
          if (!result.gmailInstalled)
            TextButton(
              onPressed: () async {
                const gmailAndroid =
                    'https://play.google.com/store/apps/details?id=com.google.android.gm';
                const gmailIos =
                    'https://apps.apple.com/app/gmail-email-by-google/id422689480';
                final uri = Uri.parse(Platform.isIOS ? gmailIos : gmailAndroid);
                await _launchUri(uri);
              },
              child: Text('instalar_gmail'.tr),
            ),
          if (!result.meetInstalled)
            TextButton(
              onPressed: () async {
                const meetAndroid =
                    'https://play.google.com/store/apps/details?id=com.google.android.apps.tachyon';
                const meetIos = 'https://apps.apple.com/br/app/id1096918571';
                final uri = Uri.parse(Platform.isIOS ? meetIos : meetAndroid);
                await _launchUri(uri);
              },
              child: Text('instalar_meet'.tr),
            ),
          TextButton(onPressed: () => Get.back(), child: Text('ignorar'.tr)),
        ],
      ),
      barrierDismissible: true,
    );
  }

  static Future<void> _launchUri(Uri uri) async {
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar('erro'.tr, 'nao_foi_possivel_abrir_loja'.tr);
      }
    } catch (e) {
      Get.snackbar('erro'.tr, 'nao_foi_possivel_abrir_loja'.tr);
    }
  }
}
