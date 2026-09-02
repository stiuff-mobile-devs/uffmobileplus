import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/crud_table.dart';

class RecordTextField extends GetView<BancoDeIdeiasController> {
  const RecordTextField({
    super.key,
    required this.field,
    required this.textController,
    required this.enabled,
  });

  final CrudField field;
  final TextEditingController textController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final multiline = field.type == CrudFieldType.multiline;

    return TextFormField(
      controller: textController,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: field.label.tr,
        border: const OutlineInputBorder(),
      ),
      minLines: multiline ? 3 : 1,
      maxLines: multiline ? 5 : 1,
      textInputAction: multiline
          ? TextInputAction.newline
          : TextInputAction.next,
      validator: (value) {
        if (field.required && (value == null || value.trim().isEmpty)) {
          return 'bdi_informe_campo'.trParams({
            'field': field.label.tr.toLowerCase(),
          });
        }
        return null;
      },
    );
  }
}
