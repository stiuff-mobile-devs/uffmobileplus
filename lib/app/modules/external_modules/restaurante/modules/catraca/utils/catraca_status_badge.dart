import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/controller/catraca_controller.dart';

/// Selo "Online"/"Offline" da catraca, mostrado logo abaixo da AppBar.
class CatracaStatusBadge extends StatelessWidget {
  const CatracaStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CatracaController>();
    return Obx(() {
      final online = controller.isConnected.value;
      final checking = controller.isCheckingConnection.value;
      final color = online ? Colors.greenAccent : Colors.orangeAccent;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (checking)
              SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            else
              Icon(
                online ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                size: 14,
                color: color,
              ),
            const SizedBox(width: 6),
            Text(
              online ? 'online'.tr : 'catraca_offline_selo'.tr,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    });
  }
}
