import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: const Text("Catraca - Leitor QR Code"),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
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
                  'Aponte o QR Code para o centro do quadrado',
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
