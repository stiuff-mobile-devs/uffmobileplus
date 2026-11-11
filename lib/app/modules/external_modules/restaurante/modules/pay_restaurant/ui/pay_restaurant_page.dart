import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/controller/pay_restaurant_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/card_details.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_balance_panel.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_price_selector.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_prices.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

/// Tela "Pagar RU": cartão no topo, painel com saldo/refeições/valor e as
/// ações (gerar código, ajuda) no rodapé.
class PayRestaurantPage extends GetView<PayRestaurantController> {
  const PayRestaurantPage({super.key});

  static const double _maxContentWidth = 420;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      appBar: AppBars.build(
        title: 'pagar_restaurante'.tr,
        actions: [
          Obx(
            () => mealPriceAppBarAction(
              selected: controller.selectedPrice.value,
              profilePrice: controller.mealPrice,
              onChanged: controller.setSelectedPrice,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'atualizar'.tr,
            onPressed: controller.reloadData,
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CustomProgressDisplay())
            : Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.darkBlueToBlackGradient(),
                ),
                child: SafeArea(
                  top: false,
                  child: LayoutBuilder(
                    // Rola em telas baixas; em telas altas o rodapé desce
                    // até o fim (Spacer dentro de IntrinsicHeight).
                    builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: _maxContentWidth,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  8,
                                ),
                                // Obx próprio: o builder do LayoutBuilder
                                // roda fora do Obx de cima, então as
                                // leituras aqui (seletor, saldo) não seriam
                                // observadas.
                                child: Obx(
                                  () => _content(constraints.maxWidth),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _content(double screenWidth) {
    final available =
        (screenWidth < _maxContentWidth ? screenWidth : _maxContentWidth) - 32;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: IdCard(
            userImageUrl: controller.userImageUrl,
            username: controller.userName,
            iduff: controller.userIdUFF,
            width: available < IdCard.baseWidth ? available : null,
          ),
        ),
        // Spacers iguais acima e abaixo: o painel fica no centro do espaço
        // entre o cartão e o rodapé.
        const Spacer(),
        const SizedBox(height: 16),
        // O painel mostra o valor escolhido na AppBar; o nome do perfil só
        // aparece quando o valor é o do próprio perfil.
        MealBalancePanel(
          balance: controller.balanceValue,
          price: controller.selectedPrice.value,
          profileKey: controller.selectedPrice.value == controller.mealPrice
              ? MealPrices.profileLabelKey(controller.profileType.value)
              : null,
          onRecharge: controller.showRechargeButton
              ? controller.goToRecharge
              : null,
          isSimulating: controller.isSimulating,
        ),
        const SizedBox(height: 16),
        Text(
          'valor_nao_debitado_se_nao_utilizado'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.0,
            color: Colors.blue[200],
            fontStyle: FontStyle.italic,
          ),
        ),
        const Spacer(),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mediumBlue(),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: controller.goToPaymentTicket,
            icon: const Icon(Icons.qr_code_2, size: 26),
            label: Text(
              'gerar_codigo'.tr,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: controller.goToPaymentHelpScreen,
          icon: Icon(Icons.help_outline, color: Colors.blue[100], size: 20),
          label: Text(
            'como_utilizar_codigo'.tr,
            style: TextStyle(color: Colors.blue[100]),
          ),
        ),
      ],
    );
  }
}
