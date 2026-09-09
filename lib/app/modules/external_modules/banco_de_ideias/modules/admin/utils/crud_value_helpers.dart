import 'package:get/get.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/crud_table.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/crud_api_service.dart';

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

String crudRecordKey(CrudTable table, CrudRecord record) {
  return table.keyPaths
      .map((path) => formatCrudValue(readCrudValue(record.raw, path)))
      .where((value) => value.isNotEmpty)
      .join(' / ');
}

String crudRecordTitle(CrudTable table, CrudRecord record) {
  final values = table.titlePaths
      .map((path) => formatCrudValue(readCrudValue(record.raw, path)))
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  return values.isEmpty ? record.nome : values.join(' - ');
}

String crudRecordSubtitle(CrudTable table, CrudRecord record) {
  final values = table.subtitleFields
      .map((field) {
        final value = formatCrudValue(readCrudValue(record.raw, field.path));
        return value.isEmpty ? '' : '${field.label.tr}: $value';
      })
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  final key = 'bdi_chave'.trParams({'value': crudRecordKey(table, record)});
  return values.isEmpty ? key : [...values, key].join('\n');
}

String crudOptionLabel(CrudField field, CrudRecord option) {
  final values = field.optionLabelPaths
      .map((path) => formatCrudValue(readCrudValue(option.raw, path)))
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  return values.isEmpty ? option.nome : values.join(' - ');
}
