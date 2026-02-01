import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/controller/balance_statement_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/utils/balance_card.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/utils/balance_filter.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/utils/balance_tabs.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class BalanceStatementPage extends GetView<BalanceStatementController> {
  const BalanceStatementPage({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(
    appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: const Text('Saldo e Extrato'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () {
              controller.getUserBalance();
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
      ),

      body: Obx(
        () => controller.isBusy.value
            ? Center(child: CustomProgressDisplay())
            : Container(
              decoration: BoxDecoration(
                    gradient: AppColors.darkBlueToBlackGradient(),
                  ),
              child: Column(
                    children: <Widget>[
                      Container(
                       decoration: BoxDecoration(
                    gradient: AppColors.darkBlueToBlackGradient(),
                  ),
                        margin: const EdgeInsets.fromLTRB(64, 40, 64, 12),
                        child: BalanceCard(
                          name: controller.userName.value,
                          idUff: controller.userBalance.idUff ?? controller.userIduff.value,
                          currentBalance: controller.userBalance.currentBalance ?? "Erro",
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Visibility(
                            visible: !controller.isFiltersOpen.value,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 8, bottom: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  backgroundColor: const Color(0xff052750),
                                  padding: const EdgeInsets.all(
                                      16), // Ajusta o tamanho interno para centralizar
                                ),
                                onPressed: () {
                                  controller.getUserBalance();
                                },
                                child: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 20.0,
                                  semanticLabel:
                                      'Text to announce in accessibility modes',
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: !controller.isFiltersOpen.value,
                            child: Container(
                              
                              margin:
                                  const EdgeInsets.only(right: 8, bottom: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  backgroundColor: const Color(0xff052750),
                                  padding: const EdgeInsets.all(
                                      16), // Ajusta o tamanho interno para centralizar
                                ),
                                onPressed: () {
                                  controller.openFilters();
                                },
                                child: const Icon(
                                  Icons.tune,
                                  color: Colors.white,
                                  size: 20.0,
                                  semanticLabel:
                                      'Text to announce in accessibility modes',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: !controller.isFiltersOpen.value,
                        child: Expanded(
                          child: Container(
                            
                            child: BalanceTabs(controller.userBalance,
                                controller.filters["period"].toInt().toString()),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.isFiltersOpen.value,
                        child: Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: 6),
                            child: BalanceFilter(
                                actionClose: () {
                                  controller.closeFilters();
                                },
                                actionApply: () {
                                  controller.applyFilters(context);
                                },
                                actionChangePeriod: (value) {
                                  controller.changePeriod(value);
                                },
                                actionReset: () {
                                  controller.resetFilters();
                                },
                                filters: controller.filterSlider),
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