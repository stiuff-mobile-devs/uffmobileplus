import 'package:hive_flutter/hive_flutter.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/models/cdc_chat_room_model.dart';

/// Uma lista de salas guardada e quando foi buscada.
class CdcCachedRooms {
  final List<CdcChatRoomModel> rooms;

  /// `null` se nunca foi buscada com sucesso.
  final DateTime? updatedAt;

  const CdcCachedRooms({this.rooms = const [], this.updatedAt});
}

/// Salas guardadas no aparelho (Hive) por usuário: as oficiais (Firestore) e
/// as do Google Chat, cada uma com a data da última busca. A Central só busca
/// de novo depois de 24h ou quando o usuário pede para atualizar.
class CdcRoomsCacheProvider {
  static const String _boxName = 'cdc_salas';
  static const String official = 'oficiais';
  static const String googleChat = 'chat';

  Future<Box> _box() async => Hive.isBoxOpen(_boxName)
      ? Hive.box(_boxName)
      : await Hive.openBox(_boxName);

  /// [source] é [official] ou [googleChat].
  Future<CdcCachedRooms> read(String userKey, String source) async {
    final raw = (await _box()).get(userKey);
    if (raw is! Map) return const CdcCachedRooms();
    final list = raw[source];
    final rooms = list is List
        ? list
            .whereType<Map>()
            .map(CdcChatRoomModel.fromCacheMap)
            .where((r) => r.id.isNotEmpty && r.hasRequiredFields())
            .toList()
        : <CdcChatRoomModel>[];
    return CdcCachedRooms(
      rooms: rooms,
      updatedAt: DateTime.tryParse((raw['${source}Em'] ?? '').toString()),
    );
  }

  /// Guarda [rooms] de [source]. Sem [updatedAt], apaga a data (a próxima
  /// abertura busca de novo).
  Future<void> save(
    String userKey,
    String source,
    List<CdcChatRoomModel> rooms, {
    DateTime? updatedAt,
  }) async {
    final box = await _box();
    final raw = box.get(userKey);
    final data = raw is Map
        ? Map<String, dynamic>.from(raw.map((k, v) => MapEntry('$k', v)))
        : <String, dynamic>{};
    data[source] = [for (final r in rooms) r.toMap()];
    data['${source}Em'] = updatedAt?.toIso8601String();
    await box.put(userKey, data);
  }
}
