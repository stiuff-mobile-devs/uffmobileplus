import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/crud_table.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/crud_api_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/admin/utils/crud_value_helpers.dart';

class RecordSelectField extends GetView<BancoDeIdeiasController> {
  const RecordSelectField({
    super.key,
    required this.field,
    required this.value,
    required this.options,
    required this.enabled,
    required this.onChanged,
  });

  final CrudField field;
  final String? value;
  final List<CrudRecord> options;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: _normalizedValue(),
      decoration: InputDecoration(
        labelText: field.label,
        border: const OutlineInputBorder(),
      ),
      items: [
        if (!field.required)
          const DropdownMenuItem<String>(value: '', child: Text('Nenhum')),
        for (final option in options)
          DropdownMenuItem<String>(
            value: option.id,
            child: Text(crudOptionLabel(field, option)),
          ),
      ],
      onChanged: enabled ? onChanged : null,
      validator: (value) {
        if (field.required && (value == null || value.isEmpty)) {
          return 'Informe ${field.label.toLowerCase()}.';
        }
        return null;
      },
    );
  }

  String? _normalizedValue() {
    if (value == null || value!.isEmpty) return field.required ? null : '';
    return options.any((option) => option.id == value) ? value : _emptyValue;
  }

  String? get _emptyValue => field.required ? null : '';
}
