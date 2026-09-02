import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/controller/pay_restaurant_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class PayHelpPage extends GetView<PayRestaurantController> {
  const PayHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: Text('acesso_ao_restaurante'.tr),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CustomProgressDisplay())
            : Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.darkBlueToBlackGradient(),
                ),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 40, left: 30, right: 30),
                      child: Text(
                        'ajuda_passo_1_brilho'.tr,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 198, 238, 253),
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Image.asset(
                      "assets/restaurant/img/qrcode_help_1.png",
                      height: 150,
                    ),
                    Image.asset(
                      "assets/restaurant/img/qrcode_help_2.png",
                      height: 150,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: Text(
                        'ajuda_passo_2_bipe'.tr,
                        style: TextStyle(
                          color: Color.fromARGB(255, 198, 238, 253),
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: Text(
                        'ajuda_passo_3_pronto'.tr,
                        style: TextStyle(
                          color: Color.fromARGB(255, 253, 255, 187),
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
