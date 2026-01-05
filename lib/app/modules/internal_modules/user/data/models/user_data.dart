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
    };
  }
}

@HiveType(typeId: 31)
class GdiGroups {
  @HiveField(0)
  String? gid; //Id do grupo
  @HiveField(1)
  String? description;

  GdiGroups(this.gid, this.description);

  GdiGroups.fromJson(Map<String, dynamic> json) {
    gid = json['gid'];
    description = json['descricao'];
  }

  @override
  String toString() {
    return "Group(gid: $gid, descicao: $description)";
  }
}
