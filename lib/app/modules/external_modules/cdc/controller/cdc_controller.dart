import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uffmobileplus/app/data/models/inbox_notification.dart';
import 'package:uffmobileplus/app/data/services/crash_reporter.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/data/services/notification_inbox_service.dart';
import 'package:uffmobileplus/app/data/services/push_notification_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/models/cdc_chat_room_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/repository/cdc_repository.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/services/cdc_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/utils/cdc_mock_notifications.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';

enum _RoomAction { open, archive, unarchive }

/// Situação das salas do Google Chat do usuário na Central.
enum CdcGoogleChatStatus {
  /// Nenhuma conta Google conectada no app.
  notConnected,

  /// A conta conectada não é @id.uff.br.
  otherAccount,

  /// Conta UFF conectada, mas sem a permissão de ver as salas do Chat.
  noPermission,
  loading,
  ready,
  error,
}

class CdcController extends GetxController {
  /// Notificações de teste: `true` mostra exemplos fixos na aba Notificações
  /// (só em memória, sem gravar no Hive); `false` mostra as reais.
  /// Volte para `false` antes de publicar.
  static const bool notificacoesDeTeste = false;

  final CdcRepository _repository;
  final CdcService _service;

  CdcController(this._repository, this._service);

  final ExternalModulesServices _externalModulesServices =
      Get.find<ExternalModulesServices>();

  /// Caixa de notificações (compartilhada com o serviço de push).
  final NotificationInboxService _inbox = NotificationInboxService();

  /// Exemplos em memória quando [notificacoesDeTeste] está ligado.
  final RxList<InboxNotification> _mock = <InboxNotification>[].obs;

  bool get _useMock => notificacoesDeTeste;

  /// Notificações mostradas na aba (exemplos ou a caixa real).
  List<InboxNotification> get notifications =>
      _useMock ? _mock : _inbox.items;

  int get unreadCount => notifications.where((n) => !n.read).length;

  /// Começa true para o primeiro frame já mostrar o carregamento.
  final RxBool isLoading = true.obs;
  final RxBool loadFailed = false.obs;
  final Rx<CdcRoomFilter> filter = CdcRoomFilter.all.obs;
  final Rx<CdcRoomSections> sections = const CdcRoomSections().obs;

  /// Aba aberta ao entrar: 1 (Notificações) quando veio de uma notificação.
  late final int initialTab =
      (Get.arguments is Map && Get.arguments['aba'] == 'notificacoes') ? 1 : 0;

  /// Só contas institucionais mostram salas do Google Chat.
  static const String _uffEmailDomain = '@id.uff.br';

  final Rx<CdcGoogleChatStatus> chatStatus =
      CdcGoogleChatStatus.loading.obs;

  List<CdcChatRoomModel> _cdcRooms = const [];
  List<CdcChatRoomModel> _chatRooms = const [];
  Set<String> _archivedKeys = <String>{};
  String _userKey = 'anonimo';

  /// A carga fica no onReady (depois do primeiro frame): o controller nasce
  /// durante o build da CdcPage, e mudar valores observados ali gera o erro
  /// "setState() or markNeedsBuild() called during build".
  @override
  void onReady() {
    super.onReady();
    loadRooms();
    if (_useMock) {
      _mock.assignAll(cdcMockNotifications());
    } else {
      _inbox.load();
    }
  }

  // ---------------------------------------------------------------------------
  // Salas
  // ---------------------------------------------------------------------------

  /// Quando as salas oficiais foram buscadas pela última vez.
  final Rxn<DateTime> updatedAt = Rxn<DateTime>();
  DateTime? _chatUpdatedAt;

  /// Abre com as salas guardadas no aparelho e só busca de novo se passaram
  /// 24h ([CdcService.cacheDuration]) ou com [force] (botão de atualizar).
  Future<void> loadRooms({bool force = false}) => _load(force: force);

  /// Botão ⟳ e puxar a lista: busca tudo de novo na hora.
  Future<void> refreshAll() async {
    final ok = await _load(force: true);
    await refreshNotifications();
    if (!ok) {
      AppPopups.error(
        'msg_verifique_internet'.tr,
        title: 'cdc_erro_atualizar_titulo'.tr,
      );
    }
  }

  /// Devolve false se uma busca necessária falhou.
  Future<bool> _load({required bool force}) async {
    var ok = true;
    try {
      isLoading.value = true;
      loadFailed.value = false;

      await _externalModulesServices.initialize();
      _userKey = _externalModulesServices.getUserStorageKey() ?? 'anonimo';
      _archivedKeys = await _repository.getArchivedKeys(_userKey);

      final cachedChat = await _repository.getCachedGoogleChatRooms(_userKey);
      _chatRooms = cachedChat.rooms;
      _chatUpdatedAt = cachedChat.updatedAt;

      final cached = await _repository.getCachedCdcRooms(_userKey);
      _cdcRooms = cached.rooms;
      updatedAt.value = cached.updatedAt;
      _organize();

      if (force || _service.isStale(cached.updatedAt, DateTime.now())) {
        ok = await _fetchCdcRooms(hasCache: cached.updatedAt != null);
      }
    } catch (e, s) {
      CrashReporter.recordError(e, s, reason: 'carregar salas de chat do cdc');
      debugPrint('CDC: erro ao carregar salas - $e');
      loadFailed.value = true;
      sections.value = const CdcRoomSections();
      ok = false;
    } finally {
      isLoading.value = false;
    }
    if (loadFailed.value) return false;
    final chatOk = await _loadGoogleChat(force: force);
    return ok && chatOk;
  }

  /// Busca as salas oficiais no Firestore. Sem nada guardado, a falha vira
  /// a tela de erro; com salas guardadas, elas continuam na tela.
  Future<bool> _fetchCdcRooms({required bool hasCache}) async {
    try {
      final fresh = await _repository.fetchCdcRooms(_userKey);
      _cdcRooms = fresh.rooms;
      updatedAt.value = fresh.updatedAt;
      _organize();
      return true;
    } catch (e, s) {
      if (!hasCache) rethrow;
      CrashReporter.recordError(e, s, reason: 'atualizar salas de chat do cdc');
      debugPrint('CDC: usando salas guardadas, busca falhou - $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Salas do Google Chat
  // ---------------------------------------------------------------------------

  String get _googleEmail =>
      (_externalModulesServices.getUserEmailGoogle() ?? '').trim().toLowerCase();

  /// Situação e salas do Chat do usuário. A API só é chamada se as salas
  /// guardadas venceram, com [force] ou com [interactive] (depois de o
  /// usuário tocar em Conectar/Permitir). Devolve false se a busca falhou.
  Future<bool> _loadGoogleChat({
    bool interactive = false,
    bool force = false,
  }) async {
    final email = _googleEmail;
    if (email.isEmpty || !await _externalModulesServices.hasActiveGoogleBond()) {
      await _dropChatRooms(CdcGoogleChatStatus.notConnected);
      return true;
    }
    if (!email.endsWith(_uffEmailDomain)) {
      await _dropChatRooms(CdcGoogleChatStatus.otherAccount);
      return true;
    }
    if (!force &&
        !interactive &&
        !_service.isStale(_chatUpdatedAt, DateTime.now())) {
      _setChatRooms(_chatRooms, CdcGoogleChatStatus.ready);
      return true;
    }

    chatStatus.value = CdcGoogleChatStatus.loading;
    try {
      final headers = await _externalModulesServices.getGoogleAuthHeaders(
        [_repository.googleChatScope],
        interactive: interactive,
      );
      if (headers == null) {
        await _dropChatRooms(CdcGoogleChatStatus.noPermission);
        return true;
      }
      final fresh = await _repository.fetchGoogleChatRooms(_userKey, headers);
      _chatUpdatedAt = fresh.updatedAt;
      _setChatRooms(fresh.rooms, CdcGoogleChatStatus.ready);
      return true;
    } catch (e, s) {
      // Mantém as salas guardadas no aparelho.
      CrashReporter.recordError(e, s, reason: 'carregar salas do google chat');
      debugPrint('CDC: erro ao carregar salas do Google Chat - $e');
      chatStatus.value = CdcGoogleChatStatus.error;
      return false;
    }
  }

  /// Sem conta UFF ou sem permissão: tira as salas do Chat da tela e do
  /// aparelho.
  Future<void> _dropChatRooms(CdcGoogleChatStatus status) async {
    if (_chatRooms.isNotEmpty || _chatUpdatedAt != null) {
      await _repository.clearGoogleChatRooms(_userKey);
      _chatUpdatedAt = null;
    }
    _setChatRooms(const [], status);
  }

  void _setChatRooms(List<CdcChatRoomModel> rooms, CdcGoogleChatStatus status) {
    _chatRooms = rooms;
    chatStatus.value = status;
    _organize();
  }

  /// Botão do card: conecta a conta Google (se faltar), confere se é da UFF
  /// e pede a permissão de ver as salas do Chat.
  Future<void> connectGoogleChat() async {
    if (!await _externalModulesServices.hasActiveGoogleBond()) {
      // Sem conta ativa, o toggle só conecta (nunca desconecta).
      final connected = await _externalModulesServices.toggleGoogleBond();
      if (!connected) return;
    }
    if (!_googleEmail.endsWith(_uffEmailDomain)) {
      await _dropChatRooms(CdcGoogleChatStatus.otherAccount);
      AppPopups.warning(
        'cdc_google_chat_outra_conta_msg'.tr,
        title: 'cdc_google_chat_outra_conta_titulo'.tr,
      );
      return;
    }
    final ok = await _loadGoogleChat(interactive: true, force: true);
    if (!ok) {
      AppPopups.error(
        'tente_novamente_mais_tarde'.tr,
        title: 'cdc_google_chat_erro_titulo'.tr,
      );
    }
  }

  void _organize() {
    sections.value = _service.organize(
      cdcRooms: _cdcRooms,
      chatRooms: _chatRooms,
      archivedKeys: _archivedKeys,
      userCourse: _externalModulesServices.getUserCourse(),
    );
    // Se o filtro ficou sem salas (ex.: desarquivou a última), volta a Todas.
    if (filter.value != CdcRoomFilter.all &&
        sections.value.of(filter.value).isEmpty) {
      filter.value = CdcRoomFilter.all;
    }
  }

  void selectFilter(CdcRoomFilter value) => filter.value = value;

  bool canArchive(CdcChatRoomModel room) => _service.canArchive(room);

  bool isArchived(CdcChatRoomModel room) =>
      _archivedKeys.contains(room.archiveKey);

  Future<void> openRoom(CdcChatRoomModel room) async {
    final Uri uri = Uri.tryParse(room.link) ?? Uri();
    if (uri.host.isEmpty) {
      AppPopups.error(
        'sala_sem_link_valido'.tr,
        title: 'link_invalido'.tr,
      );
      return;
    }

    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) AppPopups.error('nao_foi_possivel_abrir_link_sala'.tr);
  }

  Future<void> showRoomOptions(CdcChatRoomModel room) async {
    final archived = isArchived(room);
    final action = await AppPopups.choose<_RoomAction>(
      title: room.name,
      options: [
        PopupOption(
          value: _RoomAction.open,
          label: 'abrir_sala'.tr,
          icon: Icons.open_in_new_rounded,
        ),
        if (canArchive(room))
          archived
              ? PopupOption(
                  value: _RoomAction.unarchive,
                  label: 'cdc_desarquivar_sala'.tr,
                  description: 'cdc_desarquivar_descricao'.tr,
                  icon: Icons.unarchive_outlined,
                )
              : PopupOption(
                  value: _RoomAction.archive,
                  label: 'cdc_arquivar_sala'.tr,
                  description: 'cdc_arquivar_descricao'.tr,
                  icon: Icons.archive_outlined,
                ),
      ],
    );

    switch (action) {
      case _RoomAction.open:
        await openRoom(room);
      case _RoomAction.archive:
        await archive(room);
      case _RoomAction.unarchive:
        await unarchive(room);
      case null:
        break;
    }
  }

  Future<void> archive(CdcChatRoomModel room) async {
    if (!canArchive(room)) return;
    if (!await _setArchived(room, true)) return;
    // Sem botão "Desfazer": snackbar com ação não fecha sozinho no Flutter
    // 3.44 (persist). Para desfazer: filtro Arquivadas > Desarquivar.
    AppPopups.success('cdc_sala_arquivada'.tr);
  }

  Future<void> unarchive(CdcChatRoomModel room) async {
    if (!await _setArchived(room, false)) return;
    AppPopups.success('cdc_sala_desarquivada'.tr);
  }

  Future<bool> _setArchived(CdcChatRoomModel room, bool archived) async {
    final previous = {..._archivedKeys};
    final updated = {..._archivedKeys};
    archived ? updated.add(room.archiveKey) : updated.remove(room.archiveKey);
    try {
      _archivedKeys = updated;
      _organize();
      await _repository.saveArchivedKeys(_userKey, updated);
      return true;
    } catch (e, s) {
      CrashReporter.recordError(e, s, reason: 'arquivar sala do cdc');
      _archivedKeys = previous;
      _organize();
      AppPopups.error(
        'tente_novamente_mais_tarde'.tr,
        title: 'cdc_nao_foi_possivel_arquivar'.tr,
      );
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Notificações
  // ---------------------------------------------------------------------------

  /// Puxar para atualizar: busca de novo o que ficou na bandeja do celular.
  Future<void> refreshNotifications() async {
    if (_useMock) {
      _mock.assignAll(cdcMockNotifications());
      return;
    }
    await PushNotificationService().syncFromTray();
    await _inbox.load();
  }

  Future<void> openNotification(InboxNotification notification) async {
    if (!notification.read) _markRead(notification.id);

    final hasTarget = notification.link != null || _routeOf(notification) != null;
    await AppPopups.sheet<void>(
      title: notification.title.isEmpty ? null : notification.title,
      message: notification.body.isEmpty ? null : notification.body,
      icon: Icons.notifications_active_outlined,
      actions: (ctx) => [
        if (hasTarget)
          AppSheetButton.primary(
            label: 'abrir'.tr,
            onPressed: () {
              Navigator.of(ctx).pop();
              _openTarget(notification);
            },
          ),
        AppSheetButton.secondary(
          label: 'fechar'.tr,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ],
    );
  }

  /// Rota do app para abrir, se não for a própria Central.
  String? _routeOf(InboxNotification notification) {
    final route = notification.route;
    if (route == null || !route.startsWith('/') || route == Routes.CDC) {
      return null;
    }
    return route;
  }

  Future<void> _openTarget(InboxNotification notification) async {
    final link = notification.link;
    if (link != null) {
      final uri = Uri.tryParse(link);
      final opened = uri != null &&
          uri.host.isNotEmpty &&
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) AppPopups.error('cdc_nao_foi_possivel_abrir_link'.tr);
      return;
    }
    final route = _routeOf(notification);
    if (route != null) Get.toNamed(route);
  }

  void _markRead(String id) {
    if (!_useMock) {
      _inbox.markRead(id);
      return;
    }
    final i = _mock.indexWhere((n) => n.id == id);
    if (i >= 0) _mock[i] = _mock[i].copyWith(read: true);
  }

  Future<void> markAllNotificationsRead() async {
    if (_useMock) {
      _mock.assignAll(_mock.map((n) => n.copyWith(read: true)).toList());
      return;
    }
    await _inbox.markAllRead();
  }

  Future<void> clearNotifications() async {
    final ok = await AppPopups.confirm(
      title: 'cdc_limpar_notificacoes_titulo'.tr,
      message: 'cdc_limpar_notificacoes_msg'.tr,
      icon: Icons.delete_sweep_outlined,
      confirmText: 'limpar'.tr,
      destructive: true,
    );
    if (!ok) return;
    if (_useMock) {
      _mock.clear();
    } else {
      await _inbox.clear();
    }
  }
}
