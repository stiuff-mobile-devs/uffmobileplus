import 'package:all_validations_br/all_validations_br.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/area.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/catraca_transaction_item.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/catraca_validation_result.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/cpf_mask.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/operator_transaction.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/operator_transaction_offline.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/repository/catraca_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';
import 'dart:async';
import 'package:uffmobileplus/app/data/services/crash_reporter.dart';

class CatracaController extends GetxController {
  CatracaController();

  late ExternalModulesServices externalModulesServices;

  CatracaOnlineRepository repository = CatracaOnlineRepository();


  RxBool isAreaBusy = false.obs;
  RxBool isTransactionBusy = false.obs;
  RxBool isManualValidationBusy = false.obs;

  /// Conexão com a internet e o SCTM, mostrada no selo online/offline das
  /// telas. Só exibição: o caminho online/offline de cada validação continua
  /// sendo decidido na hora da validação.
  RxBool isConnected = true.obs;
  RxBool isCheckingConnection = false.obs;

  /// Horário do último lote de refeições offline enviado ao Firebase.
  Rxn<DateTime> lastSyncAt = Rxn<DateTime>();

  Rx<AreaModel> selectedArea = AreaModel().obs;

  late RxList<AreaModel> areas = <AreaModel>[].obs;

  late RxList<OperatorTransactionModel> operatorTransactions =
      <OperatorTransactionModel>[].obs;

  late RxList<OperatorTransactionOffline> operatorTransactionsOffline =
      <OperatorTransactionOffline>[].obs;

  /// Lista única da tela de validar pagamento: offline do operador nas
  /// últimas 24h (todos os campi) + online do SCTM do campus atual.
  final RxList<CatracaTransactionItem> recentItems =
      <CatracaTransactionItem>[].obs;

  /// Refeições do Hive ainda não enviadas ao Firebase (de qualquer operador,
  /// pois a sincronização envia todas).
  final RxInt pendingSyncCount = 0.obs;
  final RxBool isSyncing = false.obs;

  final Rxn<CatracaTransactionItem> selectedItem =
      Rxn<CatracaTransactionItem>();

  /// Desfecho da última validação, para a tela de resultado.
  final Rxn<CatracaValidationResult> lastResult =
      Rxn<CatracaValidationResult>();

  String? operatorIdUff;
  String? operatorEmailGoogle;
  String? operatorEmailUff;

  String? token;

  /// O aviso de "conta Google não autorizada" na sincronização automática
  /// aparece só uma vez por sessão da catraca.
  bool _permissionWarned = false;

  StreamSubscription<InternetStatus>? _connectionSubscription;
  Timer? _timer;
  int secondsRefresh = 300; // 5 minutos

  @override
  Future<void> onInit() async {
    super.onInit();
    _initAsync();
    _startInternetMonitoring();
  }

  Future<void> _initAsync() async {
    externalModulesServices = Get.find<ExternalModulesServices>();
    await reloadOperator();

    await fetchAreas();
    update();
  }

  /// Relê quem é o operador (ex.: depois de conectar/desconectar o Google
  /// pela tela de informações).
  Future<void> reloadOperator() async {
    await externalModulesServices.initialize();

    operatorIdUff = externalModulesServices.getUserIdUFF();
    // Sem conta Google o e-mail vem como '' (não null); tratar como ausente
    // para o `operatorEmailGoogle ?? operatorEmailUff` usar o e-mail IdUFF.
    operatorEmailGoogle = _nonEmpty(externalModulesServices.getUserEmailGoogle());
    try {
      operatorEmailUff = _nonEmpty(await externalModulesServices.getEmail());
    } catch (e) {
      debugPrint('Erro ao obter email uff do usuário: $e');
    }
  }

  /// Token do Firebase para o SCTM, com limite de 5s: a renovação vai à rede e
  /// não pode prender a catraca. Estourou ou falhou → segue sem token.
  Future<String> _firebaseToken() async {
    try {
      return await externalModulesServices.getFirebaseIdToken().timeout(
            const Duration(seconds: 5),
          ) ??
          '';
    } catch (e) {
      debugPrint('Token do Firebase indisponível: $e');
      return '';
    }
  }

  Future<void> fetchAreas() async {
    isAreaBusy.value = true;
    try {
      try {
        await repository.cleanMore24hTransactionsOffline();
      } catch (e) {
        debugPrint('Erro ao tentar limpar dados: $e');
      }
      try {
        token = await externalModulesServices.getAccessToken();
        final result = await repository
            .getAreas(operatorIdUff ?? '', token, await _firebaseToken())
            .timeout(const Duration(seconds: 5));
        if (result.isEmpty) {
          // O SCTM respondeu com erro (ex.: sem permissão) ou sem áreas.
          await _useContingencyAreas();
        } else {
          areas.value = result;
          await repository.saveAreas(result);
          _updateStatusMessage(true);
        }
      } on TimeoutException catch (_) {
        debugPrint('A conexão demorou muito para responder.');
        await _useContingencyAreas();
      } catch (e, s) {
        CrashReporter.recordError(e, s, reason: 'buscar áreas da catraca');
        await _useContingencyAreas();
      }
    } finally {
      isAreaBusy.value = false;
    }
  }

  /// Áreas quando o SCTM não respondeu: a última lista salva do SCTM ou, se
  /// nunca houve, a lista fixa.
  Future<void> _useContingencyAreas() async {
    final saved = await repository.getSavedAreas();
    areas.value = saved.isNotEmpty ? saved : await getOffLineAreas();
    _updateStatusMessage(false);
    AppPopups.warning(
      'catraca_areas_salvas_msg'.tr,
      title: 'catraca_areas_falhou'.tr,
    );
  }

  /// Refaz o teste de internet + SCTM e atualiza o selo online/offline.
  Future<void> checkConnection() async {
    if (isCheckingConnection.value) return;
    isCheckingConnection.value = true;
    try {
      final hasInternet = await InternetConnection().hasInternetAccess;
      isConnected.value = hasInternet && await repository.getSctmStatus();
    } catch (e) {
      debugPrint('Erro ao verificar conexão da catraca: $e');
      isConnected.value = false;
    } finally {
      isCheckingConnection.value = false;
    }
  }

  /// Refresh da tela de validar pagamento: conexão + transações.
  Future<void> refreshTransactions() async {
    await checkConnection();
    await fetchOperatorTransactions();
  }

  Future<void> fetchOperatorTransactions() async {
    isTransactionBusy.value = true;
    try {
      try {
        operatorTransactionsOffline.value = await repository
            .getOperatorTransactionsOffline();
      } catch (e) {
        debugPrint('Erro ao buscar transações offline: $e');
      }

      // Limpa antes: se a busca falhar, não mostra as do campus anterior.
      operatorTransactions.clear();
      try {
        token = await externalModulesServices.getAccessToken();
        operatorTransactions.value = await repository
            .getOperatorTransactions(
              operatorIdUff ?? '',
              token ?? '',
              selectedArea.value.id.toString(),
              await _firebaseToken(),
            )
            .timeout(const Duration(seconds: 8));
      } on TimeoutException catch (_) {
        AppPopups.warning(
          'catraca_timeout_lista_msg'.tr,
          title: 'catraca_timeout_lista'.tr,
        );
      } catch (e, s) {
        CrashReporter.recordError(e, s, reason: 'buscar transações online da catraca');
        debugPrint('Erro ao buscar transações online: $e');
      }

      try {
        await syncOfflineTransactions();
      } catch (e) {
        debugPrint('Erro ao sincronizar transações offline: $e');
      }
      await _buildRecentItems();
    } finally {
      isTransactionBusy.value = false;
    }
  }

  /// Monta [recentItems] e [pendingSyncCount] a partir do Hive (relido, pois a
  /// sincronização acima pode ter marcado itens como enviados) e da lista
  /// online já buscada.
  Future<void> _buildRecentItems() async {
    try {
      operatorTransactionsOffline.value = await repository
          .getOperatorTransactionsOffline();
    } catch (e) {
      debugPrint('Erro ao reler transações offline: $e');
    }

    final offline = operatorTransactionsOffline;
    pendingSyncCount.value = offline.where((tx) => tx.isSynced != true).length;

    // Um operador por aparelho: mostra tudo o que está no aparelho.
    final operator = operatorEmailGoogle ?? operatorEmailUff ?? '';
    final since = DateTime.now().subtract(const Duration(hours: 24));

    final items = <CatracaTransactionItem>[
      ...offline
          .where((tx) => tx.entryTime.isAfter(since))
          .map(CatracaTransactionItem.fromOffline),
      ...operatorTransactions.map(
        (tx) => CatracaTransactionItem.fromOnline(
          tx,
          campus: selectedArea.value.nome,
          operator: operator.isEmpty ? null : operator,
        ),
      ),
    ];

    items.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });
    recentItems.assignAll(items);
  }

  /// Botão "Sincronizar" da tela de validar pagamento: envia os pendentes ao
  /// Firebase (mesma rotina automática) e recarrega a lista.
  Future<void> syncNow() async {
    if (isSyncing.value) return;
    isSyncing.value = true;
    try {
      await syncOfflineTransactions(manual: true);
      await fetchOperatorTransactions();
      if (pendingSyncCount.value > 0 && !_permissionWarned) {
        AppPopups.warning(
          'msg_verifique_internet'.tr,
          title: 'catraca_sincronizacao_falhou'.tr,
        );
      } else {
        AppPopups.success('catraca_tudo_sincronizado'.tr);
      }
    } finally {
      isSyncing.value = false;
    }
  }

  /// Lê e valida um QR code. Retorna `false` quando a leitura é cancelada
  /// (nada a mostrar).
  Future<bool> loadingQrCodeData() async {
    try {
      isTransactionBusy.value = true;
      // true quando o SCTM deu a palavra final (aprovou ou recusou): aí não
      // há caminho offline.
      bool isSctmCompleted = false;
      String? qrCodeScanRes = await _scanQRCode();

      if (qrCodeScanRes == null || qrCodeScanRes == "-1") {
        // O leitor já fechou; não há tela extra para tirar da pilha.
        return false;
      }

      final expCarteirinhaPagamento = RegExp(
        r"ididentificacao_iduff=([0-9a-zA-Z]+)&hash=([0-9a-fA-F]{40})",
      );

      final expCarteirinhaIdentificacao = RegExp(
        r"ididentificacao_iduff=([0-9a-zA-Z]+)",
      );

      String? idIdentificacaoIduff;
      String? stringCarteirinhaPagamento;

      // Verifica se é o QR Code específico de PAGAMENTO (ID + HASH)
      final matchPagamento = expCarteirinhaPagamento.firstMatch(qrCodeScanRes);

      if (matchPagamento != null) {
        idIdentificacaoIduff = matchPagamento.group(1);
        stringCarteirinhaPagamento = matchPagamento.group(0);
      } else {
        final matchIdentificacao = expCarteirinhaIdentificacao.firstMatch(
          qrCodeScanRes,
        );

        if (matchIdentificacao != null) {
          idIdentificacaoIduff = matchIdentificacao.group(1);
        }
      }

      // Validar pagamento online
      if (stringCarteirinhaPagamento == qrCodeScanRes) {
        try {
          token = await externalModulesServices.getAccessToken();

          Map responseMessage = await repository.validatePayment(
            qrCodeScanRes,
            operatorIdUff!,
            token!,
            selectedArea.value.id.toString(),
            await _firebaseToken(),
          );

          // Campos lidos com segurança: um nome ausente não pode virar
          // exceção e desviar uma recusa para a contingência.
          final bool approved = responseMessage["valid"] == true;
          // "responded" == false: falha de comunicação (sem internet,
          // timeout, erro do servidor) → segue para o offline.
          final bool responded = responseMessage["responded"] == true;
          isSctmCompleted = responded;
          _updateStatusMessage(responded);

          if (approved) {
            final name = responseMessage["name"]?.toString();
            _setResult(
              CatracaResultKind.approvedSctm,
              name: name,
              item: CatracaTransactionItem.fromOnline(
                OperatorTransactionModel(
                  name: name,
                  value: responseMessage["message"]?.toString(),
                  area: selectedArea.value.nome,
                  date: DateTime.now(),
                ),
                campus: selectedArea.value.nome,
                operator: operatorEmailGoogle ?? operatorEmailUff,
              ),
            );
          } else if (responded) {
            // Recusa de fato (saldo, QR expirado, hash inválido): não libera
            // e não salva offline.
            _setResult(
              CatracaResultKind.rejected,
              message: responseMessage["message"]?.toString(),
              name: responseMessage["name"]?.toString(),
            );
          }
        } catch (e, s) {
          CrashReporter.recordError(e, s, reason: 'validar pagamento online na catraca');
          debugPrint('Erro ao validar pagamento online: $e');
          _updateStatusMessage(false);
        }
      }
      // Validar pagamento offline
      if (!isSctmCompleted) {
        try {
          if (RegExp(r'^[0-9a-zA-Z]+$').hasMatch(idIdentificacaoIduff ?? '')) {
            OperatorTransactionOffline operatorTransactionOffline =
                OperatorTransactionOffline(
                  idUser: idIdentificacaoIduff,
                  idOperator: operatorEmailGoogle ?? operatorEmailUff ?? '',
                  idCampus: selectedArea.value.id.toString(),
                  campus: selectedArea.value.nome,
                );

            bool isDuplicate = await repository.isTransactionDuplicated(
              operatorTransactionOffline.idUser ?? '',
              operatorTransactionOffline.entryTime,
            );

            if (isDuplicate) {
              _setResult(
                CatracaResultKind.duplicate,
                name: idIdentificacaoIduff,
              );
            } else {
              // Salvando no banco local
              try {
                await repository.saveOperatorTransactionsOffline(
                  operatorTransactionOffline,
                );
                _setResult(
                  CatracaResultKind.savedOffline,
                  name: idIdentificacaoIduff,
                  item: CatracaTransactionItem.fromOffline(
                    operatorTransactionOffline,
                  ),
                );
              } catch (e, s) {
                CrashReporter.recordError(e, s, reason: 'salvar transação offline da catraca');
                debugPrint('Erro ao salvar transação offline: $e');
                _setResult(
                  CatracaResultKind.error,
                  message: 'erro_salvar_transacao_offline'.tr,
                  name: idIdentificacaoIduff,
                );
              }
            }
          } else {
            _setResult(CatracaResultKind.invalidCode);
          }
        } catch (e, s) {
          CrashReporter.recordError(e, s, reason: 'validar pagamento offline na catraca');
          debugPrint('Erro ao validar pagamento offline: $e');
          _setResult(
            CatracaResultKind.error,
            message: 'erro_validar_pagamento_offline'.tr,
          );
        }
      }
    } catch (e, s) {
      CrashReporter.recordError(e, s, reason: 'ler qr code na catraca');
      debugPrint('Erro ao ler código QR code: $e');
      _setResult(CatracaResultKind.error, message: 'erro_ler_qr_code'.tr);
    }
    return true;
  }

  Future<List<AreaModel>> getOffLineAreas() async {
    return [
      AreaModel(id: 4, nome: 'R.U. do Gragoatá'),
      AreaModel(id: 9, nome: 'R.U. da Praia Vermelha'),
      AreaModel(id: 12, nome: 'R.U. Veterinária'),
      AreaModel(id: 13, nome: 'R.U. HUAP'),
      AreaModel(id: 14, nome: 'R.U. Reitoria'),
      AreaModel(id: 17, nome: 'Coluni'),
    ];
  }

  Future<bool> cpfIsValid(String cpf) async {
    return await Future.value(AllValidations.isCpf(cpf));
  }

  Future<void> saveCpfValidationTransaction(String cpf) async {
    OperatorTransactionOffline operatorTransactionOffline =
        OperatorTransactionOffline(
          idUser: cpf,
          idOperator: operatorEmailGoogle ?? operatorEmailUff ?? '',
          idCampus: selectedArea.value.id.toString(),
          campus: selectedArea.value.nome,
          isIduff: true,
        );
    bool isDuplicate = await repository.isTransactionDuplicated(
      operatorTransactionOffline.idUser ?? '',
      operatorTransactionOffline.entryTime,
    );
    if (isDuplicate) {
      _setResult(CatracaResultKind.duplicate, name: maskCpf(cpf));
    } else {
      try {
        await repository.saveOperatorTransactionsOffline(
          operatorTransactionOffline,
        );
        _setResult(
          CatracaResultKind.savedOffline,
          name: maskCpf(cpf),
          item: CatracaTransactionItem.fromOffline(operatorTransactionOffline),
        );
      } catch (e, s) {
        CrashReporter.recordError(e, s, reason: 'salvar validação manual por cpf na catraca');
        debugPrint('Erro ao salvar transação offline: $e');
        _setResult(
          CatracaResultKind.error,
          message: 'falha_salvar_transacao_offline'.tr,
          name: maskCpf(cpf),
        );
      }
    }
  }

  void selectArea(int index) {
    selectedArea.value = areas[index];
    fetchOperatorTransactions();
    Get.toNamed(Routes.VALIDAR_PAGAMENTO);
  }

  Future<void> readCode() async {
    final hasResult = await loadingQrCodeData();
    isTransactionBusy.value = false;
    if (hasResult) await _showResult();
  }

  /// Abre o resultado sempre por cima da lista: o "voltar" do resultado leva à
  /// lista, sem empilhar resultados ou a tela manual.
  Future<void> _showResult() async {
    await _buildRecentItems();
    Get.until(
      (route) =>
          route.settings.name == Routes.VALIDAR_PAGAMENTO || route.isFirst,
    );
    Get.toNamed(Routes.RESULTADO_PAGE);
  }

  void _setResult(
    CatracaResultKind kind, {
    String? message,
    String? name,
    CatracaTransactionItem? item,
  }) {
    lastResult.value = CatracaValidationResult(
      kind: kind,
      message: message,
      name: name,
      item: item,
    );
  }

  static String? _nonEmpty(String? value) =>
      (value == null || value.trim().isEmpty) ? null : value.trim();

  Future<String?> _scanQRCode() async {
    final result = await Get.toNamed(Routes.LEITOR_QRCODE);
    return result as String?;
  }

  void manualValidation() {
    Get.toNamed(Routes.VALIDAR_MANUALMENTE);
  }

  /// Depois da liberação manual.
  Future<void> getResultPage() => _showResult();

  void goToDetalhado(CatracaTransactionItem item) {
    selectedItem.value = item;
    Get.toNamed(Routes.RESULTADO_DETALHADO_PAGE);
  }

  /// Sincronização em andamento: chamadas concorrentes (timer, reconexão,
  /// botão, lista) esperam a mesma em vez de enviar os mesmos itens de novo.
  Future<void>? _runningSync;

  /// [manual]: chamada pelo botão Sincronizar. Muda só a frequência do aviso
  /// de conta sem permissão (sempre no manual, uma vez por sessão no
  /// automático).
  Future<void> syncOfflineTransactions({bool manual = false}) {
    if (manual) _permissionWarned = false;
    return _runningSync ??= _syncOfflineTransactions().whenComplete(
      () => _runningSync = null,
    );
  }

  Future<void> _syncOfflineTransactions() async {
  try {
    List<OperatorTransactionOffline> allTransactions = await repository
        .getOperatorTransactionsOffline();

    // Filtra apenas as transações que ainda não foram sincronizadas
    List<OperatorTransactionOffline> pending = allTransactions
        .where((tx) => tx.isSynced == false)
        .toList();

    if (pending.isEmpty) return;

    const int batchSize = 400; 
    
    // Divide as transações pendentes em lotes e processa cada lote
    for (int i = 0; i < pending.length; i += batchSize) {
      int end = (i + batchSize < pending.length) 
          ? i + batchSize 
          : pending.length;
          
      List<OperatorTransactionOffline> currentBatch = pending.sublist(i, end);

      try {
        // Tenta enviar o lote atual para o Firebase
        await repository.saveOperatorTransactionsToFirebaseBatch(currentBatch)
            .timeout(const Duration(seconds: 15)); 

        // Se a sincronização for bem-sucedida, marca as transações como sincronizadas
        List<OperatorTransactionOffline> syncedBatch = currentBatch
            .map((tx) => tx.copyWith(isSynced: true))
            .toList();

        // Atualiza o status das transações no banco local
        await repository.saveOperatorTransactionsOfflineBatch(syncedBatch);
        lastSyncAt.value = DateTime.now();
        
        debugPrint('Batch of ${currentBatch.length} transactions synced successfully!');
        
      } catch (e, s) {
        if (_isPermissionDenied(e)) {
          // Conta Google fora da lista de operadores do Firebase: esperado,
          // não vira relato. Os demais lotes falhariam igual.
          _warnPermissionDenied();
          return;
        }
        CrashReporter.recordError(e, s, reason: 'sincronizar lote de transações offline da catraca');
        debugPrint('Error syncing batch ($i to $end): $e');
      }
    }
  } catch (e, s) {
    CrashReporter.recordError(e, s, reason: 'sincronizar transações offline da catraca');
    debugPrint('General error in offline synchronization: $e');
  }
}

  /// O provider relança os erros do Firestore como `Exception('...: $e')`,
  /// então procura o código também no texto.
  bool _isPermissionDenied(Object e) {
    if (e is FirebaseException) return e.code == 'permission-denied';
    return e.toString().contains('permission-denied');
  }

  void _warnPermissionDenied() {
    if (_permissionWarned) return;
    _permissionWarned = true;
    AppPopups.warning(
      'catraca_sem_permissao_firebase_msg'.tr,
      title: 'catraca_sem_permissao_firebase'.tr,
    );
  }

  /// Saída da catraca com refeições pendentes: avisa que estão seguras e
  /// oferece sincronizar. Retorna `true` se pode sair.
  Future<bool> confirmLeave() async {
    await _buildRecentItems();
    final pending = pendingSyncCount.value;
    if (pending == 0) return true;
    final syncNowChosen = await AppPopups.confirm(
      title: 'catraca_sair_pendentes_titulo'.trParams({'quantidade': '$pending'}),
      message: 'catraca_sair_pendentes_msg'.tr,
      icon: Icons.cloud_upload_rounded,
      type: PopupType.warning,
      confirmText: 'catraca_sincronizar_agora'.tr,
      cancelText: 'catraca_sair_mesmo_assim'.tr,
      dismissible: false,
    );
    if (!syncNowChosen) return true;
    await syncNow();
    return pendingSyncCount.value == 0;
  }

  void _startInternetMonitoring() {
    // Escuta as mudanças de status da internet
    _connectionSubscription = InternetConnection().onStatusChange.listen((
      InternetStatus status,
    ) {
      switch (status) {
        case InternetStatus.connected:
          debugPrint('Sincronizando catraca...');
          // Envia o que ficou pendente assim que a internet volta.
          syncOfflineTransactions();
          _startTimer(secondsRefresh);
          break;
        case InternetStatus.disconnected:
        debugPrint('Desconectado da internet. Disconectando catraca...');
          _timer?.cancel();
          break;
      }
    });
  }

  void _startTimer(int secondsRefresh) {
    // Um timer só: cada reconexão criava outro sem cancelar o anterior.
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: secondsRefresh), (timer) {
      
      syncOfflineTransactions();
    });
  }

  /// Atualiza o selo do topo (SCTM ativo / Contingência).
  void _updateStatusMessage(bool isOnline) {
    isConnected.value = isOnline;
  }

  @override
  void onClose() {
    _connectionSubscription?.cancel();
    _timer?.cancel();
    super.onClose();
  }
}
