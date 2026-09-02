import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/admin/utils/admin_crud_helpers.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/admin/ui/widgets/admin_record_form_dialog.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/crud_table.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/crud_api_service.dart';

class AdminCrudTablePage extends StatefulWidget {
  AdminCrudTablePage({
    super.key,
    required this.table,
    CrudApiService? crudApiService,
  }) : crudApiService = crudApiService ?? CrudApiService();

  final CrudTable table;
  final CrudApiService crudApiService;

  @override
  State<AdminCrudTablePage> createState() => _AdminCrudTablePageState();
}

class _AdminCrudTablePageState extends State<AdminCrudTablePage> {
  List<CrudRecord> _records = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final records = await widget.crudApiService.listRecords(
        path: widget.table.path,
        itemsKey: widget.table.itemsKey,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openRecordForm([CrudRecord? record]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AdminRecordFormDialog(
        title: record == null
            ? 'bdi_novo_registro'.tr
            : 'bdi_editar_registro'.tr,
        table: widget.table,
        record: record,
        crudApiService: widget.crudApiService,
        onSave: (data) async {
          if (record == null) {
            await widget.crudApiService.createRecord(
              path: widget.table.path,
              data: data,
            );
          } else {
            await widget.crudApiService.updateRecord(
              table: widget.table,
              record: record,
              data: data,
            );
          }
        },
      ),
    );

    if (saved == true) {
      _showMessage(
        record == null
            ? 'bdi_registro_criado'.tr
            : 'bdi_registro_atualizado'.tr,
      );
      await _loadRecords();
    }
  }

  Future<void> _confirmDelete(CrudRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AdminDeleteRecordDialog(recordTitle: _recordTitle(record)),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await widget.crudApiService.deleteRecord(
        table: widget.table,
        record: record,
      );
      _showMessage('bdi_registro_excluido'.tr);
      await _loadRecords();
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _recordTitle(CrudRecord record) {
    final values = widget.table.titlePaths
        .map((path) => formatCrudValue(readCrudValue(record.raw, path)))
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    if (values.isEmpty) {
      return record.nome;
    }

    return values.join(' - ');
  }

  String _recordSubtitle(CrudRecord record) {
    final values = widget.table.subtitleFields
        .map((field) {
          final value = formatCrudValue(readCrudValue(record.raw, field.path));
          return value.isEmpty ? '' : '${field.label.tr}: $value';
        })
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    final chave = 'bdi_chave'.trParams({'value': _recordKey(record)});

    if (values.isEmpty) {
      return chave;
    }

    return [...values, chave].join('\n');
  }

  String _recordKey(CrudRecord record) {
    return widget.table.keyPaths
        .map((path) => formatCrudValue(readCrudValue(record.raw, path)))
        .where((value) => value.isNotEmpty)
        .join(' / ');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.table.title.tr),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
        actions: [
          IconButton(
            tooltip: 'atualizar'.tr,
            onPressed: _isLoading ? null : _loadRecords,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openRecordForm(),
        icon: const Icon(Icons.add_rounded),
        label: Text('novo'.tr),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: _buildBody(colorScheme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return AdminStateMessage(
        icon: Icons.error_outline_rounded,
        title: 'bdi_nao_foi_possivel_carregar_registros'.tr,
        message: _errorMessage!,
        action: FilledButton.icon(
          onPressed: _loadRecords,
          icon: const Icon(Icons.refresh_rounded),
          label: Text('tentar_novamente'.tr),
        ),
      );
    }

    if (_records.isEmpty) {
      return AdminStateMessage(
        icon: Icons.inventory_2_outlined,
        title: 'bdi_nenhum_registro_encontrado'.tr,
        message: 'bdi_crie_primeiro_item'.tr,
        action: FilledButton.icon(
          onPressed: () => _openRecordForm(),
          icon: const Icon(Icons.add_rounded),
          label: Text('bdi_novo_registro'.tr),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _records.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final record = _records[index];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  AppColors.mediumBlue(alpha: 36),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.lightBlue(alpha: 46),
                foregroundColor: Colors.white,
                child: Text('${index + 1}'),
              ),
              title: Text(
                _recordTitle(record),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                _recordSubtitle(record),
                style: const TextStyle(color: Colors.white70),
              ),
              isThreeLine: widget.table.subtitleFields.length > 1,
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: 'editar'.tr,
                    onPressed: () => _openRecordForm(record),
                    color: Colors.white70,
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton(
                    tooltip: 'excluir'.tr,
                    onPressed: () => _confirmDelete(record),
                    color: Colors.redAccent,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
