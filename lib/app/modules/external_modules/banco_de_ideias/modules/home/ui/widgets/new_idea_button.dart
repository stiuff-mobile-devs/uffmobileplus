import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/ideia_api_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/ideas/ui/widgets/idea_create_dialog.dart';

class NewIdeaButton extends GetView<BancoDeIdeiasController> {
  const NewIdeaButton({
    super.key,
    required this.ideiaApiService,
    required this.onIdeaCreated,
  });

  final IdeiaApiService ideiaApiService;
  final VoidCallback onIdeaCreated;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _openCreateDialog(context),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Nova ideia'),
    );
  }

  Future<void> _openCreateDialog(BuildContext context) async {
    final cadastrou = await showDialog<bool>(
      context: context,
      builder: (context) => IdeaCreateDialog(ideiaApiService: ideiaApiService),
    );

    if (!context.mounted || cadastrou != true) {
      return;
    }

    onIdeaCreated();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ideia cadastrada com sucesso.')),
    );
  }
}
