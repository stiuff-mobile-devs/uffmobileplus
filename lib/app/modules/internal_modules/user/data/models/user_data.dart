import 'package:hive/hive.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';

part 'user_data.g.dart';

@HiveType(typeId: 18)
class UserData extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  String? nomesocial;

  @HiveField(2)
  String? matricula;

  @HiveField(3)
  String? iduff;

  @HiveField(4)
  String? curso;

  @HiveField(5)
  String? fotoUrl;

  @HiveField(6)
  String? dataValidadeMatricula;

  @HiveField(7)
  String? bond;

  @HiveField(8)
  String? textoQrCodeCarteirinha;

  @HiveField(9)
  String? accessToken;

  @HiveField(10)
  String? bondId;

  @HiveField(11)
  List<GdiGroups>? gdiGroups;

  @HiveField(12)
  ProfileTypes? profileType;

  @HiveField(13)
  List<String>? shortcutRoutes;

  @HiveField(14)
  GdiGroupsGoogle? gdiGroupsGoogle;

  @HiveField(15)
  DateTime? lastRegisteredTokenCdcUpdate;

  @HiveField(16)
  String? lastRegisteredTokenCdcMethod;

  @HiveField(17)
  UserGoogleModel? userGoogleModel;

  @HiveField(18)
  UserIduffModel? userIduffModel;

  UserData({
    this.name,
    this.nomesocial,
    this.matricula,
    this.iduff,
    this.curso,
    this.fotoUrl,
    this.dataValidadeMatricula,
    this.bond,
    this.textoQrCodeCarteirinha,
    this.accessToken,
    this.bondId,
    this.gdiGroups,
    this.profileType,
    this.shortcutRoutes,
    this.gdiGroupsGoogle,
    this.lastRegisteredTokenCdcUpdate,
    this.lastRegisteredTokenCdcMethod,
    this.userGoogleModel,
    this.userIduffModel,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    ProfileTypes? parseProfileType(String? typeStr) {
      if (typeStr == null) return null;
      try {
        return ProfileTypes.values.firstWhere(
          (e) => e.name == typeStr || e.toString() == 'ProfileTypes.$typeStr',
        );
      } catch (_) {
        return null;
      }
    }

    return UserData(
      name: json['name'] as String?,
      nomesocial: json['nomesocial'] as String?,
      matricula: json['matricula'] as String?,
      iduff: json['iduff'] as String?,
      curso: json['curso'] as String?,
      fotoUrl: json['fotoUrl'] as String?,
      dataValidadeMatricula: json['dataValidadeMatricula'] as String?,
      bond: json['bond'] as String?,
      textoQrCodeCarteirinha: json['textoQrCodeCarteirinha'] as String?,
      accessToken: json['accessToken'] as String?,
      bondId: json['bondId'] as String?,
      gdiGroups: json['gdiGroups'] != null
          ? List<GdiGroups>.from((json['gdiGroups'] as List).map((x) => GdiGroups.fromJson(x)))
          : null,
      profileType: parseProfileType(json['profileType'] as String?),
      shortcutRoutes: json['shortcutRoutes'] != null
          ? List<String>.from(json['shortcutRoutes'] as List)
          : null,
      gdiGroupsGoogle: json['gdiGroupsGoogle'] != null
          ? GdiGroupsGoogle.fromJson(Map<String, dynamic>.from(json['gdiGroupsGoogle']))
          : null,
          
      lastRegisteredTokenCdcUpdate: json['lastRegisteredTokenCdcUpdate'] != null ? _parseCreatedAtDateTime(json['lastRegisteredTokenCdcUpdate']) : null,
      lastRegisteredTokenCdcMethod: json['lastRegisteredTokenCdcMethod'] as String?,
      userGoogleModel: json['userGoogleModel'] != null 
          ? UserGoogleModel.fromJson(Map<String, dynamic>.from(json['userGoogleModel'])) 
          : null,
      userIduffModel: json['userIduffModel'] != null 
          ? UserIduffModel.fromJson(Map<String, dynamic>.from(json['userIduffModel'])) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nomesocial': nomesocial,
      'matricula': matricula,
      'iduff': iduff,
      'curso': curso,
      'fotoUrl': fotoUrl,
      'dataValidadeMatricula': dataValidadeMatricula,
      'bond': bond,
      'textoQrCodeCarteirinha': textoQrCodeCarteirinha,
      'accessToken': accessToken,
      'bondId': bondId,
      'gdiGroups': gdiGroups?.map((group) => group.toJson()).toList(),
      'profileType': profileType?.name,
      'shortcutRoutes': shortcutRoutes,
      'gdiGroupsGoogle': gdiGroupsGoogle?.toJson(),
      'lastRegisteredTokenCdcUpdate': lastRegisteredTokenCdcUpdate,
      'lastRegisteredTokenCdcMethod': lastRegisteredTokenCdcMethod,
      'userGoogleModel': userGoogleModel?.toJson(),
      'userIduffModel': userIduffModel?.toJson(),
    };
  }

  static DateTime? _parseCreatedAtDateTime(dynamic dataFromFirebase) {
    if (dataFromFirebase.runtimeType.toString() == 'Timestamp') {
      return dataFromFirebase.toDate();
    } else if (dataFromFirebase is String) {
      return DateTime.tryParse(dataFromFirebase);
    } else if (dataFromFirebase is DateTime) {
      return dataFromFirebase;
    }
    return null;
  }
}

@HiveType(typeId: 31)
class GdiGroups {
  @HiveField(0)
  String? gid;
  @HiveField(1)
  String? description;
  @HiveField(2)
  String? name;
  @HiveField(3)
  String? email;
  @HiveField(4)
  String? directMembersCount;

  // Construtor posicional (sem as chaves {})
  GdiGroups(this.gid, this.description, this.name, this.email, this.directMembersCount);

  factory GdiGroups.fromJson(Map<String, dynamic> json) {
    // Retornando os valores na ordem exata, sem nomear os parâmetros
    return GdiGroups(
      json['gid']?.toString() ?? json['id']?.toString(),
      json['descricao']?.toString(),                   
      json['name']?.toString(),                          
      json['email']?.toString(),                        
      json['directMembersCount']?.toString(),            
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gid': gid,
      'descricao': description,
      'name': name,
      'email': email,
      'directMembersCount': directMembersCount
    };
  }
}

@HiveType(typeId: 33)
class GdiGroupsGoogle {
  @HiveField(0)
  DateTime? lastUpdate;
  
  @HiveField(1)
  List<GdiGroups>? gdiGroups;

  // 1. Construtor posicional sem as chaves {}
  GdiGroupsGoogle(this.lastUpdate, this.gdiGroups);

  factory GdiGroupsGoogle.fromJson(Map<String, dynamic> json) {
    return GdiGroupsGoogle(
      // 2. Passando os argumentos na ordem exata do construtor, sem nomeá-los
      json['lastUpdate'] != null ? _parseCreatedAtDateTime(json['lastUpdate']) : null,
      json['gdiGroups'] != null
          ? List<GdiGroups>.from((json['gdiGroups'] as List).map((x) => GdiGroups.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastUpdate': lastUpdate?.toIso8601String(),
      'gdiGroups': gdiGroups?.map((group) => group.toJson()).toList(),
    };
  }

  static DateTime? _parseCreatedAtDateTime(dynamic dataFromFirebase) {
    if (dataFromFirebase.runtimeType.toString() == 'Timestamp') {
      return dataFromFirebase.toDate();
    } else if (dataFromFirebase is String) {
      return DateTime.tryParse(dataFromFirebase);
    } else if (dataFromFirebase is DateTime) {
      return dataFromFirebase;
    }
    return null;
  }
}

@HiveType(typeId: 17)
class UserGoogleModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String? urlImage;

  @HiveField(4)
  DateTime? createdAt;

  UserGoogleModel({
    this.id,
    this.name,
    this.email,
    this.urlImage,
    this.createdAt,
  });

  factory UserGoogleModel.fromJson(Map<String, dynamic> json) {
    return UserGoogleModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      urlImage: json['urlImage']?.toString(),
      createdAt: json['createdAt'] != null ? _parseCreatedAtDateTime(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'urlImage': urlImage,
      'createdAt': createdAt,
    };
  }

  static DateTime? _parseCreatedAtDateTime(dynamic dataFromFirebase) {
    if (dataFromFirebase.runtimeType.toString() == 'Timestamp') {
      return dataFromFirebase.toDate();
    } else if (dataFromFirebase is String) {
      return DateTime.tryParse(dataFromFirebase);
    } else if (dataFromFirebase is DateTime) {
      return dataFromFirebase;
    }
    return null;
  }
}

@HiveType(typeId: 0)
class UserIduffModel extends HiveObject {
  @HiveField(0)
  String? iduff;

  @HiveField(1)
  String? fullName;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String? photoUrl;

  @HiveField(4)
  String? registration;

  @HiveField(5)
  String? vinculacao;

  @HiveField(6)
  AuthIduffModel? authData;

  UserIduffModel({
    this.iduff,
    this.fullName,
    this.email,
    this.photoUrl,
    this.registration,
    this.vinculacao,
    this.authData,
  });

  factory UserIduffModel.fromJson(Map<String, dynamic> json) {
    return UserIduffModel(
      iduff: json['iduff']?.toString(),
      fullName: json['fullName']?.toString(),
      email: json['email']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      registration: json['registration']?.toString(),
      vinculacao: json['vinculacao']?.toString(),
      authData: json['authData'] != null ? AuthIduffModel.fromMap(Map<String, dynamic>.from(json['authData'])) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iduff': iduff,
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'registration': registration,
      'vinculacao': vinculacao,
      'authData': authData?.toMap(),
    };
  }
}

@HiveType(typeId: 1)
class AuthIduffModel extends HiveObject {
  @HiveField(0)
  final String? accessToken;

  @HiveField(1)
  final String? refreshToken;

  @HiveField(2)
  final int? accessTokenExpiration;

  @HiveField(3)
  final String? codeVerifier;

  @HiveField(4)
  final String? authorizationCode;

  @HiveField(5)
  final bool? isLogged;

  AuthIduffModel({
    this.accessToken,
    this.refreshToken,
    this.accessTokenExpiration = 0,
    this.codeVerifier,
    this.authorizationCode,
    this.isLogged = false,
  });

  factory AuthIduffModel.fromMap(Map<String, dynamic> map) {
    return AuthIduffModel(
      accessToken: map['accessToken']?.toString(),
      refreshToken: map['refreshToken']?.toString(),
      accessTokenExpiration: int.tryParse(map['accessTokenExpiration']?.toString() ?? '0') ?? 0,
      codeVerifier: map['codeVerifier']?.toString(),
      authorizationCode: map['authorizationCode']?.toString(),
      isLogged: map['isLogged'] == true || map['isLogged'] == 'true',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessTokenExpiration': accessTokenExpiration,
      'codeVerifier': codeVerifier,
      'authorizationCode': authorizationCode,
      'isLogged': isLogged,
    };
  }
}