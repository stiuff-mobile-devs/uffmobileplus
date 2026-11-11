import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/recharge_card/controller/recharge_card_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

/// Passos para pagar a recarga no PagTesouro. O conteúdo rola e o botão fica
/// fixo no rodapé, então nada estoura em telas pequenas ou textos longos.
class RechargeCardPay extends GetView<RechargeCardController> {
  const RechargeCardPay({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 16.0, color: Colors.blue[100]);
    final bold = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.blue[100],
    );

    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      appBar: AppBars.build(title: 'recarregar_cartao_pagamento'.tr),
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CustomProgressDisplay())
            : Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.darkBlueToBlackGradient(),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              width: 3.0,
                              color: Colors.blue[100]!,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'valor_da_recarga'.tr,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.blue[100],
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "R\$ ${controller.priceFieldController.text}",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 44,
                                  color: Colors.blue[100],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text('siga_os_passos_recarga'.tr, style: textStyle),
                      const SizedBox(height: 16),
                      Text.rich(
                        TextSpan(
                          style: textStyle,
                          children: [
                            TextSpan(text: 'passo_1_acesse_o'.tr),
                            TextSpan(text: "PagTesouro", style: bold),
                            const TextSpan(text: ";"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('passo_2_siga_instrucoes'.tr, style: textStyle),
                      const SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          style: textStyle,
                          children: [
                            TextSpan(text: 'passo_3_apos_confirmacao'.tr),
                            TextSpan(text: "PagTesouro", style: bold),
                            TextSpan(text: 'aguarde_processamento'.tr),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'link_pagtesouro_validade_msg'.tr,
                        style: TextStyle(color: Colors.blue[100]),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: Obx(
        () => controller.isLoading.value
            ? const SizedBox.shrink()
            : Container(
                color: Colors.black,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 12, 32, 20),
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff052750),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          controller.launchPaymentUrl(
                            controller.paymentUrl,
                            context,
                          );
                        },
                        child: Text(
                          'ir_para_pagtesouro'.tr,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
