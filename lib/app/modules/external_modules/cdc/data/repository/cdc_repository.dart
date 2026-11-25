import 'package:uffmobileplus/app/modules/external_modules/cdc/data/provider/cdc_archive_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/provider/cdc_google_chat_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/provider/cdc_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/provider/cdc_rooms_cache_provider.dart';

class CdcRepository {
  final CdcProvider _provider;
  final CdcArchiveProvider _archiveProvider;
  final CdcGoogleChatProvider _chatProvider;
  final CdcRoomsCacheProvider _cache;

  CdcRepository(
    this._provider,
    this._archiveProvider,
    this._chatProvider,
    this._cache,
  );

  // ---------------------------------------------------------------------------
  // Salas oficiais (Firestore)
  // ---------------------------------------------------------------------------

  Future<CdcCachedRooms> getCachedCdcRooms(String userKey) =>
      _cache.read(userKey, CdcRoomsCacheProvider.official);

  /// Busca no Firestore (todas; o filtro por curso fica no Service) e guarda.
  Future<CdcCachedRooms> fetchCdcRooms(String userKey) async {
    final rooms = await _provider.getChatRooms();
    final now = DateTime.now();
    await _cache.save(
      userKey,
      CdcRoomsCacheProvider.official,
      rooms,
      updatedAt: now,
    );
    return CdcCachedRooms(rooms: rooms, updatedAt: now);
  }

  // ---------------------------------------------------------------------------
  // Salas do Google Chat
  // ---------------------------------------------------------------------------

  /// Escopo do Google que a busca das salas do Chat precisa.
  String get googleChatScope => CdcGoogleChatProvider.scope;

  Future<CdcCachedRooms> getCachedGoogleChatRooms(String userKey) =>
      _cache.read(userKey, CdcRoomsCacheProvider.googleChat);

  /// Busca na API do Chat em nome do usuário e guarda.
  Future<CdcCachedRooms> fetchGoogleChatRooms(
    String userKey,
    Map<String, String> authHeaders,
  ) async {
    final rooms = await _chatProvider.getSpaces(authHeaders);
    final now = DateTime.now();
    await _cache.save(
      userKey,
      CdcRoomsCacheProvider.googleChat,
      rooms,
      updatedAt: now,
    );
    return CdcCachedRooms(rooms: rooms, updatedAt: now);
  }

  /// Sem conta ou sem permissão: apaga as salas do Chat guardadas.
  Future<void> clearGoogleChatRooms(String userKey) =>
      _cache.save(userKey, CdcRoomsCacheProvider.googleChat, const []);

  // ---------------------------------------------------------------------------
  // Arquivadas
  // ---------------------------------------------------------------------------

  Future<Set<String>> getArchivedKeys(String userKey) =>
      _archiveProvider.getArchivedKeys(userKey);

  Future<void> saveArchivedKeys(String userKey, Set<String> keys) =>
      _archiveProvider.saveArchivedKeys(userKey, keys);
}
