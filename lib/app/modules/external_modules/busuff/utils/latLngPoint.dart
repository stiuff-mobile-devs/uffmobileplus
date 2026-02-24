import 'package:latlong2/latlong.dart';

class LatLngPoint {
  String letter;
  late LatLng latLng;

  LatLngPoint(double latitude, double longitude, this.letter ) {
    latLng = LatLng(latitude, longitude);
  }
}