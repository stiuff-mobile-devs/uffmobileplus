import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

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
    String? id,
    this.idCampus,
    this.campus,
    DateTime? entryTime,
    this.idUffOperator,
    this.idUffUser,
    this.processed = false,
  }) : id = id ?? Uuid().v4(),
       entryTime = entryTime ?? DateTime.now();

  factory OperatorTransactionOffline.fromJson(Map<String, dynamic> json) {
    return OperatorTransactionOffline(
      id: (json['id'] as String?) ?? Uuid().v4(),
      idCampus: json['idCampus'] != null ? json['idCampus'] as String : null,
      campus: json['campus'] != null ? json['campus'] as String : null,
      entryTime: _parseEntryTime(json['entryTime']),
      idUffOperator: json['idUffOperator'] != null
          ? json['idUffOperator'] as String
          : null,
      idUffUser: json['idUffUser'] != null ? json['idUffUser'] as String : null,
      processed: json['processed'] == true || json['processed'] == 1,
    );
  }

  static DateTime _parseEntryTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.parse(value);
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    throw FormatException('entryTime inválido: $value');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idCampus': idCampus,
      'campus': campus,
      'entryTime': entryTime,
      'idUffOperator': idUffOperator,
      'idUffUser': idUffUser,
      'processed': processed,
    };
  }
}
