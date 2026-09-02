import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/ideia.dart';

enum IdeaLinkFilter {
  minhasIdeias('bdi_minhas_ideias', Icons.account_circle_outlined, {'dono'}),
  ideiasFavoritas('bdi_ideias_favoritas', Icons.star_outline_rounded, {
    'seguidor',
  }),
  ideiasParticipantes('bdi_ideias_participantes', Icons.groups_outlined, {
    'membro',
  });

  const IdeaLinkFilter(this.labelKey, this.icon, this.vinculos);

  final String labelKey;
  final IconData icon;
  final Set<String> vinculos;

  String get label => labelKey.tr;

  bool matches(IdeiaResumo ideia) {
    final vinculo = (ideia.tipoVinculo ?? '').trim().toLowerCase();
    return vinculos.contains(vinculo);
  }
}
