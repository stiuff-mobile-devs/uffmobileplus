import 'package:flutter/material.dart';

class CustomCloseButton extends StatelessWidget {
  const CustomCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, right: 10),
      child: Align(
        alignment: Alignment.topRight,
        child: Icon(
          Icons.close,
          color: Colors.white,
          size: 28.0,
          semanticLabel: 'Text to announce in accessibility modes',
        ),
      ),
    );
  }
}
