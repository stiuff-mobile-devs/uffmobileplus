import 'package:flutter_test/flutter_test.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/models/cdc_chat_room_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/services/cdc_service.dart';

CdcChatRoomModel room(
  String id, {
  String? name,
  String? link,
  bool required = false,
  bool allCourses = true,
  List<String> courses = const [],
  CdcRoomOrigin origin = CdcRoomOrigin.cdc,
}) =>
    CdcChatRoomModel(
      id: id,
      name: name ?? id,
      link: link ?? 'https://example.com/$id',
      type: '',
      allCourses: allCourses,
      courses: courses,
      isRequired: required,
      origin: origin,
    );

void main() {
  final service = CdcService();

  group('CdcService.organize', () {
    test('lista única: obrigatórias primeiro, cada grupo em ordem alfabética',
        () {
      final sections = service.organize(
        cdcRooms: [
          room('b', name: 'Bravo'),
          room('z', name: 'Zulu', required: true),
          room('a', name: 'alfa'),
          room('m', name: 'Mike', required: true),
        ],
        chatRooms: const [],
        archivedKeys: const {},
        userCourse: 'Computação',
      );

      expect(sections.active.map((r) => r.name), [
        'Mike',
        'Zulu',
        'alfa',
        'Bravo',
      ]);
      expect(sections.of(CdcRoomFilter.all), sections.active);
    });

    test('mostra só as salas do curso do usuário', () {
      final sections = service.organize(
        cdcRooms: [
          room('comp', allCourses: false, courses: ['Computação']),
          room('dir', allCourses: false, courses: ['Direito']),
        ],
        chatRooms: const [],
        archivedKeys: const {},
        userCourse: ' computação ',
      );

      expect(sections.active.map((r) => r.id), ['comp']);
    });

    test('arquivada sai da seção e vai para Arquivadas', () {
      final archivedRoom = room('a');
      final sections = service.organize(
        cdcRooms: [archivedRoom, room('b')],
        chatRooms: const [],
        archivedKeys: {archivedRoom.archiveKey},
        userCourse: '',
      );

      expect(sections.active.map((r) => r.id), ['b']);
      expect(sections.archived.map((r) => r.id), ['a']);
    });

    test('obrigatória nunca fica arquivada', () {
      final requiredRoom = room('r', required: true);
      final sections = service.organize(
        cdcRooms: [requiredRoom],
        chatRooms: const [],
        archivedKeys: {requiredRoom.archiveKey},
        userCourse: '',
      );

      expect(sections.active.map((r) => r.id), ['r']);
      expect(sections.archived, isEmpty);
      expect(service.canArchive(requiredRoom), isFalse);
    });

    test('sala da CDC que o usuário já tem no Chat aparece uma vez só', () {
      final sections = service.organize(
        cdcRooms: [
          room('cdc1', link: 'https://chat.google.com/room/AAA111'),
        ],
        chatRooms: [
          room('spaces/AAA111', origin: CdcRoomOrigin.googleChat),
          room('spaces/BBB222', origin: CdcRoomOrigin.googleChat),
        ],
        archivedKeys: const {},
        userCourse: '',
      );

      expect(sections.active.map((r) => r.id), ['cdc1', 'spaces/BBB222']);
      expect(sections.active.first.isMember, isTrue);
      expect(sections.active.last.category, CdcRoomCategory.mine);
    });
  });

  group('CdcChatRoomModel', () {
    test('lê o id da sala do Chat nos formatos de link conhecidos', () {
      expect(
        CdcChatRoomModel.chatSpaceIdFromLink(
          'https://chat.google.com/room/AAQA123?cls=7',
        ),
        'AAQA123',
      );
      expect(
        CdcChatRoomModel.chatSpaceIdFromLink(
          'https://mail.google.com/chat/u/0/#chat/space/AAQA456',
        ),
        'AAQA456',
      );
      expect(
        CdcChatRoomModel.chatSpaceIdFromLink('https://meet.google.com/abc'),
        isNull,
      );
    });

    test('lê o campo required do Firestore', () {
      final model = CdcChatRoomModel.fromMap(
        id: 'x',
        map: {'name': 'Sala', 'link': 'https://l', 'required': true},
      );
      expect(model.isRequired, isTrue);
      expect(model.category, CdcRoomCategory.required);
    });
  });
}
