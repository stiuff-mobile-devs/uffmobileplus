import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/modules/external_modules/sos/controller/sos_controller.dart';

class SosPage extends GetView<SosController> {
  const SosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("botao_emergencia".tr),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 8,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: Get.height * 0.1),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: Get.width * 0.08,vertical: 20),
              child: Text(
                "sos_descricao".tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.lightBlue(), fontSize: 16),
              ),
            ),

            SizedBox(height: Get.height * 0.05),

            Obx(() {
              if (controller.isLoading.value) {
                return Column(
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(
                        color: AppColors.lightBlue(),
                        strokeWidth: 5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "sos_enviando".tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }
              double buttonSize = (Get.width * 0.55).clamp(180.0, 300.0);
              return GestureDetector(
                onTap: () => controller.sendSos(),
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.5),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),

                      BoxShadow(
                        color: AppColors.darkBlue().withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: -5,
                      ),
                    ],
                    border: Border.all(color: AppColors.lightBlue(), width: 4),
                  ),
                  child: Center(
                    child: Text(
                      "SOS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: buttonSize * 0.25,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black45,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
