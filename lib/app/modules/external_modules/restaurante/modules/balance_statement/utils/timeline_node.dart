//import 'package:carteirinha_uff_digital/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/constants.dart';

class TimelineNode extends StatelessWidget {
  final String type;

  const TimelineNode(this.type, {super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          color: Colors.white,
          width: 1,
          height: 100,
          margin: EdgeInsets.fromLTRB(5, 0, 20, 0),
        ),
        Container(
          decoration: BoxDecoration(
            color: type.contains(Constants.DEBIT)
                ? Colors.redAccent[100]
                : Colors.greenAccent[100],
            shape: BoxShape.circle,
          ),
          width: 10,
          height: 10,
          margin: EdgeInsets.fromLTRB(5, 0, 20, 0),
        ),
      ],
    );
  }
}
