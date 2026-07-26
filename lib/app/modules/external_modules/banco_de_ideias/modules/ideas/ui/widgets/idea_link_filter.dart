import 'package:flutter/material.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/ideia.dart';

enum IdeaLinkFilter {
  minhasIdeias('Minhas Ideias', Icons.account_circle_outlined, {'dono'}),
  ideiasFavoritas('Ideias Favoritas', Icons.star_outline_rounded, {'seguidor'}),
  ideiasParticipantes('Ideias Participantes', Icons.groups_outlined, {
    'membro',
  });

  const IdeaLinkFilter(this.label, this.icon, this.vinculos);

  final String label;
  final IconData icon;
  final Set<String> vinculos;

  bool matches(IdeiaResumo ideia) {
    final vinculo = (ideia.tipoVinculo ?? '').trim().toLowerCase();
    return vinculos.contains(vinculo);
  }
}
