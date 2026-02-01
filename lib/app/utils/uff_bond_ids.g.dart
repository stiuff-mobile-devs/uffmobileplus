// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uff_bond_ids.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileTypesAdapter extends TypeAdapter<ProfileTypes> {
  @override
  final int typeId = 32;

  @override
  ProfileTypes read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProfileTypes.anonymous;
      case 1:
        return ProfileTypes.grad;
      case 2:
        return ProfileTypes.pos;
      case 3:
        return ProfileTypes.teacher;
      case 4:
        return ProfileTypes.employee;
      case 5:
        return ProfileTypes.outsourced;
      default:
        return ProfileTypes.anonymous;
    }
  }

  @override
  void write(BinaryWriter writer, ProfileTypes obj) {
    switch (obj) {
      case ProfileTypes.anonymous:
        writer.writeByte(0);
        break;
      case ProfileTypes.grad:
        writer.writeByte(1);
        break;
      case ProfileTypes.pos:
        writer.writeByte(2);
        break;
      case ProfileTypes.teacher:
        writer.writeByte(3);
        break;
      case ProfileTypes.employee:
        writer.writeByte(4);
        break;
      case ProfileTypes.outsourced:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileTypesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
