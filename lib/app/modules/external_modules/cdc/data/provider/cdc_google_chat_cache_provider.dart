import 'package:hive_flutter/hive_flutter.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/models/cdc_chat_room_model.dart';

/// Última lista de salas do Google Chat, guardada no aparelho (Hive) por
/// usuário: a tela abre na hora e funciona sem internet.
class CdcGoogleChatCacheProvider {
  static const String _boxName = 'cdc_salas_google_chat';

  Future<Box> _box() async => Hive.isBoxOpen(_boxName)
      ? Hive.box(_boxName)
      : await Hive.openBox(_boxName);

  Future<List<CdcChatRoomModel>> read(String userKey) async {
    final raw = (await _box()).get(userKey);
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (m) => CdcChatRoomModel(
            id: (m['id'] ?? '').toString(),
            name: (m['name'] ?? '').toString(),
            link: (m['link'] ?? '').toString(),
            type: '',
            allCourses: true,
            courses: const [],
            origin: CdcRoomOrigin.googleChat,
          ),
        )
        .where((r) => r.id.isNotEmpty && r.hasRequiredFields())
        .toList();
  }

  Future<void> save(String userKey, List<CdcChatRoomModel> rooms) async {
    await (await _box()).put(userKey, [
      for (final r in rooms) {'id': r.id, 'name': r.name, 'link': r.link},
    ]);
  }

  Future<void> clear(String userKey) async => (await _box()).delete(userKey);
}
