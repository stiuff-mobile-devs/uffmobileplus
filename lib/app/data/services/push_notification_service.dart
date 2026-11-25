import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/models/inbox_notification.dart';
import 'package:uffmobileplus/app/data/services/crash_reporter.dart';
import 'package:uffmobileplus/app/data/services/notification_inbox_service.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

/// Handler de mensagens em background — DEVE ser top-level (fora de classes).
/// Chamado quando o app está terminado ou em background e recebe uma mensagem data-only.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    'Notificação recebida em background: ${message.notification?.title}',
  );
}

/// Serviço centralizado para gerenciar Push Notifications via FCM.
///
/// Responsabilidades:
/// - Inicializar `flutter_local_notifications` (canal Android + config iOS)
/// - Exibir notificações no foreground via `flutter_local_notifications`
/// - Tratar clique em notificações (background e app terminado) → navegar p/ CDC
/// - Escutar `onTokenRefresh` para re-registrar o token no futuro
/// - Guardar as notificações na caixa de entrada ([NotificationInboxService]):
///   ao chegar com o app aberto, ao tocar e, ao abrir/voltar ao app, as que
///   ainda estão na bandeja do celular (chegaram com o app fechado)
class PushNotificationService with WidgetsBindingObserver {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Canal de notificação Android de alta importância.
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'cdc_notifications', // ID do canal
    'Notificações da Central de Comunicação', // Nome visível ao usuário
    description: 'Notificações enviadas pela Central de Comunicação da UFF',
    importance: Importance.high,
    playSound: true,
  );

  /// Inicializa o serviço de notificações.
  /// Deve ser chamado após `FirebaseService.init()` no `main.dart`.
  Future<void> init() async {
    // 1. Criar o canal de notificação no Android
    await _createAndroidNotificationChannel();

    // 2. Inicializar flutter_local_notifications
    await _initLocalNotifications();

    // 3. Configurar apresentação de notificações no foreground (iOS)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4. Escutar notificações no foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 5. Escutar clique em notificações quando app está em background
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // 6. Verificar se o app foi aberto via notificação (app estava terminado)
    await _checkInitialMessage();

    // 7. Escutar renovação de token
    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    // 8. Guardar o que chegou com o app fechado e repetir ao voltar ao app
    WidgetsBinding.instance.addObserver(this);
    await syncFromTray();

    debugPrint('✅ PushNotificationService inicializado');
  }

  // ---------------------------------------------------------------------------
  // Inicialização
  // ---------------------------------------------------------------------------

  /// Cria o canal de notificação Android (necessário para Android 8+).
  Future<void> _createAndroidNotificationChannel() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_androidChannel);
    }
  }

  /// Inicializa o plugin `flutter_local_notifications`.
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // Permissão já solicitada pelo FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // ---------------------------------------------------------------------------
  // Handlers de Notificação
  // ---------------------------------------------------------------------------

  /// Chamado quando uma notificação chega com o app **aberto (foreground)**.
  /// O FCM não exibe notificações automaticamente neste estado,
  /// então usamos `flutter_local_notifications` para exibir manualmente.
  void _onForegroundMessage(RemoteMessage message) {
    debugPrint(
      'Notificação foreground: ${message.notification?.title} - ${message.notification?.body}',
    );

    NotificationInboxService().addMessage(message);

    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['route'] ?? Routes.CDC,
    );
  }

  /// Chamado quando o usuário clica em uma notificação e o app estava em **background**.
  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint(
      'Notificação clicada (background): ${message.notification?.title}',
    );
    NotificationInboxService().addMessage(message, read: true);
    _navigateToCdc();
  }

  /// Verifica se o app foi **iniciado** a partir de uma notificação (app terminado).
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        'App aberto via notificação (terminated): ${initialMessage.notification?.title}',
      );
      await NotificationInboxService().addMessage(initialMessage, read: true);
      // Atrasa a navegação para garantir que o GetMaterialApp já inicializou
      Future.delayed(const Duration(seconds: 2), () {
        _navigateToCdc();
      });
    }
  }

  /// Chamado quando o usuário toca em uma notificação local (foreground).
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notificação local clicada. Payload: ${response.payload}');
    _navigateToCdc();
  }

  // ---------------------------------------------------------------------------
  // Bandeja do celular
  // ---------------------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) syncFromTray();
  }

  /// Guarda na caixa de entrada as notificações da CDC que estão na bandeja
  /// do celular. É o único jeito de pegar as que chegaram com o app fechado,
  /// quando o código do app não roda. Se o usuário apagou da bandeja sem
  /// tocar, ela se perde.
  Future<void> syncFromTray() async {
    try {
      final active = await _localNotifications.getActiveNotifications();
      final trayItems = active
          .where(_isCdcNotification)
          .map(
            (n) => InboxNotification.fromTray(
              title: n.title,
              body: n.body ?? n.bigText,
            ),
          )
          .toList();
      await NotificationInboxService().addFromTray(trayItems);
    } catch (e, s) {
      CrashReporter.recordError(e, s, reason: 'ler notificações da bandeja');
    }
  }

  /// No Android, só o canal da CDC (é também o canal padrão do FCM no
  /// manifest); assim as notificações fixas do SOS e do Monitora ficam de
  /// fora. No iOS o app só mostra notificações da CDC.
  bool _isCdcNotification(ActiveNotification n) {
    if (Platform.isAndroid) return n.channelId == _androidChannel.id;
    return true;
  }

  // ---------------------------------------------------------------------------
  // Navegação
  // ---------------------------------------------------------------------------

  /// Navega para a tela da CDC, já na aba Notificações.
  void _navigateToCdc() {
    // Verifica se já está na rota da CDC para evitar empilhamento
    if (Get.currentRoute != Routes.CDC) {
      Get.toNamed(Routes.CDC, arguments: {'aba': 'notificacoes'});
    }
  }

  // ---------------------------------------------------------------------------
  // Token Refresh
  // ---------------------------------------------------------------------------

  /// Chamado quando o token FCM/APNs é renovado.
  /// Loga a renovação; o re-registro na CDC acontecerá no próximo login
  /// (a checagem de 90 dias será invalidada pelo novo token).
  void _onTokenRefresh(String newToken) {
    debugPrint('Token FCM renovado: $newToken');
    // O token será re-registrado na CDC no próximo login.
    // Para um comportamento mais agressivo, poderia chamar o registro aqui,
    // mas seria necessário ter o auth token disponível.
  }
}
