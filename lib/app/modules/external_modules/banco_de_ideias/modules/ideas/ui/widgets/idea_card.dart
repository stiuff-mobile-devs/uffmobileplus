import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/ideia.dart';

class IdeaCard extends GetView<BancoDeIdeiasController> {
  const IdeaCard({
    super.key,
    required this.ideia,
    required this.canDelete,
    required this.onTap,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  final IdeiaResumo ideia;
  final bool canDelete;
  final VoidCallback onTap, onDelete, onToggleFavorite;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        child: const Icon(Icons.lightbulb_outline_rounded),
      ),
      title: Text(
        ideia.titulo,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: _IdeaCardSubtitle(ideia: ideia),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!ideia.podeAdministrar)
            IconButton(
              tooltip: ideia.favorita
                  ? 'Remover dos favoritos'
                  : 'Favoritar ideia',
              onPressed: onToggleFavorite,
              icon: Icon(
                ideia.favorita
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
              ),
            ),
          if (canDelete)
            IconButton(
              tooltip: 'Excluir ideia',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            )
          else
            const Icon(Icons.chevron_right_rounded),
        ],
      ),
      onTap: onTap,
    ),
  );
}

class _IdeaCardSubtitle extends GetView<BancoDeIdeiasController> {
  const _IdeaCardSubtitle({required this.ideia});
  final IdeiaResumo ideia;
  @override
  Widget build(BuildContext context) {
    final detalhes = [
      ideia.tipo,
      ideia.estado,
      if ((ideia.tipoVinculo ?? '').isNotEmpty) ideia.tipoVinculo!,
      '${ideia.quantidadeSeguidores} seguidores',
    ].where((v) => v.isNotEmpty).join(' - ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ideia.descricao.isNotEmpty)
          Text(ideia.descricao, maxLines: 2, overflow: TextOverflow.ellipsis),
        if (detalhes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              detalhes,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}
