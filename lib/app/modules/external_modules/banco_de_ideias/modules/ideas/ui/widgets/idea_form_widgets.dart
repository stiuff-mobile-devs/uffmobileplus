import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/ideia.dart';

class IdeaFormScrollView extends GetView<BancoDeIdeiasController> {
  const IdeaFormScrollView({
    super.key,
    required this.formKey,
    required this.child,
  });

  final GlobalKey<FormState> formKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(child: child),
    );
  }
}

class IdeaStepProgress extends GetView<BancoDeIdeiasController> {
  const IdeaStepProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Etapa $currentStep de $totalSteps',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: currentStep / totalSteps),
      ],
    );
  }
}

class IdeaTextField extends GetView<BancoDeIdeiasController> {
  const IdeaTextField({
    super.key,
    required this.textController,
    required this.labelText,
    required this.validator,
    this.autofocus = false,
    this.minLines,
    this.maxLines = 1,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController textController;
  final String labelText;
  final FormFieldValidator<String> validator;
  final bool autofocus;
  final int? minLines;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      minLines: minLines,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
    );
  }
}

class IdeaOptionsDropdown extends GetView<BancoDeIdeiasController> {
  const IdeaOptionsDropdown({
    super.key,
    required this.labelText,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.validator,
  });

  final String labelText;
  final String? value;
  final List<IdeiaOpcao> options;
  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final option in options)
          DropdownMenuItem(
            value: option.id,
            child: Text(option.nome, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}

class IdeaCategoriesField extends GetView<BancoDeIdeiasController> {
  const IdeaCategoriesField({
    super.key,
    required this.categorias,
    required this.selectedIds,
    required this.enabled,
    required this.onChanged,
    required this.validator,
  });

  final List<IdeiaOpcao> categorias;
  final Set<String> selectedIds;
  final bool enabled;
  final void Function({
    required FormFieldState<Set<String>> field,
    required String categoriaId,
    required bool checked,
  })
  onChanged;
  final FormFieldValidator<Set<String>> validator;

  @override
  Widget build(BuildContext context) {
    return FormField<Set<String>>(
      initialValue: Set<String>.from(selectedIds),
      validator: validator,
      builder: (field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: 'Categorias',
            border: const OutlineInputBorder(),
            errorText: field.errorText,
          ),
          child: categorias.isEmpty
              ? const Text('Nenhuma categoria disponivel.')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final categoria in categorias)
                      FilterChip(
                        label: Text(categoria.nome),
                        selected: selectedIds.contains(categoria.id),
                        onSelected: enabled
                            ? (selected) {
                                onChanged(
                                  field: field,
                                  categoriaId: categoria.id,
                                  checked: selected,
                                );
                              }
                            : null,
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class IdeaDialogSecondaryButton extends GetView<BancoDeIdeiasController> {
  const IdeaDialogSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.enabled,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: destructive
          ? TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            )
          : null,
      child: Text(label),
    );
  }
}

class IdeaDialogPrimaryButton extends GetView<BancoDeIdeiasController> {
  const IdeaDialogPrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.loading,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(label),
    );
  }
}
