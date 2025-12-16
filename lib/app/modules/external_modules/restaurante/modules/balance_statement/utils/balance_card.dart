import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final String name;
  final String idUff;
  final String currentBalance;

  const BalanceCard({super.key, required this.name, required this.idUff, required this.currentBalance});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: 220,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              this.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue[100],
                  fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                idUff,
                style: TextStyle(color: Colors.blue[100],),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.green[900],
                borderRadius: BorderRadius.all(
                  const Radius.circular(20.0),
                ),
              ),
              child: FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "R\$ ",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      currentBalance,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
