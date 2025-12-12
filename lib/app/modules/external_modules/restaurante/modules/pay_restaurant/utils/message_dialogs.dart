import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/constants.dart';

class MessageDialogs {
  static Future showErrorDialog<T>(
    context, {
    message = Constants.DEFAULT_API_ERROR,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Ops..."),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  static Future showMessageDialog<T>(context, {message}) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message, textAlign: TextAlign.center),
          actions: <Widget>[
            TextButton(
              child: Text("OK", textAlign: TextAlign.center),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
