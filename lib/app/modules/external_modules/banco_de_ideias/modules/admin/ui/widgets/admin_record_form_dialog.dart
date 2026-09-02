import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/crud_table.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/crud_api_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/admin/utils/admin_crud_helpers.dart';

class AdminRecordFormDialog extends StatefulWidget {
  const AdminRecordFormDialog({
    super.key,
    required this.title,
    required this.table,
    required this.crudApiService,
    required this.onSave,
    this.record,
  });

  final String title;
  final CrudTable table;
  final CrudRecord? record;
  final CrudApiService crudApiService;
  final Future<void> Function(Map<String, dynamic> data) onSave;

  @override
  State<AdminRecordFormDialog> createState() => _AdminRecordFormDialogState();
}

class _AdminRecordFormDialogState extends State<AdminRecordFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _selectValues = {};
  final Map<String, List<CrudRecord>> _options = {};
  bool _isLoadingOptions = true;
  bool _isSaving = false;
  String? _optionsError;

  @override
  void initState() {
    super.initState();

    for (final field in widget.table.fields) {
      final initialValue = _initialFieldValue(field);
      if (field.type == CrudFieldType.select) {
        _selectValues[field.name] = initialValue.isEmpty ? null : initialValue;
      } else {
        _controllers[field.name] = TextEditingController(text: initialValue);
      }
    }

    _loadOptions();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadOptions() async {
    try {
      for (final field in widget.table.fields) {
        if (field.type != CrudFieldType.select) {
          continue;
        }

        final path = field.optionsPath;
        final itemsKey = field.optionsItemsKey;
        if (path == null || itemsKey == null) {
          continue;
        }

        _options[field.name] = await widget.crudApiService.listOptions(
          path: path,
          itemsKey: itemsKey,
        );
      }

      if (!mounted) {
        return;
      }

      setState(() => _isLoadingOptions = false);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _optionsError = error.toString();
        _isLoadingOptions = false;
      });
    }
  }

  String _initialFieldValue(CrudField field) {
    final record = widget.record;
    if (record == null) {
      return '';
    }

    return formatCrudValue(
      readCrudValue(record.raw, field.recordPath ?? field.name),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.onSave(_buildPayload());
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.toString())));
      setState(() => _isSaving = false);
    }
  }

  Map<String, dynamic> _buildPayload() {
    final payload = <String, dynamic>{};

    for (final field in widget.table.fields) {
      final value = field.type == CrudFieldType.select
          ? _selectValues[field.name]
          : _controllers[field.name]!.text.trim();

      payload[field.name] = value == null || value.isEmpty ? null : value;
    }

    return payload;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(width: 520, child: _buildContent()),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: Text('cancelar'.tr),
        ),
        FilledButton.icon(
          onPressed: _isSaving || _isLoadingOptions || _optionsError != null
              ? null
              : _save,
          icon: _isSaving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_rounded),
          label: Text('salvar'.tr),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoadingOptions) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_optionsError != null) {
      return Text(_optionsError!);
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final field in widget.table.fields) ...[
              _buildField(field),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildField(CrudField field) {
    if (field.type == CrudFieldType.select) {
      final options = _options[field.name] ?? const <CrudRecord>[];

      return DropdownButtonFormField<String>(
        initialValue: _normalizedSelectValue(field, options),
        decoration: InputDecoration(
          labelText: field.label.tr,
          border: const OutlineInputBorder(),
        ),
        items: [
          if (!field.required)
            DropdownMenuItem<String>(value: '', child: Text('bdi_nenhum'.tr)),
          ...options.map(
            (option) => DropdownMenuItem<String>(
              value: option.id,
              child: Text(_optionLabel(field, option)),
            ),
          ),
        ],
        onChanged: _isSaving
            ? null
            : (value) {
                setState(() {
                  _selectValues[field.name] = value == '' ? null : value;
                });
              },
        validator: (value) {
          if (field.required && (value == null || value.isEmpty)) {
            return 'bdi_informe_campo'.trParams({
              'field': field.label.tr.toLowerCase(),
            });
          }
          return null;
        },
      );
    }

    return TextFormField(
      controller: _controllers[field.name],
      enabled: !_isSaving,
      decoration: InputDecoration(
        labelText: field.label.tr,
        border: const OutlineInputBorder(),
      ),
      minLines: field.type == CrudFieldType.multiline ? 3 : 1,
      maxLines: field.type == CrudFieldType.multiline ? 5 : 1,
      textInputAction: field.type == CrudFieldType.multiline
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

  String? _normalizedSelectValue(CrudField field, List<CrudRecord> options) {
    final value = _selectValues[field.name];
    if (value == null || value.isEmpty) {
      return field.required ? null : '';
    }

    final exists = options.any((option) => option.id == value);
    return exists ? value : (field.required ? null : '');
  }

  String _optionLabel(CrudField field, CrudRecord option) {
    final values = field.optionLabelPaths
        .map((path) => formatCrudValue(readCrudValue(option.raw, path)))
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    return values.isEmpty ? option.nome : values.join(' - ');
  }
}
