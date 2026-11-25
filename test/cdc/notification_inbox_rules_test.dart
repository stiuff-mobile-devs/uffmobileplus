import 'package:flutter_test/flutter_test.dart';
import 'package:uffmobileplus/app/data/models/inbox_notification.dart';
import 'package:uffmobileplus/app/data/services/notification_inbox_service.dart';

InboxNotification push(
  String id, {
  String title = 'Aviso',
  String body = 'Texto',
  int minute = 0,
  bool read = false,
}) =>
    InboxNotification(
      id: id,
      title: title,
      body: body,
      receivedAt: DateTime(2026, 11, 25, 10, minute),
      read: read,
    );

void main() {
  group('NotificationInboxService.addTo', () {
    test('guarda da mais nova para a mais antiga', () {
      var list = <InboxNotification>[];
      list = NotificationInboxService.addTo(list, push('a', minute: 1));
      list = NotificationInboxService.addTo(list, push('b', minute: 5));
      list = NotificationInboxService.addTo(list, push('c', minute: 3));

      expect(list.map((n) => n.id), ['b', 'c', 'a']);
    });

    test('mantém só as mais recentes até o limite', () {
      var list = <InboxNotification>[];
      for (var i = 0; i < NotificationInboxService.maxItems + 5; i++) {
        list = NotificationInboxService.addTo(
          list,
          push('n$i', body: 'Texto $i', minute: i),
        );
      }

      expect(list.length, NotificationInboxService.maxItems);
      expect(list.first.id, 'n${NotificationInboxService.maxItems + 4}');
      expect(list.any((n) => n.id == 'n0'), isFalse);
    });

    test('mesmo id não entra duas vezes', () {
      var list = NotificationInboxService.addTo([], push('a'));
      list = NotificationInboxService.addTo(list, push('a'));

      expect(list.length, 1);
    });

    test('repetida que chega como lida marca a guardada como lida', () {
      var list = NotificationInboxService.addTo([], push('a'));
      list = NotificationInboxService.addTo(list, push('a', read: true));

      expect(list.single.read, isTrue);
    });

    test('da bandeja com o mesmo conteúdo de uma guardada não duplica', () {
      var list = NotificationInboxService.addTo([], push('fcm-1'));
      list = NotificationInboxService.addTo(
        list,
        InboxNotification.fromTray(title: 'Aviso', body: 'Texto'),
      );

      expect(list.map((n) => n.id), ['fcm-1']);
    });

    test('duas mensagens do FCM com o mesmo texto são notificações diferentes',
        () {
      var list = NotificationInboxService.addTo([], push('fcm-1'));
      list = NotificationInboxService.addTo(list, push('fcm-2', minute: 9));

      expect(list.length, 2);
    });

    test('ida e volta pelo Map do Hive preserva os campos', () {
      final original = InboxNotification(
        id: 'x',
        title: 'T',
        body: 'B',
        receivedAt: DateTime.utc(2026, 11, 25, 12),
        read: true,
        route: '/cdc',
        link: 'https://uff.br',
      );
      final copy = InboxNotification.fromMap(original.toMap());

      expect(copy.toMap(), original.toMap());
    });
  });
}
