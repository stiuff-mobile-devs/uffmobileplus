import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserDestination {
  const UserDestination({
    required this.labelKey,
    required this.icon,
    required this.selectedIcon,
  });

  final String labelKey;
  final IconData icon;
  final IconData selectedIcon;

  String get label => labelKey.tr;
}
