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
  String? idOperator;

  @HiveField(5)
  String? idUser;

  @HiveField(6)
  bool? processed;

  @HiveField(7)
  bool? isSynced;

  @HiveField(8)
  bool? isIduff;

  OperatorTransactionOffline({
    String? id,
    this.idCampus,
    this.campus,
    DateTime? entryTime,
    this.idOperator,
    this.idUser,
    this.processed = false,
    this.isSynced = false,
    this.isIduff = false,
  }) : id = id ?? Uuid().v4(),
       entryTime = entryTime ?? DateTime.now();

  factory OperatorTransactionOffline.fromJson(Map<String, dynamic> json) {
    return OperatorTransactionOffline(
      id: json['id'],
      idCampus: json['idCampus'] != null ? json['idCampus'] as String : null,
      campus: json['campus'] != null ? json['campus'] as String : null,
      entryTime: _parseEntryTime(json['entryTime']),
      idOperator: json['idOperator'] != null
          ? json['idOperator'] as String
          : null,
      idUser: json['idUser'] != null ? json['idUser'] as String : null,
      processed: json['processed'] == true || json['processed'] == 1,
      isIduff: json['isIduff'] == true || json['isIduff'] == 1,
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
      'idOperator': idOperator,
      'idUser': idUser,
      'processed': processed,
      'isIduff': isIduff,
    };
  }

  OperatorTransactionOffline copyWith({
    String? id,
    String? idCampus,
    String? campus,
    DateTime? entryTime,
    String? idOperator,
    String? idUser,
    bool? processed,
    bool? isSynced,
    bool? isIduff,
  }) {
    return OperatorTransactionOffline(
      id: id ?? this.id,
      idCampus: idCampus ?? this.idCampus,
      campus: campus ?? this.campus,
      entryTime: entryTime ?? this.entryTime,
      idOperator: idOperator ?? this.idOperator,
      idUser: idUser ?? this.idUser,
      processed: processed ?? this.processed,
      isSynced: isSynced ?? this.isSynced,
      isIduff: isIduff ?? this.isIduff,
    );
  }
}
