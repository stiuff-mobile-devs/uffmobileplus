import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/crud_table.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/crud_api_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/admin/controller/record_form_controller.dart';
import 'record_select_field.dart';
import 'record_text_field.dart';

class RecordFormContent extends GetView<BancoDeIdeiasController> {
  const RecordFormContent({
    super.key,
    required this.formKey,
    required this.formController,
    required this.isSaving,
    required this.onSelectChanged,
  });

  final GlobalKey<FormState> formKey;
  final RecordFormController formController;
  final bool isSaving;
  final void Function(String fieldName, String? value) onSelectChanged;

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final field in formController.table.fields) ...[
            _field(field),
            const SizedBox(height: 12),
          ],
        ],
      ),
    ),
  );

  Widget _field(CrudField field) {
    if (field.type != CrudFieldType.select) {
      return RecordTextField(
        field: field,
        textController: formController.controllers[field.name]!,
        enabled: !isSaving,
      );
    }
    return RecordSelectField(
      field: field,
      value: formController.selectValues[field.name],
      options: formController.options[field.name] ?? const <CrudRecord>[],
      enabled: !isSaving,
      onChanged: (value) => onSelectChanged(field.name, value),
    );
  }
}
