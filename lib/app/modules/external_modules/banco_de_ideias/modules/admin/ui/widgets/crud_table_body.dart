import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/crud_table.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/crud_api_service.dart';
import 'admin_state_message.dart';
import 'crud_record_list.dart';

class CrudTableBody extends GetView<BancoDeIdeiasController> {
  const CrudTableBody({
    super.key,
    required this.table,
    required this.records,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
  });

  final CrudTable table;
  final List<CrudRecord> records;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRefresh;
  final VoidCallback onCreate;
  final ValueChanged<CrudRecord> onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) return _error();
    if (records.isEmpty) return _empty();
    return CrudRecordList(
      table: table,
      records: records,
      onRefresh: onRefresh,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }

  Widget _error() => AdminStateMessage(
    icon: Icons.error_outline_rounded,
    title: 'bdi_nao_foi_possivel_carregar_registros'.tr,
    message: errorMessage!,
    action: _action(Icons.refresh_rounded, 'tentar_novamente'.tr, () {
      onRefresh();
    }),
  );

  Widget _empty() => AdminStateMessage(
    icon: Icons.inventory_2_outlined,
    title: 'bdi_nenhum_registro_encontrado'.tr,
    message: 'bdi_crie_primeiro_item'.tr,
    action: _action(Icons.add_rounded, 'bdi_novo_registro'.tr, onCreate),
  );

  Widget _action(IconData icon, String label, VoidCallback onPressed) =>
      FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
}
