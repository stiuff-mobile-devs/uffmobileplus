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
      title: const Text('Filtrar ideias'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tituloController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _aplicar(),
              decoration: const InputDecoration(
                labelText: 'Titulo',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            _OptionField(
              label: 'Tipo',
              icon: Icons.category_outlined,
              value: _tipoId,
              options: widget.tipos,
              onChanged: (value) => setState(() => _tipoId = value),
            ),
            const SizedBox(height: 14),
            _OptionField(
              label: 'Categoria',
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
          child: const Text('Cancelar'),
        ),
        TextButton.icon(
          onPressed: _limpar,
          icon: const Icon(Icons.filter_alt_off_outlined),
          label: const Text('Limpar'),
        ),
        FilledButton.icon(
          onPressed: _aplicar,
          icon: const Icon(Icons.filter_list_rounded),
          label: const Text('Filtrar'),
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
        const DropdownMenuItem<String>(value: null, child: Text('Todos')),
        if (!hasSelectedOption)
          DropdownMenuItem<String>(
            value: value,
            enabled: false,
            child: const Text('Carregando selecao...'),
          ),
        for (final option in options)
          DropdownMenuItem<String>(value: option.id, child: Text(option.nome)),
      ],
      onChanged: onChanged,
    );
  }
}
