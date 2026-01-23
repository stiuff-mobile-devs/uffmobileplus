import 'package:cloud_firestore/cloud_firestore.dart';

class UserLocationModel {
  double? lat;
  double? long;
  DateTime? timestamp;
  String? id;

  UserLocationModel({this.lat, this.long, this.timestamp, this.id});

  UserLocationModel.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    long = json['long'];
    timestamp = (json['timestamp'] as Timestamp).toDate();
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = lat;
    data['long'] = long;
    data['timestamp'] = timestamp != null
        ? Timestamp.fromDate(timestamp!)
        : null;
    data['id'] = id;
    return data;
  }
}
