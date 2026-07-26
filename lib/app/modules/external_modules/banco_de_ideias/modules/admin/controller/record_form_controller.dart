import 'package:flutter/material.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/crud_table.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/crud_api_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/admin/utils/crud_value_helpers.dart';

class RecordFormController {
  RecordFormController(this.table, this.record, this.api);

  final CrudTable table;
  final CrudRecord? record;
  final CrudApiService api;
  final controllers = <String, TextEditingController>{};
  final selectValues = <String, String?>{};
  final options = <String, List<CrudRecord>>{};

  void init() {
    for (final field in table.fields) {
      final value = initialValue(field);
      if (field.type == CrudFieldType.select) {
        selectValues[field.name] = value.isEmpty ? null : value;
      } else {
        controllers[field.name] = TextEditingController(text: value);
      }
    }
  }

  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
  }

  Future<void> loadOptions() async {
    for (final field in table.fields) {
      final path = field.optionsPath;
      final key = field.optionsItemsKey;
      if (field.type == CrudFieldType.select && path != null && key != null) {
        options[field.name] = await api.listOptions(path: path, itemsKey: key);
      }
    }
  }

  String initialValue(CrudField field) => record == null
      ? ''
      : formatCrudValue(
          readCrudValue(record!.raw, field.recordPath ?? field.name),
        );

  Map<String, dynamic> payload() => {
    for (final field in table.fields)
      field.name: _emptyToNull(
        field.type == CrudFieldType.select
            ? selectValues[field.name]
            : controllers[field.name]!.text.trim(),
      ),
  };

  String? _emptyToNull(String? value) =>
      value == null || value.isEmpty ? null : value;
}
