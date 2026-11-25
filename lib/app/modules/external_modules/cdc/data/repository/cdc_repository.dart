import 'package:uffmobileplus/app/modules/external_modules/cdc/data/models/cdc_chat_room_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/provider/cdc_archive_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/provider/cdc_google_chat_cache_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/provider/cdc_google_chat_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/provider/cdc_provider.dart';

class CdcRepository {
  final CdcProvider _provider;
  final CdcArchiveProvider _archiveProvider;
  final CdcGoogleChatProvider _chatProvider;
  final CdcGoogleChatCacheProvider _chatCache;

  CdcRepository(
    this._provider,
    this._archiveProvider,
    this._chatProvider,
    this._chatCache,
  );

  /// Salas cadastradas pela CDC (todas; o filtro por curso fica no Service).
  Future<List<CdcChatRoomModel>> getCdcRooms() => _provider.getChatRooms();

  Future<Set<String>> getArchivedKeys(String userKey) =>
      _archiveProvider.getArchivedKeys(userKey);

  Future<void> saveArchivedKeys(String userKey, Set<String> keys) =>
      _archiveProvider.saveArchivedKeys(userKey, keys);

  /// Escopo do Google que a busca das salas do Chat precisa.
  String get googleChatScope => CdcGoogleChatProvider.scope;

  /// Busca as salas do Chat do usuário e atualiza o cache.
  Future<List<CdcChatRoomModel>> getGoogleChatRooms(
    String userKey,
    Map<String, String> authHeaders,
  ) async {
    final rooms = await _chatProvider.getSpaces(authHeaders);
    await _chatCache.save(userKey, rooms);
    return rooms;
  }

  Future<List<CdcChatRoomModel>> getCachedGoogleChatRooms(String userKey) =>
      _chatCache.read(userKey);

  Future<void> clearCachedGoogleChatRooms(String userKey) =>
      _chatCache.clear(userKey);
}
