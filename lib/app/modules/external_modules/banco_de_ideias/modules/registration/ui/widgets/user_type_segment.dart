import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

class UserTypeSegment extends GetView<BancoDeIdeiasController> {
  const UserTypeSegment({
    super.key,
    required this.tipoUsuario,
    required this.enabled,
    required this.onChanged,
  });

  final String tipoUsuario;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SegmentedButton<String>(
      direction: constraints.maxWidth < 480 ? Axis.vertical : Axis.horizontal,
      expandedInsets: EdgeInsets.zero,
      segments: [
        ButtonSegment(
          value: 'Aluno',
          icon: const Icon(Icons.school_rounded),
          label: Text('bdi_aluno'.tr),
        ),
        ButtonSegment(
          value: 'Professor',
          icon: const Icon(Icons.co_present_rounded),
          label: Text('bdi_professor'.tr),
        ),
        ButtonSegment(
          value: 'Terceirizado',
          icon: const Icon(Icons.badge_outlined),
          label: Text('bdi_terceirizado'.tr),
        ),
      ],
      selected: {tipoUsuario},
      onSelectionChanged: enabled ? (values) => onChanged(values.first) : null,
    ),
  );
}
