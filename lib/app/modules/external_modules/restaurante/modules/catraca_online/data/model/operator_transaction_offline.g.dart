// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operator_transaction_offline.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OperatorTransactionOfflineAdapter
    extends TypeAdapter<OperatorTransactionOffline> {
  @override
  final int typeId = 40;

  @override
  OperatorTransactionOffline read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OperatorTransactionOffline(
      id: fields[0] as String,
      idCampus: fields[1] as String?,
      campus: fields[2] as String?,
      entryTime: fields[3] as DateTime?,
      idUffOperator: fields[4] as String?,
      idUffUser: fields[5] as String?,
      processed: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OperatorTransactionOffline obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idCampus)
      ..writeByte(2)
      ..write(obj.campus)
      ..writeByte(3)
      ..write(obj.entryTime)
      ..writeByte(4)
      ..write(obj.idUffOperator)
      ..writeByte(5)
      ..write(obj.idUffUser)
      ..writeByte(6)
      ..write(obj.processed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperatorTransactionOfflineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
