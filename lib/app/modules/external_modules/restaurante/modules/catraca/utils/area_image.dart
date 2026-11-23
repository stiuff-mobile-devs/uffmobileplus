import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/area.dart';

const String _imgDir = 'assets/restaurant/img';

/// Foto de cada área do SCTM, pelo id. Áreas sem foto (ex.: Coluni) ou novas
/// usam o logo da UFF.
const Map<int, String> _areaImages = {
  4: '$_imgDir/gr.png', // Gragoatá
  9: '$_imgDir/pv.png', // Praia Vermelha
  12: '$_imgDir/ve.png', // Veterinária
  13: '$_imgDir/hu.png', // HUAP
  14: '$_imgDir/re.png', // Reitoria
};

const String areaFallbackImage = '$_imgDir/uff_logo.png';

String areaImagePath(AreaModel area) =>
    _areaImages[area.id] ?? areaFallbackImage;
