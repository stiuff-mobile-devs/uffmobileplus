import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/recharge_card/controller/recharge_card_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class RechargeCardPage extends GetView<RechargeCardController> {
  const RechargeCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: Text("Recarregar Cartão"),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () {
              controller.onInit();
            },
          ),
        ],
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 40),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: List.generate(10, (i) {
                            final meals = i + 1; // Número de refeições (1 a 10)
                            return GestureDetector(
                              onTap: () {
                                controller.setSelectedValue(i);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: controller.selectedValues[i]
                                      ? const Color(0xff104389)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: controller.selectedValues[i]
                                        ? Colors.blue[100]!
                                        : Colors.grey[500]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "R\$ ${controller.textPrices[i]}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: controller.selectedValues[i]
                                            ? Colors.white
                                            : Colors.blue[100],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "($meals ${meals == 1 ? 'refeição' : 'refeições'})",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: controller.selectedValues[i]
                                            ? Colors.white
                                            : Colors.white,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(
                        width: 238,
                        child: TextField(
                          inputFormatters: [
                            CurrencyTextInputFormatter.currency(
                              locale: 'br',
                              decimalDigits: 2,
                              symbol: '',
                            ),
                          ],
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          controller: controller.priceFieldController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                              left: 14.0,
                              bottom: 16.0,
                              top: 16.0,
                            ),
                            prefixText: "R\$ ",
                            prefixStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            hintText: 'Digite ou selecione um valor',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.white54,
                            ),
                            helperText: 'Valor da recarga a ser efetuada',
                            helperStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 50),
                        child: FloatingActionButton.extended(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          backgroundColor: const Color(0xff052750),
                          label: const Text(
                            "Ir para o pagamento",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          onPressed: () {
                            controller.goToPayment();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
