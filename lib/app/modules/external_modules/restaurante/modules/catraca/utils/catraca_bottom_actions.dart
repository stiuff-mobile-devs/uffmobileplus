import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/controller/catraca_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

/// Barra inferior da catraca: "Liberar manualmente" + "Ler QR code".
///
/// Com [accent] (tela de resultado colorida), o botão principal fica branco
/// com o texto na cor do resultado e a barra fica transparente.
class CatracaBottomActions extends GetView<CatracaController> {
  const CatracaBottomActions({
    super.key,
    this.accent,
    this.manualLabel,
    this.scanLabel,
  });

  final Color? accent;
  final String? manualLabel;
  final String? scanLabel;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    final onAccent = accent != null;
    return Container(
      color: onAccent ? Colors.transparent : AppColors.darkBlue(),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: onAccent ? Colors.white : AppColors.lightBlue(),
                      width: onAccent ? 1.5 : 1,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: shape,
                  ),
                  onPressed: controller.manualValidation,
                  icon: const Icon(Icons.keyboard_rounded),
                  label: Text(
                    manualLabel ?? 'liberar_manualmente'.tr,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: onAccent
                        ? Colors.white
                        : AppColors.mediumBlue(),
                    foregroundColor: onAccent ? accent : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: shape,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onPressed: controller.readCode,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: Text(
                    scanLabel ?? 'ler_qr_code'.tr,
                    textAlign: TextAlign.center,
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
