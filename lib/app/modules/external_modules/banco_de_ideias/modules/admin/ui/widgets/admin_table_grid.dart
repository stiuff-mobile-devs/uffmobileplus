import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/crud_table.dart';
import 'admin_table_card.dart';

class AdminTableGrid extends GetView<BancoDeIdeiasController> {
  const AdminTableGrid({
    super.key,
    required this.tables,
    required this.onOpenTable,
  });

  final List<CrudTable> tables;
  final ValueChanged<CrudTable> onOpenTable;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 760 ? 3 : 1;
      return GridView.builder(
        itemCount: tables.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: columns == 1 ? 3.8 : 1.45,
        ),
        itemBuilder: (context, index) {
          final table = tables[index];
          return AdminTableCard(table: table, onTap: () => onOpenTable(table));
        },
      );
    },
  );
}
