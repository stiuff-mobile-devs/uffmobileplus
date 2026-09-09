import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/ideia.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/ideia_api_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/ideas/ui/widgets/idea_state_widgets.dart';

class IdeaDetailDialog extends StatefulWidget {
  const IdeaDetailDialog({
    super.key,
    required this.ideiaId,
    required this.ideiaApiService,
    required this.onEditIdea,
    required this.onDeleteIdea,
    required this.onToggleFavorite,
  });

  final String ideiaId;
  final IdeiaApiService ideiaApiService;
  final Future<bool> Function(IdeiaDetalhe detalhe) onEditIdea;
  final Future<bool> Function(IdeiaResumo ideia) onDeleteIdea;
  final Future<bool> Function(IdeiaResumo ideia) onToggleFavorite;

  @override
  State<IdeaDetailDialog> createState() => _IdeaDetailDialogState();
}

class _IdeaDetailDialogState extends State<IdeaDetailDialog> {
  late Future<IdeiaDetalhe> _detalheFuture;

  @override
  void initState() {
    super.initState();
    _detalheFuture = widget.ideiaApiService.buscarIdeia(widget.ideiaId);
  }

  void _recarregar() {
    setState(() {
      _detalheFuture = widget.ideiaApiService.buscarIdeia(widget.ideiaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('bdi_detalhes_ideia'.tr),
      content: SizedBox(
        width: 560,
        child: FutureBuilder<IdeiaDetalhe>(
          future: _detalheFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return DialogError(error: snapshot.error, onRetry: _recarregar);
            }

            final detalhe = snapshot.data;
            if (detalhe == null) {
              return SizedBox(
                height: 120,
                child: Center(child: Text('bdi_ideia_nao_encontrada'.tr)),
              );
            }

            return IdeaDetailContent(
              detalhe: detalhe,
              onEditIdea: () async {
                final editou = await widget.onEditIdea(detalhe);
                if (editou && mounted) {
                  _recarregar();
                }
              },
              onDeleteIdea: () async {
                final navigator = Navigator.of(context);
                final deletou = await widget.onDeleteIdea(detalhe.resumo);
                if (deletou && mounted) {
                  navigator.pop();
                }
              },
              onToggleFavorite: () async {
                final alterou = await widget.onToggleFavorite(detalhe.resumo);
                if (alterou && mounted) {
                  _recarregar();
                }
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('fechar'.tr),
        ),
      ],
    );
  }
}

class IdeaDetailContent extends GetView<BancoDeIdeiasController> {
  const IdeaDetailContent({
    super.key,
    required this.detalhe,
    required this.onEditIdea,
    required this.onDeleteIdea,
    required this.onToggleFavorite,
  });

  final IdeiaDetalhe detalhe;
  final Future<void> Function() onEditIdea;
  final Future<void> Function() onDeleteIdea;
  final Future<void> Function() onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final ideia = detalhe.resumo;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ideia.titulo,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 12),
          DetailField(label: 'bdi_descricao'.tr, value: ideia.descricao),
          DetailField(label: 'tipo'.tr, value: ideia.tipo),
          DetailField(label: 'estado'.tr, value: ideia.estado),
          DetailField(
            label: 'bdi_seguidores'.tr,
            value: ideia.quantidadeSeguidores.toString(),
          ),
          if (detalhe.categorias.isNotEmpty) ...[
            const SizedBox(height: 8),
            DetailSectionTitle('bdi_categorias'.tr),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final categoria in detalhe.categorias)
                  Chip(label: Text(categoria.nome)),
              ],
            ),
          ],
          if (detalhe.participantes.isNotEmpty) ...[
            const SizedBox(height: 16),
            DetailSectionTitle('bdi_participantes'.tr),
            const SizedBox(height: 6),
            for (final participante in detalhe.participantes)
              ParticipantTile(participante: participante),
          ],
          if (!ideia.podeAdministrar) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onToggleFavorite,
              icon: Icon(
                ideia.favorita
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
              ),
              label: Text(
                ideia.favorita
                    ? 'bdi_remover_favoritos'.tr
                    : 'bdi_favoritar_ideia'.tr,
              ),
            ),
          ],
          if (ideia.podeAdministrar) ...[
            const SizedBox(height: 16),
            DetailSectionTitle('bdi_administracao'.tr),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onEditIdea,
                  icon: const Icon(Icons.edit_rounded),
                  label: Text('editar'.tr),
                ),
                OutlinedButton.icon(
                  onPressed: onDeleteIdea,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text('excluir'.tr),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class DetailSectionTitle extends GetView<BancoDeIdeiasController> {
  const DetailSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF486581),
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class DetailField extends GetView<BancoDeIdeiasController> {
  const DetailField({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailSectionTitle(label),
          const SizedBox(height: 3),
          Text(value),
        ],
      ),
    );
  }
}

class ParticipantTile extends GetView<BancoDeIdeiasController> {
  const ParticipantTile({super.key, required this.participante});

  final IdeiaParticipante participante;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (participante.tipoVinculo.isNotEmpty) participante.tipoVinculo,
      if (participante.email.isNotEmpty) participante.email,
    ].join(' - ');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        child: const Icon(Icons.person_rounded),
      ),
      title: Text(participante.nome),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
    );
  }
}
