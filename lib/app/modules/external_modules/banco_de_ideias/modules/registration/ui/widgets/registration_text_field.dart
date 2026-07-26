import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

class RegistrationTextField extends GetView<BancoDeIdeiasController> {
  const RegistrationTextField({
    super.key,
    required this.textController,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController textController;
  final String label;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: textController,
    style: const TextStyle(color: Colors.white),
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    ),
    validator: validator,
  );
}
