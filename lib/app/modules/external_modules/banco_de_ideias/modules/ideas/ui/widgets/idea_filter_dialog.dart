import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/ideia.dart';

class IdeaFilterDialog extends StatefulWidget {
  const IdeaFilterDialog({
    super.key,
    required this.filtro,
    required this.tipos,
    required this.categorias,
  });

  final IdeiaFiltro filtro;
  final List<IdeiaOpcao> tipos;
  final List<IdeiaOpcao> categorias;

  @override
  State<IdeaFilterDialog> createState() => _IdeaFilterDialogState();
}

class _IdeaFilterDialogState extends State<IdeaFilterDialog> {
  late final TextEditingController _tituloController;
  String? _tipoId;
  String? _categoriaId;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.filtro.nome);
    _tipoId = widget.filtro.tipoId;
    _categoriaId = widget.filtro.categoriaId;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  void _aplicar() {
    Navigator.of(context).pop(
      IdeiaFiltro(
        nome: _tituloController.text,
        tipoId: _tipoId,
        categoriaId: _categoriaId,
      ),
    );
  }

  void _limpar() {
    Navigator.of(context).pop(const IdeiaFiltro());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('bdi_filtrar_ideias'.tr),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tituloController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _aplicar(),
              decoration: InputDecoration(
                labelText: 'titulo'.tr,
                prefixIcon: const Icon(Icons.search_rounded),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            _OptionField(
              label: 'tipo'.tr,
              icon: Icons.category_outlined,
              value: _tipoId,
              options: widget.tipos,
              onChanged: (value) => setState(() => _tipoId = value),
            ),
            const SizedBox(height: 14),
            _OptionField(
              label: 'bdi_categoria'.tr,
              icon: Icons.sell_outlined,
              value: _categoriaId,
              options: widget.categorias,
              onChanged: (value) => setState(() => _categoriaId = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cancelar'.tr),
        ),
        TextButton.icon(
          onPressed: _limpar,
          icon: const Icon(Icons.filter_alt_off_outlined),
          label: Text('limpar'.tr),
        ),
        FilledButton.icon(
          onPressed: _aplicar,
          icon: const Icon(Icons.filter_list_rounded),
          label: Text('filtrar'.tr),
        ),
      ],
    );
  }
}

class _OptionField extends GetView<BancoDeIdeiasController> {
  const _OptionField({
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final String? value;
  final List<IdeiaOpcao> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final hasSelectedOption =
        value == null ||
        value!.isEmpty ||
        options.any((option) => option.id == value);

    return DropdownButtonFormField<String>(
      initialValue: value?.isEmpty == true ? null : value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem<String>(value: null, child: Text('todos'.tr)),
        if (!hasSelectedOption)
          DropdownMenuItem<String>(
            value: value,
            enabled: false,
            child: Text('bdi_carregando_selecao'.tr),
          ),
        for (final option in options)
          DropdownMenuItem<String>(value: option.id, child: Text(option.nome)),
      ],
      onChanged: onChanged,
    );
  }
}
