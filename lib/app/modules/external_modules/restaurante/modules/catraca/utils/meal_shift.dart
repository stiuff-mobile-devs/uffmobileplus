/// Janelas de refeição usadas na checagem de duplicidade da catraca.
/// Almoço: 10:00–14:59. Jantar: 16:00–19:59.
const int _inicioAlmoco = 10;
const int _fimAlmoco = 15;
const int _inicioJanta = 16;
const int _fimJanta = 20;

bool _noAlmoco(DateTime t) => t.hour >= _inicioAlmoco && t.hour < _fimAlmoco;
bool _naJanta(DateTime t) => t.hour >= _inicioJanta && t.hour < _fimJanta;

/// `true` se [registro] conta como a mesma refeição que [tentativa]: mesmo
/// dia e mesmo turno. Fora das janelas, a tentativa nunca é duplicada.
bool isSameMealShift(DateTime registro, DateTime tentativa) {
  final mesmoDia =
      registro.year == tentativa.year &&
      registro.month == tentativa.month &&
      registro.day == tentativa.day;
  if (!mesmoDia) return false;
  if (_noAlmoco(tentativa)) return _noAlmoco(registro);
  if (_naJanta(tentativa)) return _naJanta(registro);
  return false;
}
