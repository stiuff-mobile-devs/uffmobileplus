import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/recharge_card/controller/recharge_card_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class RechargeCardPay extends GetView<RechargeCardController> {
  const RechargeCardPay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: Text('recarregar_cartao_pagamento'.tr),
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
                alignment: Alignment.center,
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.darkBlueToBlackGradient(),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 350,
                        margin: EdgeInsets.only(top: 60),
                        padding: const EdgeInsets.symmetric(horizontal: 38),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 78,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      width: 3.0,
                                      color: Colors.blue[100]!,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'valor_da_recarga'.tr,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.blue[100],
                                        ),
                                      ),
                                      Text(
                                        "R\$ ${controller.priceFieldController.text}",
                                        style: TextStyle(
                                          fontSize: 44,
                                          color: Colors.blue[100],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                'siga_os_passos_recarga'.tr,
                                style: TextStyle(
                                  color: Colors.blue[100],
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.blue[100],
                                ),
                                children: [
                                  TextSpan(text: 'passo_1_acesse_o'.tr),
                                  TextSpan(
                                    text: "PagTesouro",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[100],
                                    ),
                                  ),
                                  TextSpan(text: ";"),
                                ],
                              ),
                            ),
                            Text(
                              'passo_2_siga_instrucoes'.tr,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue[100],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.blue[100],
                                ),
                                children: [
                                  TextSpan(
                                    text: 'passo_3_apos_confirmacao'.tr,
                                  ),
                                  TextSpan(
                                    text: "PagTesouro",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[100],
                                    ),
                                  ),
                                  TextSpan(text: 'aguarde_processamento'.tr),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 18.0),
                              child: Text(
                                'link_pagtesouro_validade_msg'.tr,
                                style: TextStyle(color: Colors.blue[100]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 80),
                        child: FloatingActionButton.extended(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          backgroundColor: Color(0xff052750),
                          label: Text(
                            'ir_para_pagtesouro'.tr,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          onPressed: () {
                            controller.launchPaymentUrl(
                              controller.paymentUrl,
                              context,
                            );
                          },
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
