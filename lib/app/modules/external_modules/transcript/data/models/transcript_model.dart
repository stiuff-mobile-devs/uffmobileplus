import 'package:hive/hive.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/data/models/transcript_discipline.dart';

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
  List<TranscriptDiscipline>? disciplinas;

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
      disciplinas = <TranscriptDiscipline>[];
      json['disciplinas'].forEach((v) {
        disciplinas!.add(TranscriptDiscipline.fromJson(v));
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

