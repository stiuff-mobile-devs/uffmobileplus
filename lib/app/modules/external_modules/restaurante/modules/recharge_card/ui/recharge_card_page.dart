import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/recharge_card/controller/recharge_card_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_balance_panel.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_price_selector.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_prices.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_simulation_banner.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class RechargeCardPage extends GetView<RechargeCardController> {
  const RechargeCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      resizeToAvoidBottomInset: true,
      appBar: AppBars.build(
        title: 'recarregar_cartao'.tr,
        actions: [
          Obx(
            () => mealPriceAppBarAction(
              selected: controller.selectedPrice.value,
              profilePrice: controller.profilePrice,
              onChanged: controller.setSelectedPrice,
            ),
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CustomProgressDisplay())
            : GestureDetector(
                // Fecha o teclado ao tocar fora do campo
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.translucent,
                child: Container(
                  alignment: Alignment.center,
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppColors.darkBlueToBlackGradient(),
                  ),
                  // Tela fixa: só a grade de valores rola (Expanded abaixo).
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Saldo, refeições e valor do perfil ───────────
                          // Some com o teclado aberto, para o campo de valor
                          // e o botão continuarem cabendo na tela.
                          if (MediaQuery.viewInsetsOf(context).bottom == 0) ...[
                            Obx(
                              () => MealBalancePanel(
                                balance: controller.balanceValue,
                                price: controller.profilePrice,
                                profileKey: MealPrices.profileLabelKey(
                                  controller.profileType.value,
                                ),
                                isLoading: controller.isBalanceLoading.value,
                              ),
                            ),

                            const SizedBox(height: 16),
                          ],

                          // ── Grade 2 colunas x 5 linhas (1 a 10 refeições) ──
                          // Linhas com Expanded: divide o espaço real, sem
                          // conta de largura (a borda da moldura não quebra).
                          // É a única parte que rola; o resto fica fixo.
                          Expanded(
                            child: SingleChildScrollView(
                              // respiro para o brilho da moldura não cortar
                              padding: const EdgeInsets.all(4),
                              child: Obx(() {
                                final simulating = controller.isSimulating;
                                final prices = controller.textPrices;
                                void select(int i) {
                                  FocusScope.of(context).unfocus();
                                  SystemChannels.textInput.invokeMethod(
                                    'TextInput.hide',
                                  );
                                  controller.setSelectedValue(i);
                                }

                                return MealSimulationFrame(
                                  isSimulating: simulating,
                                  flashKey: controller.selectedPrice.value,
                                  radius: 12,
                                  showIdleBorder: false,
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      simulating ? 12 : 0,
                                    ),
                                    child: Column(
                                      children: [
                                        for (
                                          int row = 0;
                                          row < (prices.length + 1) ~/ 2;
                                          row++
                                        ) ...[
                                          if (row > 0)
                                            const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              for (
                                                int col = 0;
                                                col < 2;
                                                col++
                                              ) ...[
                                                if (col > 0)
                                                  const SizedBox(width: 10),
                                                Expanded(
                                                  child:
                                                      row * 2 + col <
                                                          prices.length
                                                      ? _QuickValueTile(
                                                          price:
                                                              prices[row * 2 +
                                                                  col],
                                                          meals:
                                                              row * 2 + col + 1,
                                                          isSelected:
                                                              controller
                                                                  .selectedValues[row *
                                                                      2 +
                                                                  col],
                                                          onTap: () => select(
                                                            row * 2 + col,
                                                          ),
                                                        )
                                                      : const SizedBox.shrink(),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Obx(
                            () => _MealCountButton(
                              mealCount: controller.mealCount.value,
                              price: controller.mealCountPrice,
                              onDecrement: () {
                                FocusScope.of(context).unfocus();
                                controller.decrementMealCount();
                              },
                              onIncrement: () {
                                FocusScope.of(context).unfocus();
                                controller.incrementMealCount();
                              },
                              onSelect: () {
                                FocusScope.of(context).unfocus();
                                SystemChannels.textInput.invokeMethod(
                                  'TextInput.hide',
                                );
                                controller.selectMealCountButton();
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          TextField(
                            inputFormatters: [
                              CurrencyTextInputFormatter.currency(
                                locale: 'br',
                                decimalDigits: 2,
                                symbol: '',
                              ),
                            ],
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: false,
                            ),
                            textInputAction: TextInputAction.done,
                            onEditingComplete: () =>
                                FocusScope.of(context).unfocus(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            controller: controller.priceFieldController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 16,
                              ),
                              prefixText: "R\$ ",
                              prefixStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              hintText: 'digite_ou_selecione_valor'.tr,
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.white54,
                              ),
                              helperText: 'valor_recarga_a_ser_efetuada'.tr,
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
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          FloatingActionButton.extended(
                            heroTag: 'goToPayment',
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            backgroundColor: const Color(0xff052750),
                            label: Text(
                              'ir_para_pagamento'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              controller.goToPayment();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _MealCountButton extends StatelessWidget {
  const _MealCountButton({
    required this.mealCount,
    required this.price,
    required this.onDecrement,
    required this.onIncrement,
    required this.onSelect,
  });

  final int mealCount;
  final String price;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue[300]!, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Botão −
          _SideButton(
            icon: Icons.remove,
            onTap: onDecrement,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),

          // Área central — seleciona o valor no campo
          Expanded(
            child: InkWell(
              onTap: onSelect,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "R\$ $price",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mealCount == 1
                          ? 'refeicao_contagem_singular'.trParams({
                              'count': '$mealCount',
                            })
                          : 'refeicao_contagem_plural'.trParams({
                              'count': '$mealCount',
                            }),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Botão +
          _SideButton(
            icon: Icons.add,
            onTap: onIncrement,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.icon,
    required this.onTap,
    required this.borderRadius,
  });

  final IconData icon;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xff104389),
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

/// Botão rápido da grade: valor e quantidade de refeições.
class _QuickValueTile extends StatelessWidget {
  const _QuickValueTile({
    required this.price,
    required this.meals,
    required this.isSelected,
    required this.onTap,
  });

  final String price;
  final int meals;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff104389) : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.blue[100]! : Colors.grey[500]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "R\$ $price",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 15,
                    color: isSelected ? Colors.white : Colors.blue[100],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'refeicoes_abrev'.trParams({'count': '$meals'}),
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
