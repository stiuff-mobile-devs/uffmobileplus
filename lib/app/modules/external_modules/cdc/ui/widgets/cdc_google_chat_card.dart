import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/controller/cdc_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

/// Card do topo da aba Salas sobre as salas do Google Chat do usuário:
/// conectar a conta, dar a permissão, usar a conta da UFF ou tentar de novo.
/// Some quando as salas já foram carregadas.
class CdcGoogleChatCard extends GetView<CdcController> {
  const CdcGoogleChatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final (title, message, action) = switch (controller.chatStatus.value) {
        CdcGoogleChatStatus.notConnected => (
            'cdc_google_chat_titulo'.tr,
            'cdc_google_chat_conectar_msg'.tr,
            'cdc_google_chat_conectar'.tr,
          ),
        CdcGoogleChatStatus.noPermission => (
            'cdc_google_chat_titulo'.tr,
            'cdc_google_chat_permitir_msg'.tr,
            'cdc_google_chat_permitir'.tr,
          ),
        CdcGoogleChatStatus.otherAccount => (
            'cdc_google_chat_outra_conta_titulo'.tr,
            'cdc_google_chat_outra_conta_msg'.tr,
            null,
          ),
        CdcGoogleChatStatus.error => (
            'cdc_google_chat_erro_titulo'.tr,
            'tente_novamente_mais_tarde'.tr,
            'tentar_novamente'.tr,
          ),
        CdcGoogleChatStatus.loading || CdcGoogleChatStatus.ready => (
            null,
            null,
            null,
          ),
      };
      if (title == null || message == null) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.mediumBlue().withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.lightBlue().withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.forum_outlined,
                  color: AppColors.lightBlue(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mediumBlue(),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: controller.connectGoogleChat,
                  child: Text(action),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
