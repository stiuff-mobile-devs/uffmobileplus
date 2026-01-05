import 'package:hive/hive.dart';

part 'uff_bond_ids.g.dart';

class UffBondIds {
  static const String undergraduate_student = '1';
  static const String undergraduate_student_ead = '8';
  static const String post_doc_researcher_student = '12';
  static const String post_grad_student = '7';
  static const String teacher = '2';
  static const String outsourced = '5';
  static const String employee = '4';
}

@HiveType(typeId: 32)
enum ProfileTypes {
  @HiveField(0)
  anonymous,
  @HiveField(1)
  grad,
  @HiveField(2)
  pos,
  @HiveField(3)
  teacher,
  @HiveField(4)
  employee,
  @HiveField(5)
  outsourced,
}

List<ProfileTypes> everyoneLogged = [
  ProfileTypes.grad,
  ProfileTypes.pos,
  ProfileTypes.teacher,
  ProfileTypes.employee,
  ProfileTypes.outsourced,
];
List<ProfileTypes> everyone = [
  ProfileTypes.grad,
  ProfileTypes.pos,
  ProfileTypes.teacher,
  ProfileTypes.employee,
  ProfileTypes.outsourced,
  ProfileTypes.anonymous,
];
