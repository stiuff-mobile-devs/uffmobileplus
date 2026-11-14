import 'package:shared_preferences/shared_preferences.dart';

/// Lembra o município e a rota escolhidos para abrir o BusUFF onde o usuário
/// parou.
class BusuffPreferences {
  static const String _municipioKey = 'busuff_municipio';
  static const String _routeKey = 'busuff_rota';

  Future<(String?, int)> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_municipioKey), prefs.getInt(_routeKey) ?? 0);
  }

  Future<void> save(String municipioId, int routeIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_municipioKey, municipioId);
    await prefs.setInt(_routeKey, routeIndex);
  }
}
