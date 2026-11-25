import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Uma notificação guardada na caixa de entrada da Central de Comunicação.
class InboxNotification {
  /// Id estável: `data.id` enviado pelo backend, o `messageId` do FCM ou,
  /// para o que foi lido da bandeja do celular, um id derivado do conteúdo.
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final bool read;

  /// Rota do app (`data.route`) a abrir ao tocar.
  final String? route;

  /// Link externo (`data.link` ou `data.url`) a abrir ao tocar.
  final String? link;

  /// Veio da bandeja do celular (o app estava fechado quando chegou), então
  /// não tem id do FCM e a data é a da leitura da bandeja.
  final bool fromTray;

  const InboxNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.read = false,
    this.route,
    this.link,
    this.fromTray = false,
  });

  factory InboxNotification.fromRemoteMessage(
    RemoteMessage message, {
    DateTime? now,
    bool read = false,
  }) {
    final data = message.data;
    final title = _text(message.notification?.title ?? data['title']);
    final body = _text(message.notification?.body ?? data['body']);
    final explicitId = _text(data['id']);
    final messageId = _text(message.messageId);
    return InboxNotification(
      id: explicitId.isNotEmpty
          ? explicitId
          : messageId.isNotEmpty
              ? messageId
              : contentId(title, body),
      title: title,
      body: body,
      receivedAt: message.sentTime ?? now ?? DateTime.now(),
      read: read,
      route: _nullIfEmpty(data['route']),
      link: _nullIfEmpty(data['link'] ?? data['url']),
    );
  }

  /// Notificação lida da bandeja do celular.
  factory InboxNotification.fromTray({
    required String? title,
    required String? body,
    DateTime? now,
  }) {
    final t = _text(title);
    final b = _text(body);
    return InboxNotification(
      id: contentId(t, b),
      title: t,
      body: b,
      receivedAt: now ?? DateTime.now(),
      fromTray: true,
    );
  }

  factory InboxNotification.fromMap(Map<dynamic, dynamic> map) {
    return InboxNotification(
      id: _text(map['id']),
      title: _text(map['title']),
      body: _text(map['body']),
      receivedAt:
          DateTime.tryParse(_text(map['receivedAt'])) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      read: map['read'] == true,
      route: _nullIfEmpty(map['route']),
      link: _nullIfEmpty(map['link']),
      fromTray: map['fromTray'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'receivedAt': receivedAt.toIso8601String(),
        'read': read,
        'route': route,
        'link': link,
        'fromTray': fromTray,
      };

  bool get isEmpty => title.isEmpty && body.isEmpty;

  /// Assinatura do conteúdo, usada para achar a mesma notificação vinda por
  /// caminhos diferentes (bandeja x toque x app aberto).
  String get signature => contentId(title, body);

  InboxNotification copyWith({bool? read}) => InboxNotification(
        id: id,
        title: title,
        body: body,
        receivedAt: receivedAt,
        read: read ?? this.read,
        route: route,
        link: link,
        fromTray: fromTray,
      );

  /// Precisa ser igual entre execuções do app (por isso não usa `hashCode`).
  static String contentId(String title, String body) {
    final digest = sha1.convert(utf8.encode('${title.trim()}\n${body.trim()}'));
    return 'conteudo:${digest.toString().substring(0, 16)}';
  }

  static String _text(Object? value) => (value ?? '').toString().trim();

  static String? _nullIfEmpty(Object? value) {
    final text = _text(value);
    return text.isEmpty ? null : text;
  }
}
