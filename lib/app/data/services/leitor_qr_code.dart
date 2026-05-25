import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:uffmobileplus/app/utils/color_pallete.dart'; // Mantido do seu código

class LeitorQrCodesController extends GetxController {
  final MobileScannerController cameraController = MobileScannerController();
  bool isProcessing = false;

  void toggleTorch() {
    cameraController.toggleTorch();
  }

  void switchCamera() {
    cameraController.switchCamera();
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}

class LeitorQrCodeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LeitorQrCodesController>(() => LeitorQrCodesController());
  }
}

class LeitorQrCode extends GetView<LeitorQrCodesController> {
  const LeitorQrCode({super.key});

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
        title: const Text("Leitor QR Code"),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        // flexibleSpace: Container(
        //   decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        // ),
        backgroundColor: Colors.blue, // Apenas para rodar sem o seu AppColors
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller.cameraController,
            onDetect: (capture) => onQrCodeDetected(context, capture),
            // Tratamento de erro caso dê problema na câmera (ex: sem permissão)
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Erro ao iniciar a câmera.\nVerifique as permissões do aplicativo.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              );
            },
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
                const Text(
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
          
          // Agrupando os botões de ação no canto superior direito
          Positioned(
            top: 24,
            right: 24,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'toggleCamera',
                  backgroundColor: Colors.black54,
                  mini: true,
                  onPressed: controller.switchCamera,
                  child: const Icon(Icons.cameraswitch, color: Colors.white),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'toggleTorch',
                  backgroundColor: Colors.black54,
                  mini: true, // Deixei menor para não poluir tanto a tela
                  onPressed: controller.toggleTorch,
                  child: const Icon(Icons.flash_on, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}