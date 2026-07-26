import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/ideia.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/ideas/ui/widgets/idea_state_widgets.dart';

class IdeaList extends GetView<BancoDeIdeiasController> {
  const IdeaList({
    super.key,
    required this.future,
    required this.canDelete,
    required this.emptyMessage,
    required this.onRetry,
    required this.onOpenIdea,
    required this.onDeleteIdea,
    required this.onToggleFavorite,
    this.expand = true,
  });

  final Future<List<IdeiaResumo>> future;
  final bool canDelete;
  final String emptyMessage;
  final VoidCallback onRetry;
  final ValueChanged<IdeiaResumo> onOpenIdea;
  final ValueChanged<IdeiaResumo> onDeleteIdea;
  final ValueChanged<IdeiaResumo> onToggleFavorite;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final content = FutureBuilder<List<IdeiaResumo>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState();
        }

        if (snapshot.hasError) {
          return ErrorState(error: snapshot.error, onRetry: onRetry);
        }

        final ideias = snapshot.data ?? const [];
        if (ideias.isEmpty) {
          return EmptyState(message: emptyMessage);
        }

        return ListView.separated(
          itemCount: ideias.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ideia = ideias[index];
            return IdeaCard(
              ideia: ideia,
              canDelete: canDelete && ideia.podeAdministrar,
              onTap: () => onOpenIdea(ideia),
              onDelete: () => onDeleteIdea(ideia),
              onToggleFavorite: () => onToggleFavorite(ideia),
            );
          },
        );
      },
    );

    if (!expand) {
      return content;
    }

    return Expanded(child: content);
  }
}

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
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final detalhes = [
      ideia.tipo,
      ideia.estado,
      if ((ideia.tipoVinculo ?? '').isNotEmpty) ideia.tipoVinculo!,
      '${ideia.quantidadeSeguidores} seguidores',
    ].where((value) => value.isNotEmpty).join(' - ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 10,
            ),
            leading: CircleAvatar(
              backgroundColor: AppColors.lightBlue(alpha: 46),
              foregroundColor: Colors.white,
              child: const Icon(Icons.lightbulb_outline_rounded),
            ),
            title: Text(
              ideia.titulo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ideia.descricao.isNotEmpty)
                  Text(
                    ideia.descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                if (detalhes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      detalhes,
                      style: TextStyle(
                        color: AppColors.lightBlue(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!ideia.podeAdministrar)
                  IconButton(
                    tooltip: ideia.favorita
                        ? 'Remover dos favoritos'
                        : 'Favoritar ideia',
                    onPressed: onToggleFavorite,
                    color: ideia.favorita ? Colors.amberAccent : Colors.white70,
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
                    color: Colors.redAccent,
                    icon: const Icon(Icons.delete_outline_rounded),
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white70,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
