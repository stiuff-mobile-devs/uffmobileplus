import 'package:flutter/material.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/crud_table.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/crud_api_service.dart';
import 'record_form_content.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/admin/controller/record_form_controller.dart';
import 'record_form_dialog_view.dart';

class RecordFormDialog extends StatefulWidget {
  const RecordFormDialog({
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
  State<RecordFormDialog> createState() => _RecordFormDialogState();
}

class _RecordFormDialogState extends State<RecordFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final RecordFormController _controller;
  bool _isLoading = true, _isSaving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _controller = RecordFormController(
      widget.table,
      widget.record,
      widget.crudApiService,
    )..init();
    _loadOptions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    try {
      await _controller.loadOptions();
      if (mounted) setState(() => _isLoading = false);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSave(_controller.payload());
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) => RecordFormDialogView(
    title: widget.title,
    content: _content(),
    isSaving: _isSaving,
    canSave: !_isSaving && !_isLoading && _error == null,
    onCancel: () => Navigator.of(context).pop(false),
    onSave: _save,
  );
  Widget _content() => _isLoading
      ? const Center(child: CircularProgressIndicator())
      : _error != null
      ? Text(_error!)
      : RecordFormContent(
          formKey: _formKey,
          formController: _controller,
          isSaving: _isSaving,
          onSelectChanged: _setSelect,
        );
  void _setSelect(String name, String? value) => setState(
    () => _controller.selectValues[name] = value == '' ? null : value,
  );
}
