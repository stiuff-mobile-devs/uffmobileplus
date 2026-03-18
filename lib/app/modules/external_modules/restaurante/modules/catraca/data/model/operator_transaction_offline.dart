import 'package:hive/hive.dart';

part 'operator_transaction_offline.g.dart';

@HiveType(typeId: 40)
class OperatorTransactionOffline {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? idCampus;

  @HiveField(2)
  String? campus;

  @HiveField(3)
  DateTime entryTime;

  @HiveField(4)
  String? idUffOperator;

  @HiveField(5)
  String? idUffUser;

  @HiveField(6)
  bool processed;

  OperatorTransactionOffline({
    required this.id,
    this.idCampus,
    this.campus,
    DateTime? entryTime,
    this.idUffOperator,
    this.idUffUser,
    this.processed = false,
  }) : entryTime = entryTime ?? DateTime.now();

  factory OperatorTransactionOffline.fromJson(Map<String, dynamic> json) {
    return OperatorTransactionOffline(
      id: json['id'] as String,
      idCampus: json['idCampus'] != null ? json['idCampus'] as String : null,
      campus: json['campus'] != null ? json['campus'] as String : null,
      entryTime: json['entryTime'] != null
          ? DateTime.parse(json['entryTime'] as String)
          : DateTime.now(),
      idUffOperator: json['idUffOperator'] != null
          ? json['idUffOperator'] as String
          : null,
      idUffUser: json['idUffUser'] != null ? json['idUffUser'] as String : null,
      processed: json['processed'] == true || json['processed'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idCampus': idCampus,
      'campus': campus,
      'entryTime': entryTime.toIso8601String(),
      'idUffOperator': idUffOperator,
      'idUffUser': idUffUser,
      'processed': processed,
    };
  }
}
