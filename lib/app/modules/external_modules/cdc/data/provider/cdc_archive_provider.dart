import 'package:hive_flutter/hive_flutter.dart';

/// Salas arquivadas, guardadas no aparelho (Hive) por usuário.
///
/// O Google Chat não tem "arquivar" para o usuário: arquivar só tira a sala
/// da lista principal da Central de Comunicação.
class CdcArchiveProvider {
  static const String _boxName = 'cdc_salas_arquivadas';

  Future<Box> _box() async => Hive.isBoxOpen(_boxName)
      ? Hive.box(_boxName)
      : await Hive.openBox(_boxName);

  Future<Set<String>> getArchivedKeys(String userKey) async {
    final box = await _box();
    final raw = box.get(userKey);
    if (raw is! List) return <String>{};
    return raw.map((e) => e.toString()).toSet();
  }

  Future<void> saveArchivedKeys(String userKey, Set<String> keys) async {
    final box = await _box();
    await box.put(userKey, keys.toList());
  }
}
