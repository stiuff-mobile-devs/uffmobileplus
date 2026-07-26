import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

class RecordFormDialogView extends GetView<BancoDeIdeiasController> {
  const RecordFormDialogView({
    super.key,
    required this.title,
    required this.content,
    required this.isSaving,
    required this.canSave,
    required this.onCancel,
    required this.onSave,
  });

  final String title;
  final Widget content;
  final bool isSaving;
  final bool canSave;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: SizedBox(width: 520, child: content),
    actions: [
      TextButton(
        onPressed: isSaving ? null : onCancel,
        child: const Text('Cancelar'),
      ),
      FilledButton.icon(
        onPressed: canSave ? onSave : null,
        icon: isSaving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_rounded),
        label: const Text('Salvar'),
      ),
    ],
  );
}
