import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final void Function() action;
  final Color backgroundColor;
  final String text;

  const FilterButton({super.key, required this.action, required this.backgroundColor, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: backgroundColor,
        ),
        onPressed: action,
        child: Text(
          text,
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
    );
  }
}
