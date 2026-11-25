/// De onde a sala veio.
enum CdcRoomOrigin {
  /// Cadastrada pela Central de Comunicação (Firestore, coleção `chats`).
  cdc,

  /// Sala do Google Chat em que o usuário já está.
  googleChat,
}

/// Seção em que a sala aparece, na ordem da tela.
enum CdcRoomCategory { required, cdc, mine }

class CdcChatRoomModel {
  final String id;
  final String name;
  final String link;
  final String type;
  final bool allCourses;
  final List<String> courses;

  /// Sala obrigatória: sempre no topo e não pode ser arquivada
  /// (Firestore `required: true`).
  final bool isRequired;

  final CdcRoomOrigin origin;

  /// Sala da CDC em que o usuário também já está no Google Chat.
  final bool isMember;

  const CdcChatRoomModel({
    required this.id,
    required this.name,
    required this.link,
    required this.type,
    required this.allCourses,
    required this.courses,
    this.isRequired = false,
    this.origin = CdcRoomOrigin.cdc,
    this.isMember = false,
  });

  factory CdcChatRoomModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    final dynamic rawCourses = map['courses'];

    final List<String> normalizedCourses =
        (rawCourses is List ? rawCourses : const [])
            .whereType<dynamic>()
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();

    return CdcChatRoomModel(
      id: id,
      name: (map['name'] ?? '').toString().trim(),
      link: (map['link'] ?? '').toString().trim(),
      type: (map['type'] ?? '').toString().trim(),
      allCourses: map['all_courses'] == true,
      courses: normalizedCourses,
      isRequired: map['required'] == true,
    );
  }

  CdcRoomCategory get category {
    if (isRequired) return CdcRoomCategory.required;
    return origin == CdcRoomOrigin.cdc
        ? CdcRoomCategory.cdc
        : CdcRoomCategory.mine;
  }

  /// Id da sala no Google Chat (o `<id>` de `spaces/<id>`), tirado do link
  /// quando a sala é da CDC. `null` se o link não for de uma sala do Chat.
  String? get chatSpaceId {
    if (origin == CdcRoomOrigin.googleChat) {
      return id.startsWith('spaces/') ? id.substring(7) : id;
    }
    return chatSpaceIdFromLink(link);
  }

  /// Chave usada para arquivar. Uma sala da CDC que também é uma sala do
  /// Chat do usuário tem a mesma chave nos dois casos.
  String get archiveKey {
    final spaceId = chatSpaceId;
    return spaceId != null ? 'spaces/$spaceId' : 'cdc/$id';
  }

  /// Aceita `chat.google.com/room/<id>` e os links do Gmail
  /// (`mail.google.com/chat/u/0/#chat/space/<id>`).
  static String? chatSpaceIdFromLink(String link) {
    final uri = Uri.tryParse(link.trim());
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    if (host != 'chat.google.com' && host != 'mail.google.com') return null;

    for (final segments in [uri.pathSegments, uri.fragment.split('/')]) {
      for (var i = 0; i < segments.length - 1; i++) {
        if ((segments[i] == 'room' || segments[i] == 'space') &&
            segments[i + 1].isNotEmpty) {
          return segments[i + 1];
        }
      }
    }
    return null;
  }

  bool isVisibleForCourse(String userCourse) {
    if (allCourses) return true;

    final String normalizedUserCourse = userCourse.trim().toLowerCase();
    if (normalizedUserCourse.isEmpty || normalizedUserCourse == '-') {
      return false;
    }

    return courses.any(
      (course) => course.trim().toLowerCase() == normalizedUserCourse,
    );
  }

  bool hasRequiredFields() {
    return name.isNotEmpty && link.isNotEmpty;
  }

  CdcChatRoomModel copyWith({bool? isMember}) => CdcChatRoomModel(
        id: id,
        name: name,
        link: link,
        type: type,
        allCourses: allCourses,
        courses: courses,
        isRequired: isRequired,
        origin: origin,
        isMember: isMember ?? this.isMember,
      );
}
