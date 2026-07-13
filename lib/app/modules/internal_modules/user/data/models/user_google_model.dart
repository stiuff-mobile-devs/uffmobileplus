import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'user_google_model.g.dart';

@HiveType(typeId: 17)
class UserGoogleModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String? urlImage;

  @HiveField(4)
  DateTime? createdAt;

  UserGoogleModel({
    this.id,
    this.name,
    required this.email,
    this.urlImage,
    this.createdAt,
  });

  factory UserGoogleModel.fromJson(Map<String, dynamic> json) {
    DateTime? formatedCreatedAt;

    if (json['createdAt'] != null) {
      formatedCreatedAt = _parseCreatedAtDateTime(json['createdAt']);
    }

    return UserGoogleModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String,
      urlImage: json['urlImage'] as String?,
      createdAt: formatedCreatedAt,
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
    if (dataFromFirebase is Timestamp) {
      return dataFromFirebase.toDate();
    } else if (dataFromFirebase is String) {
      return DateTime.tryParse(dataFromFirebase);
    } else if (dataFromFirebase is DateTime) {
      return dataFromFirebase;
    }
    return null;
  }
}
