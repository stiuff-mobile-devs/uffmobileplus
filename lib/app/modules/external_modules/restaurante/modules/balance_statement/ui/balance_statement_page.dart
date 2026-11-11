import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/controller/balance_statement_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/utils/statement_filters.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/utils/statement_list.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_balance_panel.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_prices.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

/// Saldo e extrato: painel do RU no topo, filtros compactos e a lista por
/// dia. A tela é fixa; só a lista rola.
class BalanceStatementPage extends GetView<BalanceStatementController> {
  const BalanceStatementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      appBar: AppBars.build(
        title: 'saldo_e_extrato'.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'atualizar'.tr,
            onPressed: controller.getUserBalance,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: SafeArea(
          top: false,
          child: Obx(() {
            // Carregamento em tela cheia só na primeira vez; depois o
            // conteúdo fica e o painel mostra "…".
            final firstLoad = controller.isBusy.value &&
                controller.userBalance.currentBalance == null &&
                !controller.hasError.value;
            if (firstLoad) return Center(child: CustomProgressDisplay());

            final isBusy = controller.isBusy.value;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MealBalancePanel(
                    balance: controller.balanceValue,
                    price: controller.mealPrice,
                    profileKey: MealPrices.profileLabelKey(
                      controller.profileType.value,
                    ),
                    isLoading: isBusy,
                    onRecharge: !isBusy && controller.isBalanceInsufficient
                        ? controller.goToRecharge
                        : null,
                  ),
                  const SizedBox(height: 16),
                  StatementFilters(
                    type: controller.typeFilter.value,
                    period: controller.period,
                    onTypeChanged: controller.setTypeFilter,
                    onPeriodChanged: controller.setPeriod,
                  ),
                  Expanded(
                    child: StatementList(
                      statement: controller.filteredStatement,
                      period: controller.period,
                      hasError: controller.hasError.value,
                      onRefresh: controller.getUserBalance,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
