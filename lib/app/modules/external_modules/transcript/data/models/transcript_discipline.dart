import 'package:hive/hive.dart';

part 'transcript_discipline.g.dart';

@HiveType(typeId: 22)
class TranscriptDiscipline {
  @HiveField(0)
  int? id;
  @HiveField(1)
  String? codigoDisciplina;
  @HiveField(2)
  int? cargahoraria;
  @HiveField(3)
  int? creditos;
  @HiveField(4)
  String? nome;
  @HiveField(5)
  String? frequencia;
  @HiveField(6)
  String? statusHistorico;
  @HiveField(7)
  String? nota;
  @HiveField(8)
  String? vs;
  @HiveField(9)
  int? anosemestre;

  TranscriptDiscipline({
    this.id,
    this.codigoDisciplina,
    this.cargahoraria,
    this.creditos,
    this.nome,
    this.frequencia,
    this.statusHistorico,
    this.nota,
    this.vs,
    this.anosemestre,
  });

  TranscriptDiscipline.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    codigoDisciplina = json['codigo_disciplina'];
    cargahoraria = json['cargahoraria'];
    creditos = json['creditos'];
    nome = json['nome'];
    frequencia = json['frequencia'];
    statusHistorico = json['status_historico'];
    nota = json['nota'];
    vs = json['vs'];
    anosemestre = json['anosemestre'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['codigo_disciplina'] = codigoDisciplina;
    data['cargahoraria'] = cargahoraria;
    data['creditos'] = creditos;
    data['nome'] = nome;
    data['frequencia'] = frequencia;
    data['status_historico'] = statusHistorico;
    data['nota'] = nota;
    data['vs'] = vs;
    data['anosemestre'] = anosemestre;
    return data;
  }
}
