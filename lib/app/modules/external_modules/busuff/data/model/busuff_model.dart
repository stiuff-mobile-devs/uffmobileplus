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
    // created_at vem em UTC ("...Z"); toLocal mantém o instante correto para
    // calcular há quanto tempo a posição foi enviada.
    timestamp = DateTime.parse(json['created_at']).toLocal();
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'speed': speed,
      'speed_accuracy': speedAccuracy,
      'heading': heading,
      'timestamp': timestamp,
    };
  }
}
