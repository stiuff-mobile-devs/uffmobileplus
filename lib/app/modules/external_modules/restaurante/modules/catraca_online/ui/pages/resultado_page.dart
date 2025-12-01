import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/controller/catraca_online_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/utils/transaction_message.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class ResultadoPage extends GetView<CatracaOnlineController> {
  const ResultadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: Obx(() => Text(controller.statusMessage.value)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
      ),
      body: Obx(
        () => controller.isReadQRCodeBusy.value
            ? Center(child: CustomProgressDisplay())
            : Container(
                decoration: BoxDecoration(
                  gradient: AppColors.darkBlueToBlackGradient(),
                ),
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppColors.darkBlueToBlackGradient(),
                      ),
                      child: TransactionMessage(
                        isOfflineMode: controller.isOfflineMode.value,
                        isQrCodeValid: controller.isQrCodeValid,
                        isTransactionValid: controller.isTransactionValid,
                        transactionResultMessage:
                            controller.transactionResultMessage,
                        transactionUsername: controller.transactionUsername,
                        actionButton: FloatingActionButton.extended(
                          heroTag: 'ler_codigo',
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          backgroundColor: const Color(0xff052750),
                          icon: const Icon(
                            Icons.crop_free,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Ler código",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          onPressed: () {
                            controller.readCode();
                          },
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      margin: const EdgeInsets.only(bottom: 150),
                      child: FloatingActionButton.extended(
                        heroTag: 'validar_manual',
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        backgroundColor: const Color(0xff052750),
                        icon: const Icon(
                          Icons.list,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Validar Manualmente",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        onPressed: () {
                          controller.manualValidation();
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
