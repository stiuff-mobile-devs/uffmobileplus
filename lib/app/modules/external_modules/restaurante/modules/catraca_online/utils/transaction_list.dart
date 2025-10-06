import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/controller/catraca_online_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/operator_transaction.dart';

class TransactionList extends StatelessWidget {
  final List<OperatorTransactionModel> operatorTransactions;

  const TransactionList(this.operatorTransactions);
  @override
  Widget build(BuildContext context) {
    final CatracaOnlineController controller =
        Get.find<CatracaOnlineController>();
    return ListView.builder(
      itemCount: operatorTransactions.length + 1,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Text(
              "Últimas Transações",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        } else {
          return GestureDetector(
            onTap: () async {
              controller.goToDetalhado(operatorTransactions[index - 1]);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Text(
                      DateFormat(
                        'dd/MM/yy HH:mm',
                      ).format(operatorTransactions[index - 1].date!),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    child: Text(
                      operatorTransactions[index - 1].name!,
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "R\$ ${operatorTransactions[index - 1].value}",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
