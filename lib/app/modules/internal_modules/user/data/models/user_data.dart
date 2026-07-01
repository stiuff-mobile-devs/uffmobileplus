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
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
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
          ? (json['gdiGroups'] as List)
                .map((group) => GdiGroups.fromJson(group))
                .toList()
          : null,
      profileType: json['profileType'] != null
          ? ProfileTypes.values.firstWhere(
              (e) => e.toString() == 'ProfileTypes.${json['profileType']}',
            )
          : null,
      shortcutRoutes: json['shortcutRoutes'] != null
          ? List<String>.from(json['shortcutRoutes'] as List)
          : null,
      gdiGroupsGoogle: json['gdiGroupsGoogle'] != null
          ? GdiGroupsGoogle.fromJson(json['gdiGroupsGoogle'])
          : null,
      lastRegisteredTokenCdcUpdate: json['lastRegisteredTokenCdcUpdate'] != null
          ? DateTime.parse(json['lastRegisteredTokenCdcUpdate'])
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
      'gdiGroups': gdiGroups
          ?.map((group) => {'gid': group.gid, 'descricao': group.description})
          .toList(),
      'profileType': profileType?.toString().split('.').last,
      'shortcutRoutes': shortcutRoutes,
      'gdiGroupsGoogle': gdiGroupsGoogle?.toJson(),
      'lastRegisteredTokenCdcUpdate':
          lastRegisteredTokenCdcUpdate?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserData(name: $name, nomesocial: $nomesocial, matricula: $matricula, iduff: $iduff, curso: $curso, dataValidadeMatricula: $dataValidadeMatricula, bond: $bond, textoQrCodeCarteirinha: $textoQrCodeCarteirinha,  bondId: $bondId, gdiGroups: $gdiGroups, gdiGroupsGoogle: $gdiGroupsGoogle, lastRegisteredTokenCdcUpdate: $lastRegisteredTokenCdcUpdate)';
  }
}

@HiveType(typeId: 31)
class GdiGroups {
  @HiveField(0)
  String? gid; //Id do grupo
  @HiveField(1)
  String? description;
  @HiveField(2)
  String? name;
  @HiveField(3)
  String? email;
  @HiveField(4)
  String? directMembersCount;

  GdiGroups(this.gid, this.description, this.name, this.email, this.directMembersCount);

  GdiGroups.fromJson(Map<String, dynamic> json) {
    gid = json['gid'] ?? json['id'];
    description = json['descricao'];
    name = json['name'];
    email = json['email'];
    directMembersCount = json['directMembersCount'];
  }

  @override
  String toString() {
    return "Group(gid: $gid, descicao: $description)";
  }

  Map<String, dynamic> toJson() {
    return {'gid': gid, 'descricao': description, 'name': name, 'email': email, 'directMembersCount': directMembersCount};
  }
}

@HiveType(typeId: 33)
class GdiGroupsGoogle {
  @HiveField(0)
  DateTime? lastUpdate;
  @HiveField(1)
  List<GdiGroups>? gdiGroups;

  GdiGroupsGoogle(this.lastUpdate, this.gdiGroups);

  GdiGroupsGoogle.fromJson(Map<String, dynamic> json) {
    lastUpdate = json['lastUpdate'] != null
        ? DateTime.parse(json['lastUpdate'])
        : null;
    gdiGroups = json['gdiGroups'] != null
        ? (json['gdiGroups'] as List)
              .map((group) => GdiGroups.fromJson(group))
              .toList()
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['lastUpdate'] = lastUpdate?.toIso8601String();

    data['gdiGroups'] = gdiGroups?.map((group) => group.toJson()).toList();

    return data;
  }
}
