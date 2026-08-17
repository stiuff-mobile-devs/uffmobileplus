import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

class UserTypeSegment extends GetView<BancoDeIdeiasController> {
  const UserTypeSegment({
    super.key,
    required this.isAluno,
    required this.enabled,
    required this.onChanged,
  });

  final bool isAluno;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<bool>(
    segments: const [
      ButtonSegment(
        value: true,
        icon: Icon(Icons.school_rounded),
        label: Text('Aluno'),
      ),
      ButtonSegment(
        value: false,
        icon: Icon(Icons.co_present_rounded),
        label: Text('Professor'),
      ),
    ],
    selected: {isAluno},
    onSelectionChanged: enabled ? (values) => onChanged(values.first) : null,
  );
}
