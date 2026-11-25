import 'package:uffmobileplus/app/modules/external_modules/cdc/data/models/cdc_chat_room_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/provider/cdc_archive_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/provider/cdc_provider.dart';

class CdcRepository {
  final CdcProvider _provider;
  final CdcArchiveProvider _archiveProvider;

  CdcRepository(this._provider, this._archiveProvider);

  /// Salas cadastradas pela CDC (todas; o filtro por curso fica no Service).
  Future<List<CdcChatRoomModel>> getCdcRooms() => _provider.getChatRooms();

  Future<Set<String>> getArchivedKeys(String userKey) =>
      _archiveProvider.getArchivedKeys(userKey);

  Future<void> saveArchivedKeys(String userKey, Set<String> keys) =>
      _archiveProvider.saveArchivedKeys(userKey, keys);
}
