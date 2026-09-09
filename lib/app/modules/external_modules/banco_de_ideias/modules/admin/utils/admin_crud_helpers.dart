import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

dynamic readCrudValue(Map<String, dynamic> source, String path) {
  dynamic current = source;
  for (final part in path.split('.')) {
    if (current is! Map) {
      return null;
    }
    current = current[part];
  }
  return current;
}

String formatCrudValue(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

class AdminStateMessage extends GetView<BancoDeIdeiasController> {
  const AdminStateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          action,
        ],
      ),
    );
  }
}

class AdminDeleteRecordDialog extends GetView<BancoDeIdeiasController> {
  const AdminDeleteRecordDialog({super.key, required this.recordTitle});

  final String recordTitle;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('bdi_excluir_registro_titulo'.tr),
      content: Text(
        'bdi_confirmar_exclusao_registro'.trParams({'title': recordTitle}),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('cancelar'.tr),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: Text('excluir'.tr),
        ),
      ],
    );
  }
}
