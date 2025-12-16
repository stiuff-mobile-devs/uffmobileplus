//import 'package:carteirinha_uff_digital/models/card_transaction.dart';
//import 'package:carteirinha_uff_digital/ui/balance/components/timeline_node.dart';
//import 'package:carteirinha_uff_digital/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/utils/timeline_node.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/card_transaction.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/constants.dart';

class BalanceTabStatement extends StatelessWidget {
  final List<CardTransaction> statement;
  final String period;

  const BalanceTabStatement(this.statement, this.period, {super.key});

  @override
  Widget build(BuildContext context) {
    return statement.isEmpty
        ? Center(
            child: Text(
              "Sem informações para os últimos $period dias",
              style: TextStyle(
                color: Colors.grey[300],
              ),
            ),
          )
        : Tab(
            child: ListView.builder(
              shrinkWrap: false,
              padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
              itemCount: statement.length,
              itemBuilder: (BuildContext context, int index) {
                String statementText =
                    statement[index].category!.contains(Constants.DEBIT)
                        ? "Valor debitado:"
                        : "Valor creditado:";
                return Row(
                  children: <Widget>[
                    TimelineNode(statement[index].category!),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            "${DateFormat('dd/MM/yyyy HH:mm').format(statement[index].date!.toLocal())}",
                            style: TextStyle(color: Colors.blueGrey[200])),
                        Text(statement[index].type!,
                            style: TextStyle(color: Colors.blueGrey[100])),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(statementText,
                              style: TextStyle(color: Colors.blueGrey[200])),
                          Text("R\$ ${statement[index].value}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[100])),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          );
  }
}
