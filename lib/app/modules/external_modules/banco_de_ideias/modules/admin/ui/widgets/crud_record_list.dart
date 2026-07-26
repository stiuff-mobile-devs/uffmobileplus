import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/crud_table.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/crud_api_service.dart';
import 'crud_record_card.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/admin/utils/crud_value_helpers.dart';

class CrudRecordList extends GetView<BancoDeIdeiasController> {
  const CrudRecordList({
    super.key,
    required this.table,
    required this.records,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
  });

  final CrudTable table;
  final List<CrudRecord> records;
  final Future<void> Function() onRefresh;
  final ValueChanged<CrudRecord> onEdit;
  final ValueChanged<CrudRecord> onDelete;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: records.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final record = records[index];
          return CrudRecordCard(
            index: index,
            record: record,
            table: table,
            title: crudRecordTitle(table, record),
            subtitle: crudRecordSubtitle(table, record),
            onEdit: () => onEdit(record),
            onDelete: () => onDelete(record),
          );
        },
      ),
    );
  }
}
