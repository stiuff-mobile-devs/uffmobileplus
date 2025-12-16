//import 'package:carteirinha_uff_digital/models/user_balance.dart';
//import 'package:carteirinha_uff_digital/ui/balance/components/balance_tab_statement.dart';
//import 'package:carteirinha_uff_digital/utils/constants.dart';
import 'package:flutter/material.dart';
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        extendBody: false,
        primary: false,
        appBar: AppBar(
          elevation: 2,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xff052750),
          title: const TabBar(
            labelColor: Colors.white, 
            unselectedLabelColor: Colors.white, 
            labelStyle: TextStyle(fontSize: 14),
            indicatorColor:Color.fromARGB(255, 0, 141, 47), 
            tabs: <Widget>[
              Tab(text: "Extrato"),
              Tab(text: "Recargas"),
              Tab(text: "Pagamentos"),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
                    gradient: AppColors.darkBlueToBlackGradient(),
                  ),
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              BalanceTabStatement(userBalance.statement?? [], period),
              BalanceTabStatement(
                  userBalance.statement!
                      .where((element) =>
                          element.category!.contains(Constants.CREDIT))
                      .toList(),
                  period),
              BalanceTabStatement(
                  userBalance.statement!
                      .where((element) =>
                          element.category!.contains(Constants.DEBIT))
                      .toList(),
                  period),
            ],
          ),
        ),
      ),
    );
  }
}
