import 'package:flutter/material.dart';

class CustomMultiSelectDropdown<T> extends StatefulWidget {
  final List<T> options;
  final List<T> selectedValues;
  final ValueChanged<List<T>> onChanged;
  final String Function(T) itemLabel;
  final String hintText;
  final String dialogTitle;
  final bool isValid;

  const CustomMultiSelectDropdown({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    required this.itemLabel,
    this.hintText = 'Selecione os itens',
    this.dialogTitle = 'Selecione os itens',
    this.isValid = true,
  });

  @override
  CustomMultiSelectDropdownState<T> createState() =>
      CustomMultiSelectDropdownState<T>();
}

class CustomMultiSelectDropdownState<T>
    extends State<CustomMultiSelectDropdown<T>> {
  late List<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = widget.selectedValues;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showMultiSelectDialog(context),
      child: InputDecorator(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          errorText: widget.isValid
              ? null
              : 'Por favor, selecione pelo menos um item', // Mensagem de erro
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedValues.isEmpty
                    ? widget.hintText
                    : _selectedValues.map(widget.itemLabel).join(', '),
                style: TextStyle(
                    color:
                        _selectedValues.isEmpty ? Colors.grey : Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: Color.fromARGB(157, 0, 0, 0),
            ),
          ],
        ),
      ),
    );
  }

  void _showMultiSelectDialog(BuildContext context) async {
    final selectedValues = await showDialog<List<T>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog<T>(
          options: widget.options,
          selectedValues: _selectedValues,
          itemLabel: widget.itemLabel,
          dialogTitle: widget.dialogTitle,
        );
      },
    );

    if (selectedValues != null) {
      setState(() {
        _selectedValues = selectedValues;
      });
      widget.onChanged(_selectedValues);
    }
  }
}

class MultiSelectDialog<T> extends StatefulWidget {
  final List<T> options;
  final List<T> selectedValues;
  final String Function(T) itemLabel;
  final String dialogTitle;

  const MultiSelectDialog({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.itemLabel,
    required this.dialogTitle,
  });

  @override
  MultiSelectDialogState<T> createState() => MultiSelectDialogState<T>();
}

class MultiSelectDialogState<T> extends State<MultiSelectDialog<T>> {
  late List<T> _tempSelectedValues;

  @override
  void initState() {
    super.initState();
    _tempSelectedValues = List.from(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.options.map((item) {
            return CheckboxListTile(
              value: _tempSelectedValues.contains(item),
              title: Text(widget.itemLabel(item)),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? checked) {
                setState(() {
                  if (checked!) {
                    _tempSelectedValues.add(item);
                  } else {
                    _tempSelectedValues.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.pop(context, _tempSelectedValues);
          },
        ),
      ],
    );
  }
}
