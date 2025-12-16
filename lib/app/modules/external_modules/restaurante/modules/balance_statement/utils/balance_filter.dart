//import 'package:carteirinha_uff_digital/components/ui/close_button.dart';
//import 'package:carteirinha_uff_digital/ui/balance/components/filter_button.dart';
import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/utils/close_button.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/utils/filter_button.dart';

class BalanceFilter extends StatelessWidget {
  final void Function() actionApply;
  final void Function() actionClose;
  final void Function(double) actionChangePeriod;
  final void Function() actionReset;
  final Map<String, dynamic> filters;

  const BalanceFilter(
      {super.key, required this.actionClose,
      required this.actionApply,
      required this.actionChangePeriod,
      required this.actionReset,
      required this.filters});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xff104389),
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: actionClose,
            child: CustomCloseButton(),
          ),
          Container(
            margin: EdgeInsets.only(left: 40, top: 60, right: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      "Período:",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Expanded(
                      child: Text(
                        "Últimos ${filters["period"].toStringAsFixed(0)} dias",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: Colors.blueAccent[100],
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Slider(
                  activeColor: Color(0xff9ABEF0),
                  onChanged: actionChangePeriod,
                  value: filters["period"],
                  min: 15,
                  max: 90,
                  divisions: 5,
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FilterButton(
                        backgroundColor: Color(0xff052750),
                        text: "Aplicar Filtros",
                        action: actionApply,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
