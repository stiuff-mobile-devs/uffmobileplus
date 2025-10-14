import 'package:hive/hive.dart';

part 'transcript_model.g.dart';

@HiveType(typeId: 23)
class TranscriptModel {
  @HiveField(0)
  Transcript? transcript;

  TranscriptModel({this.transcript});

  TranscriptModel.fromJson(Map<String, dynamic> json) {
    transcript = json['history'] != null ? Transcript.fromJson(json['history']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (transcript != null) {
      data['history'] = transcript!.toJson();
    }
    return data;
  }
}

@HiveType(typeId: 24)
class Transcript {
  @HiveField(0)
  String? cr;
  @HiveField(1)
  int? chCursada;
  @HiveField(2)
  int? chTotal;
  @HiveField(3)
  String? situacaoAluno;
  @HiveField(4)
  List<Disciplinas>? disciplinas;

  Transcript(
      {this.cr,
        this.chCursada,
        this.chTotal,
        this.situacaoAluno,
        this.disciplinas});

  Transcript.fromJson(Map<String, dynamic> json) {
    cr = json['cr'];
    chCursada = json['ch_cursada'];
    chTotal = json['ch_total'];
    situacaoAluno = json['situacao_aluno'];
    if (json['disciplinas'] != null) {
      disciplinas = <Disciplinas>[];
      json['disciplinas'].forEach((v) {
        disciplinas!.add(Disciplinas.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cr'] = cr;
    data['ch_cursada'] = chCursada;
    data['ch_total'] = chTotal;
    data['situacao_aluno'] = situacaoAluno;
    if (disciplinas != null) {
      data['disciplinas'] = disciplinas!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@HiveType(typeId: 25)
class Disciplinas {
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

  Disciplinas(
      {this.id,
        this.codigoDisciplina,
        this.cargahoraria,
        this.creditos,
        this.nome,
        this.frequencia,
        this.statusHistorico,
        this.nota,
        this.vs,
        this.anosemestre});

  Disciplinas.fromJson(Map<String, dynamic> json) {
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
