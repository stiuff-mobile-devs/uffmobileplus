import 'package:hive/hive.dart';

@HiveType(typeId: 30)
class Person {
  @HiveField(0)
  String? dn;
  @HiveField(1)
  List<String>? objectClass;
  @HiveField(2)
  String? uid;
  @HiveField(3)
  String? uidnumber;
  @HiveField(4)
  String? mail;
  @HiveField(5)
  String? description;
  @HiveField(6)
  String? givenName;
  @HiveField(7)
  String? cn;
  @HiveField(8)
  String? gidNumber;
  Person({
    this.dn,
    this.objectClass,
    this.uid,
    this.uidnumber,
    this.mail,
    this.description,
    this.givenName,
    this.cn,
    this.gidNumber,
  });

  Person.fromJson(Map<String, dynamic> json) {
    dn = json['dn']?[0];
    // print(json['objectclass']);
    uid = json['uid']?[0];
    uidnumber = json['uidnumber']?[0];
    mail = json['mail']?[0];
    description = json['descricao']?[0];
    givenName = json['givenname']?[0];
    cn = json['cn']?[0];
    gidNumber = json['gidnumber']?[0];
  }
}

@HiveType(typeId: 31)
class Group {
  @HiveField(0)
  String? gid;
  @HiveField(1)
  String? description;

  Group(this.gid, this.description);

  Group.fromJson(Map<String, dynamic> json) {
    gid = json['gid'];
    description = json['descricao'];
  }

  @override
  String toString() {
    return "Group(gid: $gid, descicao: $description)";
  }
}

@HiveType(typeId: 32)
class GroupList {
  @HiveField(0)
  List<Group> groups;

  GroupList(this.groups);
}