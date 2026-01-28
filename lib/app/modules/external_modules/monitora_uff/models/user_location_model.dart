import 'package:cloud_firestore/cloud_firestore.dart';

class UserLocationModel {
  String id;
  String? iduff;
  String? nome;
  double lat;
  double lng;
  DateTime timestamp;

  UserLocationModel({
    required this.id,
    required this.lat,
    required this.lng,
    required this.timestamp,
    this.iduff,
    this.nome,
  });

  UserLocationModel.fromJson(Map<String, dynamic> json)
    : id = json['id'].toString(),
      iduff = json['iduff']?.toString(),
      nome = json['nome']?.toString(),
      lat = (json['lat'] as num).toDouble(),
      lng = (json['lng'] as num).toDouble(),
      timestamp = (json['timestamp'] as Timestamp).toDate();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['iduff'] = iduff;
    data['nome'] = nome;
    data['lat'] = lat;
    data['lng'] = lng;
    data['timestamp'] = timestamp;
    return data;
  }
}
