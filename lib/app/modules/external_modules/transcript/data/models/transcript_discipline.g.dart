// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcript_discipline.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TranscriptDisciplineAdapter extends TypeAdapter<TranscriptDiscipline> {
  @override
  final int typeId = 22;

  @override
  TranscriptDiscipline read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TranscriptDiscipline(
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
  void write(BinaryWriter writer, TranscriptDiscipline obj) {
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
      other is TranscriptDisciplineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
