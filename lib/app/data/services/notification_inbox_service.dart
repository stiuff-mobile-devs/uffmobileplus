import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uffmobileplus/app/data/models/inbox_notification.dart';
import 'package:uffmobileplus/app/data/services/crash_reporter.dart';
import 'package:uffmobileplus/app/utils/user_storage_key.dart';

/// Caixa de entrada das notificações push, guardada no Hive por usuário.
///
/// Recebe as notificações do [PushNotificationService] (app aberto, toque na
/// notificação e leitura da bandeja do celular) e as mostra na Central de
/// Comunicação. Guarda só as [maxItems] mais recentes.
///
/// Enquanto não se sabe quem é o usuário (o app acabou de abrir), o que chega
/// fica em "pendentes" e passa para o usuário em [setUser].
///
/// Não grave daqui no `firebaseMessagingBackgroundHandler`: ele roda em outro
/// isolate e o Hive não é seguro entre isolates.
class NotificationInboxService {
  static final NotificationInboxService _instance =
      NotificationInboxService._internal();
  factory NotificationInboxService() => _instance;
  NotificationInboxService._internal();

  /// Quantas notificações ficam guardadas por usuário.
  static const int maxItems = 30;

  static const String _boxName = 'cdc_notificacoes';
  static const String _pendingKey = 'pendentes';
  static const String _traySeenKey = 'bandeja_vistas';
  static const int _maxTraySeen = 100;

  /// Notificações do usuário atual, da mais nova para a mais antiga.
  final RxList<InboxNotification> items = <InboxNotification>[].obs;

  int get unreadCount => items.where((n) => !n.read).length;

  String? _userKey;
  Future<void> _last = Future.value();

  String get _itemsKey => _userKey == null ? _pendingKey : 'usuario_$_userKey';

  // ---------------------------------------------------------------------------
  // Usuário
  // ---------------------------------------------------------------------------

  /// Troca o usuário dono da caixa. [seed] é o iduff ou, sem ele, o uid do
  /// Google; nulo ou vazio volta para "pendentes" (sem usuário).
  Future<void> setUser(String? seed) {
    final key = (seed == null || seed.isEmpty) ? null : userStorageKey(seed);
    return _run('trocar usuário da caixa de notificações', (box) async {
      _userKey = key;
      var list = _read(box, _itemsKey);
      if (key != null) {
        final pending = _read(box, _pendingKey);
        if (pending.isNotEmpty) {
          for (final n in pending) {
            list = addTo(list, n);
          }
          await box.delete(_pendingKey);
        }
      }
      await _store(box, list);
    });
  }

  /// Logout: o que chegar depois fica em "pendentes" até o próximo login.
  Future<void> clearUser() => setUser(null);

  // ---------------------------------------------------------------------------
  // Entrada
  // ---------------------------------------------------------------------------

  /// Guarda uma mensagem do FCM. [read] = true quando o usuário tocou nela.
  Future<void> addMessage(RemoteMessage message, {bool read = false}) =>
      add(InboxNotification.fromRemoteMessage(message, read: read));

  Future<void> add(InboxNotification notification) {
    if (notification.isEmpty) return Future.value();
    return _run('guardar notificação', (box) async {
      await _store(box, addTo(_read(box, _itemsKey), notification));
    });
  }

  /// Guarda as notificações lidas da bandeja do celular. Cada uma entra uma
  /// vez só: se o usuário limpar a lista, ela não volta da bandeja.
  Future<void> addFromTray(List<InboxNotification> trayItems) {
    if (trayItems.isEmpty) return Future.value();
    return _run('guardar notificações da bandeja', (box) async {
      final seen = (box.get(_traySeenKey) as List? ?? const [])
          .map((e) => e.toString())
          .toList();
      var list = _read(box, _itemsKey);
      var changed = false;
      for (final n in trayItems) {
        if (n.isEmpty || seen.contains(n.signature)) continue;
        list = addTo(list, n);
        seen.add(n.signature);
        changed = true;
      }
      if (!changed) return;
      final start = seen.length > _maxTraySeen ? seen.length - _maxTraySeen : 0;
      await box.put(_traySeenKey, seen.sublist(start));
      await _store(box, list);
    });
  }

  // ---------------------------------------------------------------------------
  // Ações da lista
  // ---------------------------------------------------------------------------

  /// Relê a caixa do usuário atual para [items].
  Future<void> load() => _run('carregar notificações', (box) async {
        items.assignAll(_read(box, _itemsKey));
      });

  Future<void> markRead(String id) => _update(
        'marcar notificação como lida',
        (list) => [for (final n in list) n.id == id ? n.copyWith(read: true) : n],
      );

  Future<void> markAllRead() => _update(
        'marcar notificações como lidas',
        (list) => [for (final n in list) n.copyWith(read: true)],
      );

  Future<void> remove(String id) => _update(
        'remover notificação',
        (list) => list.where((n) => n.id != id).toList(),
      );

  Future<void> clear() => _update('limpar notificações', (_) => []);

  // ---------------------------------------------------------------------------
  // Regras (puras, testáveis sem Hive)
  // ---------------------------------------------------------------------------

  /// Insere [incoming] em [current], da mais nova para a mais antiga, com no
  /// máximo [max] itens. A mesma notificação não entra duas vezes: mesmo id
  /// ou, quando um dos lados veio da bandeja (sem id do FCM), mesmo conteúdo.
  /// Se a repetida chegou como lida (o usuário tocou), marca a guardada.
  static List<InboxNotification> addTo(
    List<InboxNotification> current,
    InboxNotification incoming, {
    int max = maxItems,
  }) {
    final index = current.indexWhere((n) => isSame(n, incoming));
    if (index >= 0) {
      if (!incoming.read || current[index].read) return current;
      return [...current]..[index] = current[index].copyWith(read: true);
    }
    final list = [incoming, ...current]
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    return list.length > max ? list.sublist(0, max) : list;
  }

  static bool isSame(InboxNotification a, InboxNotification b) {
    if (a.id == b.id) return true;
    if (!a.fromTray && !b.fromTray) return false;
    return a.signature == b.signature;
  }

  // ---------------------------------------------------------------------------
  // Hive
  // ---------------------------------------------------------------------------

  Future<void> _update(
    String reason,
    List<InboxNotification> Function(List<InboxNotification>) change,
  ) {
    return _run(reason, (box) async {
      await _store(box, change(_read(box, _itemsKey)));
    });
  }

  /// Executa uma operação por vez, para duas gravações não se atropelarem.
  Future<void> _run(String reason, Future<void> Function(Box box) op) {
    final next = _last.then((_) async {
      try {
        final box = Hive.isBoxOpen(_boxName)
            ? Hive.box(_boxName)
            : await Hive.openBox(_boxName);
        await op(box);
      } catch (e, s) {
        CrashReporter.recordError(e, s, reason: reason);
      }
    });
    _last = next;
    return next;
  }

  List<InboxNotification> _read(Box box, String key) {
    final raw = box.get(key);
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map(InboxNotification.fromMap)
        .where((n) => n.id.isNotEmpty)
        .toList();
  }

  Future<void> _store(Box box, List<InboxNotification> list) async {
    await box.put(_itemsKey, list.map((n) => n.toMap()).toList());
    items.assignAll(list);
  }
}
