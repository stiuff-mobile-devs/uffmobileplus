import 'package:uffmobileplus/app/modules/external_modules/cdc/data/models/cdc_chat_room_model.dart';

/// Filtros da aba Salas.
enum CdcRoomFilter { all, archived }

/// Salas da aba Salas: a lista principal e as arquivadas.
class CdcRoomSections {
  /// Obrigatórias primeiro, depois as demais (oficiais e do Google Chat).
  final List<CdcChatRoomModel> active;
  final List<CdcChatRoomModel> archived;

  const CdcRoomSections({this.active = const [], this.archived = const []});

  bool get isEmpty => active.isEmpty && archived.isEmpty;

  List<CdcChatRoomModel> of(CdcRoomFilter filter) => switch (filter) {
        CdcRoomFilter.all => active,
        CdcRoomFilter.archived => archived,
      };
}

/// Regras da Central de Comunicação: quais salas o usuário vê e em que ordem.
class CdcService {
  /// - Salas da CDC: só as do curso do usuário (ou de todos os cursos).
  /// - Uma sala da CDC que também é sala do Chat do usuário aparece uma vez,
  ///   como sala da CDC, com o selo "Você participa".
  /// - Lista única: obrigatórias sempre primeiro (nunca arquivadas), depois
  ///   as demais; cada grupo em ordem alfabética.
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
      active: [
        ..._sorted(required),
        ..._sorted(archivable.where((r) => !isArchived(r))),
      ],
      archived: _sorted(archivable.where(isArchived)),
    );
  }

  bool canArchive(CdcChatRoomModel room) => !room.isRequired;

  /// Por quanto tempo as salas guardadas no aparelho valem antes de buscar
  /// de novo (o botão de atualizar busca na hora).
  static const Duration cacheDuration = Duration(hours: 24);

  /// A lista guardada precisa ser buscada de novo: nunca foi buscada, passou
  /// de [cacheDuration] ou a data está no futuro (relógio do aparelho mudou).
  bool isStale(DateTime? updatedAt, DateTime now) {
    if (updatedAt == null || updatedAt.isAfter(now)) return true;
    return now.difference(updatedAt) >= cacheDuration;
  }

  List<CdcChatRoomModel> _sorted(Iterable<CdcChatRoomModel> rooms) =>
      rooms.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}
