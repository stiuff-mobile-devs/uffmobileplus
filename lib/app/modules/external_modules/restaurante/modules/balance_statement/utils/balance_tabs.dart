//import 'package:carteirinha_uff_digital/models/user_balance.dart';
//import 'package:carteirinha_uff_digital/ui/balance/components/balance_tab_statement.dart';
//import 'package:carteirinha_uff_digital/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/utils/balance_tab_statement.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/user_balance.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/constants.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class BalanceTabs extends StatelessWidget {
  final UserBalance userBalance;
  final String period;

  const BalanceTabs(this.userBalance, this.period, {super.key});

  @override
  Widget build(BuildContext context) {
    // Abas dentro do conteúdo (abaixo do card de saldo). Antes era um
    // Scaffold + AppBar aninhado usado só como faixa de abas.
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Material(
            color: const Color(0xff052750),
            elevation: 2,
            child: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
              labelStyle: const TextStyle(fontSize: 14),
              indicatorColor: const Color.fromARGB(255, 0, 141, 47),
              tabs: <Widget>[
                Tab(text: 'extrato'.tr),
                Tab(text: 'recargas'.tr),
                Tab(text: 'pagamentos'.tr),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.darkBlueToBlackGradient(),
              ),
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  BalanceTabStatement(userBalance.statement ?? [], period),
                  BalanceTabStatement(
                    userBalance.statement!
                        .where(
                          (element) =>
                              element.category!.contains(Constants.CREDIT),
                        )
                        .toList(),
                    period,
                  ),
                  BalanceTabStatement(
                    userBalance.statement!
                        .where(
                          (element) =>
                              element.category!.contains(Constants.DEBIT),
                        )
                        .toList(),
                    period,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
