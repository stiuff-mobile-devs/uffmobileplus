// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserDataAdapter extends TypeAdapter<UserData> {
  @override
  final int typeId = 18;

  @override
  UserData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserData(
      name: fields[0] as String?,
      nomesocial: fields[1] as String?,
      matricula: fields[2] as String?,
      iduff: fields[3] as String?,
      curso: fields[4] as String?,
      fotoUrl: fields[5] as String?,
      dataValidadeMatricula: fields[6] as String?,
      bond: fields[7] as String?,
      textoQrCodeCarteirinha: fields[8] as String?,
      accessToken: fields[9] as String?,
      bondId: fields[10] as String?,
      gdiGroups: (fields[11] as List?)?.cast<GdiGroups>(),
      profileType: fields[12] as ProfileTypes?,
      shortcutRoutes: (fields[13] as List?)?.cast<String>(),
      gdiGroupsGoogle: fields[14] as GdiGroupsGoogle?,
      lastRegisteredTokenCdcUpdate: fields[15] as DateTime?,
      lastRegisteredTokenCdcMethod: fields[16] as String?,
      userGoogleModel: fields[17] as UserGoogleModel?,
      userIduffModel: fields[18] as UserIduffModel?,
    );
  }

  @override
  void write(BinaryWriter writer, UserData obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.nomesocial)
      ..writeByte(2)
      ..write(obj.matricula)
      ..writeByte(3)
      ..write(obj.iduff)
      ..writeByte(4)
      ..write(obj.curso)
      ..writeByte(5)
      ..write(obj.fotoUrl)
      ..writeByte(6)
      ..write(obj.dataValidadeMatricula)
      ..writeByte(7)
      ..write(obj.bond)
      ..writeByte(8)
      ..write(obj.textoQrCodeCarteirinha)
      ..writeByte(9)
      ..write(obj.accessToken)
      ..writeByte(10)
      ..write(obj.bondId)
      ..writeByte(11)
      ..write(obj.gdiGroups)
      ..writeByte(12)
      ..write(obj.profileType)
      ..writeByte(13)
      ..write(obj.shortcutRoutes)
      ..writeByte(14)
      ..write(obj.gdiGroupsGoogle)
      ..writeByte(15)
      ..write(obj.lastRegisteredTokenCdcUpdate)
      ..writeByte(16)
      ..write(obj.lastRegisteredTokenCdcMethod)
      ..writeByte(17)
      ..write(obj.userGoogleModel)
      ..writeByte(18)
      ..write(obj.userIduffModel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GdiGroupsAdapter extends TypeAdapter<GdiGroups> {
  @override
  final int typeId = 31;

  @override
  GdiGroups read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GdiGroups(
      fields[0] as String?,
      fields[1] as String?,
      fields[2] as String?,
      fields[3] as String?,
      fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GdiGroups obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.gid)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.directMembersCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GdiGroupsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GdiGroupsGoogleAdapter extends TypeAdapter<GdiGroupsGoogle> {
  @override
  final int typeId = 33;

  @override
  GdiGroupsGoogle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GdiGroupsGoogle(
      fields[0] as DateTime?,
      (fields[1] as List?)?.cast<GdiGroups>(),
    );
  }

  @override
  void write(BinaryWriter writer, GdiGroupsGoogle obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.lastUpdate)
      ..writeByte(1)
      ..write(obj.gdiGroups);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GdiGroupsGoogleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserGoogleModelAdapter extends TypeAdapter<UserGoogleModel> {
  @override
  final int typeId = 17;

  @override
  UserGoogleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserGoogleModel(
      id: fields[0] as String?,
      name: fields[1] as String?,
      email: fields[2] as String?,
      urlImage: fields[3] as String?,
      createdAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserGoogleModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.urlImage)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserGoogleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserIduffModelAdapter extends TypeAdapter<UserIduffModel> {
  @override
  final int typeId = 0;

  @override
  UserIduffModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserIduffModel(
      iduff: fields[0] as String?,
      fullName: fields[1] as String?,
      email: fields[2] as String?,
      photoUrl: fields[3] as String?,
      registration: fields[4] as String?,
      vinculacao: fields[5] as String?,
      authData: fields[6] as AuthIduffModel?,
    );
  }

  @override
  void write(BinaryWriter writer, UserIduffModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.iduff)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.photoUrl)
      ..writeByte(4)
      ..write(obj.registration)
      ..writeByte(5)
      ..write(obj.vinculacao)
      ..writeByte(6)
      ..write(obj.authData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserIduffModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AuthIduffModelAdapter extends TypeAdapter<AuthIduffModel> {
  @override
  final int typeId = 1;

  @override
  AuthIduffModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthIduffModel(
      accessToken: fields[0] as String?,
      refreshToken: fields[1] as String?,
      accessTokenExpiration: fields[2] as int?,
      codeVerifier: fields[3] as String?,
      authorizationCode: fields[4] as String?,
      isLogged: fields[5] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, AuthIduffModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.accessToken)
      ..writeByte(1)
      ..write(obj.refreshToken)
      ..writeByte(2)
      ..write(obj.accessTokenExpiration)
      ..writeByte(3)
      ..write(obj.codeVerifier)
      ..writeByte(4)
      ..write(obj.authorizationCode)
      ..writeByte(5)
      ..write(obj.isLogged);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthIduffModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
