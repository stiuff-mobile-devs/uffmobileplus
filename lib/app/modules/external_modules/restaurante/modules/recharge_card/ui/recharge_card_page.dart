import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/recharge_card/controller/recharge_card_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_balance_panel.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_prices.dart';
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
      appBar: AppBars.build(title: 'recarregar_cartao'.tr),
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
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Saldo, refeições e valor do perfil ───────────
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

                          const SizedBox(height: 20),

                          // ── Seletor do valor por refeição ─────────────────
                          Obx(
                            () => _PriceSelector(
                              selected: controller.selectedPrice.value,
                              profilePrice: controller.profilePrice,
                              onChanged: (price) {
                                FocusScope.of(context).unfocus();
                                controller.setSelectedPrice(price);
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── Grade fixa 2 colunas ──────────────────────────
                          LayoutBuilder(
                            builder: (context, constraints) => Obx(() {
                              final itemWidth = (constraints.maxWidth - 10) / 2;
                              final prices = controller.textPrices;
                              return Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: List.generate(prices.length, (i) {
                                  final meals = i + 1;
                                  final isSelected =
                                      controller.selectedValues[i];
                                  return GestureDetector(
                                    onTap: () {
                                      // Fecha o teclado antes de selecionar
                                      FocusScope.of(context).unfocus();
                                      SystemChannels.textInput.invokeMethod(
                                        'TextInput.hide',
                                      );
                                      controller.setSelectedValue(i);
                                    },
                                    child: SizedBox(
                                      width: itemWidth,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xff104389)
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.blue[100]!
                                                : Colors.grey[500]!,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "R\$ ${prices[i]}",
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.blue[100],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'refeicoes_abrev'.trParams({
                                                'count': '$meals',
                                              }),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            }),
                          ),

                          const SizedBox(height: 14),

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

                          const SizedBox(height: 28),

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

                          const SizedBox(height: 40),

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

                          const SizedBox(height: 20),
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

/// Seletor do valor por refeição usado na grade e no contador. Marca com
/// "Seu valor" a opção do perfil do usuário.
class _PriceSelector extends StatelessWidget {
  const _PriceSelector({
    required this.selected,
    required this.profilePrice,
    required this.onChanged,
  });

  final double selected;
  final double? profilePrice;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = [MealPrices.student, MealPrices.staff];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ru_ver_valores_para'.tr,
          style: TextStyle(fontSize: 14, color: Colors.blue[100]),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final price in options) ...[
              Expanded(
                child: _PriceOption(
                  price: price,
                  isSelected: selected == price,
                  isProfile: profilePrice == price,
                  onTap: () => onChanged(price),
                ),
              ),
              if (price != options.last) const SizedBox(width: 10),
            ],
          ],
        ),
      ],
    );
  }
}

class _PriceOption extends StatelessWidget {
  const _PriceOption({
    required this.price,
    required this.isSelected,
    required this.isProfile,
    required this.onTap,
  });

  final double price;
  final bool isSelected;
  final bool isProfile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xff104389) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? Colors.blue[100]! : Colors.grey[500]!,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'R\$ ${MealPrices.format(price)}',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.blue[100],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isProfile ? 'seu_valor'.tr : 'ru_por_refeicao'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isProfile ? Colors.green[300] : Colors.white70,
                  fontWeight: isProfile ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
