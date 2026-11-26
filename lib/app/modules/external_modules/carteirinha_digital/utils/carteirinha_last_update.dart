import 'package:shared_preferences/shared_preferences.dart';
import 'package:uffmobileplus/app/data/services/crash_reporter.dart';

/// Quando o QR code da carteirinha foi atualizado pela última vez no SACI,
/// guardado no aparelho por usuário. Aparece na tela de informações.
class CarteirinhaLastUpdate {
  CarteirinhaLastUpdate._();

  static const String _prefix = 'carteirinha_qr_atualizado_';

  /// [userKey] é o `getUserStorageKey()` do usuário; sem ele não guarda.
  static Future<void> save(String? userKey, DateTime when) async {
    if (userKey == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix$userKey', when.toIso8601String());
    } catch (e, s) {
      CrashReporter.recordError(
        e,
        s,
        reason: 'salvar data de atualização da carteirinha',
      );
    }
  }

  static Future<DateTime?> read(String? userKey) async {
    if (userKey == null) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString('$_prefix$userKey');
      return value == null ? null : DateTime.tryParse(value);
    } catch (e, s) {
      CrashReporter.recordError(
        e,
        s,
        reason: 'ler data de atualização da carteirinha',
      );
      return null;
    }
  }
}
