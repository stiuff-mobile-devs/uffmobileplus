import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
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
class PushNotificationService {
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
    _navigateToCdc();
  }

  /// Verifica se o app foi **iniciado** a partir de uma notificação (app terminado).
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        'App aberto via notificação (terminated): ${initialMessage.notification?.title}',
      );
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
  // Navegação
  // ---------------------------------------------------------------------------

  /// Navega para a tela da CDC.
  void _navigateToCdc() {
    // Verifica se já está na rota da CDC para evitar empilhamento
    if (Get.currentRoute != Routes.CDC) {
      Get.toNamed(Routes.CDC);
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
