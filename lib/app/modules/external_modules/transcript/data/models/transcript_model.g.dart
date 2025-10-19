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
      disciplinas: (fields[4] as List?)?.cast<TranscriptDiscipline>(),
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
