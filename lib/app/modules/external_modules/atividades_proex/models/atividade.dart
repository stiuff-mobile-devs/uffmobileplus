class Atividade {
  final String idAtividade;
  final String titulo;
  final int? vagasDisponiveis;  
  final int? cargaHoraria;
  final String? detalhes;
  final String? coordenacao;
  final String? descricaoResumida;
  //final String? descricaoCompleta;
  final String linkInscricao;
  final String? tipo;

  Atividade({
    required this.idAtividade,
    required this.titulo,
    this.vagasDisponiveis,
    this.cargaHoraria,
    this.detalhes,
    this.coordenacao,
    //this.descricaoCompleta,
    this.descricaoResumida,
    required this.linkInscricao,
    this.tipo
  });


factory Atividade.fromJson(Map<String, dynamic> json) {
  final link = json['link_inscricao'] ?? '';
  final id = link.contains('?curso=') ? link.split('?curso=').last : '';

  String classificarTipo(String titulo) {
    titulo = titulo.toLowerCase();
    if (titulo.contains('curso')) return 'Curso';
    if (titulo.contains('oficina')) return 'Oficina';
    if (titulo.contains('congresso')) return 'Congresso';
    if (titulo.contains('palestra')) return 'Palestra';
    if (titulo.contains('grupo de estudo')) return 'Grupo de estudo';
    if (titulo.contains('roda de conversa')) return 'Roda de Conversa';
    if (titulo.contains('seminário') || titulo.contains('seminario')) return 'Seminário';
    if (titulo.contains('conferência') || titulo.contains('conferencia')) return 'Conferência';
    if (titulo.contains('mesa redonda')) return 'Mesa Redonda';
    if (titulo.contains('simpósio') || titulo.contains('simposio')) return 'Simpósio';
    if (titulo.contains('visita técnica') || titulo.contains('visita tecnica')) return 'Visita Técnica';
    return 'Outro';
  }

  return Atividade(
    idAtividade: id,
    titulo: json['titulo'] ?? 'Sem título',
    vagasDisponiveis: json['vagas_disponiveis'] != null ? json['vagas_disponiveis'] as int : null,
    cargaHoraria: json['carga_horaria'] != null ? json['carga_horaria'] as int : null,
    detalhes: json['detalhes'],
    coordenacao: json['coordenacao'],
    descricaoResumida: json['descricao_resumida'],
    linkInscricao: link,
    tipo: classificarTipo(json['titulo'] ?? ''),
  );
}
}
