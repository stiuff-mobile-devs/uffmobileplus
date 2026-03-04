class BusuffModel {
  double? latitude;
  double? longitude;
  double? altitude;
  double? accuracy;
  double? speed;
  double? speedAccuracy;
  double? heading;
  DateTime? timestamp;

  BusuffModel(
      {this.latitude,
        this.longitude,
        this.altitude,
        this.accuracy,
        this.speed,
        this.speedAccuracy,
        this.heading,
        this.timestamp});

  BusuffModel.fromJson(Map<String, dynamic> json) {
    latitude = double.parse(json['latitude']);
    longitude = double.parse(json['longitude']);
    altitude = double.parse(json['altitude']);
    accuracy = double.parse(json['accuracy']);
    speed = double.parse(json['speed']);
    speedAccuracy = (json['speed_accuracy'] as int).toDouble();
    heading = double.parse(json['heading']);
    timestamp = DateTime.parse(json['created_at']).add(const Duration(hours: -3));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['altitude'] = this.altitude;
    data['accuracy'] = this.accuracy;
    data['speed'] = this.speed;
    data['speed_accuracy'] = this.speedAccuracy;
    data['heading'] = this.heading;
    data['timestamp'] = this.timestamp;
    return data;
  }
}
