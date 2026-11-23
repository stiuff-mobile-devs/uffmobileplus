import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/controller/catraca_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/catraca_app_bar.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/catraca_status_badge.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class LeitorQrCodeController extends GetxController {
  final MobileScannerController cameraController = MobileScannerController();
  bool isProcessing = false; // Adicione esta variável

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}

class LeitorQrCodePage extends GetView<LeitorQrCodeController> {
  const LeitorQrCodePage({super.key});

  void onQrCodeDetected(BuildContext context, BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty &&
        barcodes.first.rawValue != null &&
        !controller.isProcessing) {
      controller.isProcessing = true; // Bloqueia novas detecções
      Get.back(result: barcodes.first.rawValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      appBar: catracaAppBar(
        title: 'ler_qr_code'.tr,
        onRefresh: () => Get.find<CatracaController>().checkConnection(),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller.cameraController,
            onDetect: (capture) => onQrCodeDetected(context, capture),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'aponte_qr_code_centro'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black54,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Positioned(top: 24, left: 24, child: CatracaStatusBadge()),
          Positioned(
            top: 24,
            right: 24,
            child: FloatingActionButton(
              heroTag: 'toggleCamera',
              backgroundColor: Colors.black54,
              onPressed: () {
                controller.cameraController.switchCamera();
              },
              child: const Icon(Icons.cameraswitch, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
