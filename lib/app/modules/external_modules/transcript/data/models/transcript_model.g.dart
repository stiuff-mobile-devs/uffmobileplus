// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcript_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TranscriptModelAdapter extends TypeAdapter<TranscriptModel> {
  @override
  final int typeId = 23;

  @override
  TranscriptModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TranscriptModel(
      transcript: fields[0] as Transcript?,
    );
  }

  @override
  void write(BinaryWriter writer, TranscriptModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.transcript);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TranscriptAdapter extends TypeAdapter<Transcript> {
  @override
  final int typeId = 24;

  @override
  Transcript read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transcript(
      cr: fields[0] as String?,
      chCursada: fields[1] as int?,
      chTotal: fields[2] as int?,
      situacaoAluno: fields[3] as String?,
      disciplinas: (fields[4] as List?)?.cast<Disciplinas>(),
    );
  }

  @override
  void write(BinaryWriter writer, Transcript obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cr)
      ..writeByte(1)
      ..write(obj.chCursada)
      ..writeByte(2)
      ..write(obj.chTotal)
      ..writeByte(3)
      ..write(obj.situacaoAluno)
      ..writeByte(4)
      ..write(obj.disciplinas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DisciplinasAdapter extends TypeAdapter<Disciplinas> {
  @override
  final int typeId = 25;

  @override
  Disciplinas read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Disciplinas(
      id: fields[0] as int?,
      codigoDisciplina: fields[1] as String?,
      cargahoraria: fields[2] as int?,
      creditos: fields[3] as int?,
      nome: fields[4] as String?,
      frequencia: fields[5] as String?,
      statusHistorico: fields[6] as String?,
      nota: fields[7] as String?,
      vs: fields[8] as String?,
      anosemestre: fields[9] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Disciplinas obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.codigoDisciplina)
      ..writeByte(2)
      ..write(obj.cargahoraria)
      ..writeByte(3)
      ..write(obj.creditos)
      ..writeByte(4)
      ..write(obj.nome)
      ..writeByte(5)
      ..write(obj.frequencia)
      ..writeByte(6)
      ..write(obj.statusHistorico)
      ..writeByte(7)
      ..write(obj.nota)
      ..writeByte(8)
      ..write(obj.vs)
      ..writeByte(9)
      ..write(obj.anosemestre);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisciplinasAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
