import 'package:latlong2/latlong.dart';

/// Uma rota do BusUFF. Cada rota tem um único ônibus (os alunos falam
/// "o rota 1"), identificado pela [plate] na API de rastreio.
class RouteModel {
  /// Número da rota no município; `null` quando o município tem rota única.
  final int? number;

  /// Placa do ônibus desta rota; `null` quando a rota não é rastreada.
  final String? plate;

  /// Imagem do itinerário em `assets/busuff/images/rotas_busuff/`; vazio se
  /// ainda não existe.
  final String itineraryImage;

  final List<LatLng> polyline;

  /// Trechos opcionais do trajeto, desenhados pontilhados.
  final List<LatLng> dashedPolyline;

  const RouteModel({
    this.number,
    this.plate,
    this.itineraryImage = '',
    this.polyline = const [],
    this.dashedPolyline = const [],
  });

  bool get isTracked => plate != null;
  bool get hasItinerary => itineraryImage.isNotEmpty;
}

/// Município atendido pelo BusUFF, com as suas rotas.
class MunicipioModel {
  final String id;
  final String name;
  final LatLng center;
  final List<RouteModel> routes;

  const MunicipioModel({
    required this.id,
    required this.name,
    required this.center,
    required this.routes,
  });

  bool get isTracked => routes.any((r) => r.isTracked);
}
