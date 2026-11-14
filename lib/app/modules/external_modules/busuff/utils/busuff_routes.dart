import 'package:latlong2/latlong.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/data/model/route_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/utils/polyline_points.dart';

/// Municípios e rotas do BusUFF. As placas batem com o campo `description`
/// da API (`BUSUFF Rota 1`, `BUSUFF Rota 2`).
const List<MunicipioModel> busuffMunicipios = [
  MunicipioModel(
    id: 'niteroi',
    name: 'Niterói',
    center: LatLng(-22.899163, -43.122786),
    routes: [
      RouteModel(
        number: 1,
        plate: 'LRN5595',
        itineraryImage: 'niteroi_1.jpeg',
        polyline: rota1,
      ),
      RouteModel(
        number: 2,
        plate: 'LMB7157',
        itineraryImage: 'niteroi_2.jpeg',
        polyline: rota2,
        dashedPolyline: pontilhado,
      ),
    ],
  ),
  MunicipioModel(
    id: 'campos',
    name: 'Campos dos Goytacazes',
    center: LatLng(-21.7545, -41.3244),
    routes: [
      RouteModel(number: 1, itineraryImage: 'campos_1.jpeg'),
      RouteModel(number: 2, itineraryImage: 'campos_2.jpeg'),
    ],
  ),
  MunicipioModel(
    id: 'padua',
    name: 'Santo Antônio de Pádua',
    center: LatLng(-21.5339815355232, -42.18628863683549),
    routes: [RouteModel(itineraryImage: 'padua.jpeg')],
  ),
  MunicipioModel(
    id: 'angra',
    name: 'Angra dos Reis',
    center: LatLng(-23.0067, -44.3181),
    routes: [RouteModel(itineraryImage: 'angra.jpeg')],
  ),
  MunicipioModel(
    id: 'volta_redonda',
    name: 'Volta Redonda',
    center: LatLng(-22.50617992579754, -44.09447740720085),
    routes: [RouteModel()],
  ),
];
