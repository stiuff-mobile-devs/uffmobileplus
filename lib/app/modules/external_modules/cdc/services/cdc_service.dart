import 'package:uffmobileplus/app/modules/external_modules/cdc/data/models/cdc_chat_room_model.dart';

/// Filtros da aba Salas.
enum CdcRoomFilter { all, archived }

/// Salas já separadas por seção, na ordem da tela.
class CdcRoomSections {
  final List<CdcChatRoomModel> required;
  final List<CdcChatRoomModel> cdc;
  final List<CdcChatRoomModel> mine;
  final List<CdcChatRoomModel> archived;

  const CdcRoomSections({
    this.required = const [],
    this.cdc = const [],
    this.mine = const [],
    this.archived = const [],
  });

  bool get isEmpty =>
      required.isEmpty && cdc.isEmpty && mine.isEmpty && archived.isEmpty;

  /// Em Todas, as obrigatórias vêm sempre primeiro.
  List<CdcChatRoomModel> of(CdcRoomFilter filter) => switch (filter) {
        CdcRoomFilter.all => [...required, ...cdc, ...mine],
        CdcRoomFilter.archived => archived,
      };
}

/// Regras da Central de Comunicação: quais salas o usuário vê, em que seção
/// e em que ordem.
class CdcService {
  /// - Salas da CDC: só as do curso do usuário (ou de todos os cursos).
  /// - Uma sala da CDC que também é sala do Chat do usuário aparece uma vez,
  ///   como sala da CDC, com o selo "Você participa".
  /// - Obrigatórias ficam sempre na seção delas, mesmo se estiverem na lista
  ///   de arquivadas.
  /// - Cada seção em ordem alfabética.
  CdcRoomSections organize({
    required List<CdcChatRoomModel> cdcRooms,
    required List<CdcChatRoomModel> chatRooms,
    required Set<String> archivedKeys,
    required String userCourse,
  }) {
    final chatBySpace = <String, CdcChatRoomModel>{
      for (final room in chatRooms) room.chatSpaceId ?? room.id: room,
    };

    final visibleCdc = <CdcChatRoomModel>[];
    for (final room in cdcRooms) {
      if (!room.isVisibleForCourse(userCourse)) continue;
      final spaceId = room.chatSpaceId;
      final isMember = spaceId != null && chatBySpace.remove(spaceId) != null;
      visibleCdc.add(isMember ? room.copyWith(isMember: true) : room);
    }

    final required = visibleCdc.where((r) => r.isRequired).toList();
    final archivable = [
      ...visibleCdc.where((r) => !r.isRequired),
      ...chatBySpace.values,
    ];
    bool isArchived(CdcChatRoomModel r) => archivedKeys.contains(r.archiveKey);

    return CdcRoomSections(
      required: _sorted(required),
      cdc: _sorted(
        archivable.where(
          (r) => r.origin == CdcRoomOrigin.cdc && !isArchived(r),
        ),
      ),
      mine: _sorted(
        archivable.where(
          (r) => r.origin == CdcRoomOrigin.googleChat && !isArchived(r),
        ),
      ),
      archived: _sorted(archivable.where(isArchived)),
    );
  }

  bool canArchive(CdcChatRoomModel room) => !room.isRequired;

  List<CdcChatRoomModel> _sorted(Iterable<CdcChatRoomModel> rooms) =>
      rooms.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}
