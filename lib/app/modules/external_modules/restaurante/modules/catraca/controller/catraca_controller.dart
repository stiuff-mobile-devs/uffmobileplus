import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/area.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/operator_transaction.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/operator_transaction_offline.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/repository/catraca_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'dart:async';

class CatracaController extends GetxController {
  CatracaController();

  late ExternalModulesServices externalModulesServices;

  CatracaOnlineRepository repository = CatracaOnlineRepository();

  RxBool isAreaBusy = false.obs;
  RxBool isTransactionBusy = false.obs;
  RxBool isReadQRCodeBusy = false.obs;
  RxBool isDetailResultBusy = false.obs;
  RxBool isManualValidationBusy = false.obs;

  RxBool isOfflineMode = false.obs;
  RxString statusMessage = 'catraca_online'.tr.obs;

  Rx<AreaModel> selectedArea = AreaModel().obs;

  late RxList<AreaModel> areas = <AreaModel>[].obs;

  late RxList<OperatorTransactionModel> operatorTransactions =
      <OperatorTransactionModel>[].obs;

  late RxList<OperatorTransactionOffline> operatorTransactionsOffline =
      <OperatorTransactionOffline>[].obs;

  late RxList<OperatorTransactionOffline> operatorTransactionsFromFirebase =
      <OperatorTransactionOffline>[].obs;

  Rx<OperatorTransactionModel> selectedTransaction =
      OperatorTransactionModel().obs;

  String? operatorIdUff;
  String? operatorEmailGoogle;
  String? operatorEmailUff;

  String? token;

  bool isTransactionValid = false;
  bool isQrCodeValid = true;
  String transactionResultMessage = "";
  String transactionUsername = "";

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
    await externalModulesServices.initialize();

    operatorIdUff = externalModulesServices.getUserIdUFF();
    operatorEmailGoogle = externalModulesServices.getUserEmailGoogle();
    try {
      operatorEmailUff = await externalModulesServices.getEmail();
    } catch (e) {
      debugPrint('Erro ao obter email uff do usuário: $e');
    }

    await fetchAreas();
    update();
  }

  Future<void> fetchAreas() async {
    isAreaBusy.value = true;
    try {
      await repository.cleanMore24hTransactionsOffline();
    } catch (e) {
      debugPrint('Erro ao tentar limpar dados: $e');
    }
    token = await externalModulesServices.getAccessToken();
    try {
      areas.value = await repository
          .getAreas(operatorIdUff ?? '', token)
          .timeout(const Duration(seconds: 5));
          
      _updateStatusMessage(true);
    } on TimeoutException catch (_) {
      debugPrint('A conexão demorou muito para responder.');
      areas.value = await getOffLineAreas();
      _updateStatusMessage(false);
    } catch (e) {
      areas.value = await getOffLineAreas();
      _updateStatusMessage(false);
    }
    isAreaBusy.value = false;
  }

  Future<void> fetchOperatorTransactions() async {
    isTransactionBusy.value = true;
    token = await externalModulesServices.getAccessToken();

    try {
      operatorTransactionsOffline.value = await repository
          .getOperatorTransactionsOffline();
    } catch (e) {
      debugPrint('Erro ao buscar transações offline: $e');
    }

    try {
      operatorTransactionsFromFirebase.value = await repository
          .getOperatorTransactionsFromFirebase(
            operatorEmailGoogle ?? operatorEmailUff ?? '',
          );
    } catch (e) {
      debugPrint('Erro ao buscar transações offline do firebase: $e');
    }

    try {
      operatorTransactions.value = await repository.getOperatorTransactions(
        operatorIdUff ?? '',
        token ?? '',
        selectedArea.value.id.toString(),
      );
    } catch (e) {
      debugPrint('Erro ao buscar transações online: $e');
    }
    
    try{
      await syncOfflineTransactions();
    }
    catch(e){
      debugPrint('Erro ao sincronizar transações offline: $e');
    }
    isTransactionBusy.value = false;
  }

  Future<void> loadingQrCodeData() async {
    isReadQRCodeBusy.value = true;

    try {
      isTransactionBusy.value = true;
      bool isSctmCompleted = false;
      String? qrCodeScanRes = await _scanQRCode();

      if (qrCodeScanRes == null || qrCodeScanRes == "-1") {
        isReadQRCodeBusy.value = false;
        Get.back();
        return;
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
          );

          _transactionResultMessages(
            responseMessage["message"],
            responseMessage["valid"],
            true,
            responseMessage["name"],
          );

          isSctmCompleted = responseMessage["valid"] ?? false;
          _updateStatusMessage(true);
        } catch (e) {
          debugPrint('Erro ao validar pagamento online: $e');
          _transactionResultMessages('', false, true, '');
          _updateStatusMessage(false);
        }
      }
      // Validar pagamento offline
      if (!isSctmCompleted) {
        try {
          _updateStatusMessage(false);

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
              _transactionResultMessages(
                'transacao_duplicada'.tr,
                false,
                true,
                idIdentificacaoIduff ?? '-',
              );
            } else {
              // Salvando no banco local
              try {
                await repository.saveOperatorTransactionsOffline(
                  operatorTransactionOffline,
                );
                _transactionResultMessages(
                  'transacao_offline_salva_sucesso'.tr,
                  true,
                  true,
                  idIdentificacaoIduff ?? '-',
                );
              } catch (e) {
                debugPrint('Erro ao salvar transação offline: $e');
                _transactionResultMessages(
                  'erro_salvar_transacao_offline'.tr,
                  false,
                  true,
                  idIdentificacaoIduff ?? '-',
                );
              }
            }
          } else {
            _transactionResultMessages(
              'codigo_qr_invalido'.tr,
              false,
              false,
              "",
            );
          }
        } catch (e) {
          debugPrint('Erro ao validar pagamento offline: $e');
          _transactionResultMessages(
            'erro_validar_pagamento_offline'.tr,
            false,
            false,
            "",
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao ler código QR code: $e');
      _transactionResultMessages('erro_ler_qr_code'.tr, false, false, "");
    }
    isReadQRCodeBusy.value = false;
    return;
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
      _transactionResultMessages('transacao_duplicada'.tr, false, true, cpf);
    } else {
      try {
        await repository.saveOperatorTransactionsOffline(
          operatorTransactionOffline,
        );
        _updateStatusMessage(false);
        _transactionResultMessages(
          'transacao_offline_salva_sucesso'.tr,
          true,
          true,
          cpf,
        );
      } catch (e) {
        debugPrint('Erro ao salvar transação offline: $e');
        _transactionResultMessages(
          'falha_salvar_transacao_offline'.tr,
          false,
          true,
          cpf,
        );
      }
    }
  }

  void selectArea(int index) {
    selectedArea.value = areas[index];
    fetchOperatorTransactions();
    Get.toNamed(Routes.VALIDAR_PAGAMENTO);
  }

  void readCode() async {
    await loadingQrCodeData();
    isTransactionBusy.value = false;
    Get.toNamed(Routes.RESULTADO_PAGE);
  }


  Future<String?> _scanQRCode() async {
    final result = await Get.toNamed(Routes.LEITOR_QRCODE);
    return result as String?;
  }

  void manualValidation() {
    Get.toNamed(Routes.VALIDAR_MANUALMENTE);
  }

  void getResultPage() {
    Get.toNamed(Routes.RESULTADO_PAGE);
  }

   void goToDetalhado(OperatorTransactionModel transaction) {
    selectedTransaction.value = transaction;
    Get.toNamed(
      Routes.RESULTADO_DETALHADO_PAGE,
      arguments: {'operatorTransaction': transaction},
    );
  }

  Future<void> syncOfflineTransactions() async {
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
        
        debugPrint('Batch of ${currentBatch.length} transactions synced successfully!');
        
      } catch (e) {
        debugPrint('Error syncing batch ($i to $end): $e');
      }
    }
  } catch (e) {
    debugPrint('General error in offline synchronization: $e');
  }
}

  void _startInternetMonitoring() {
    // Escuta as mudanças de status da internet
    _connectionSubscription = InternetConnection().onStatusChange.listen((
      InternetStatus status,
    ) {
      switch (status) {
        case InternetStatus.connected:
          debugPrint('Sincronizando catraca...');
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
    _timer = Timer.periodic(Duration(seconds: secondsRefresh), (timer) {
      
      syncOfflineTransactions();
    });
  }

  void _updateStatusMessage(bool isOnline) {
    if (isOnline) {
      statusMessage.value = 'catraca_online'.tr;
      isOfflineMode.value = false;
    } else {
      statusMessage.value = 'catraca_offline'.tr;
      isOfflineMode.value = true;
    }
  }

  void _transactionResultMessages(
    String message,
    bool isValid,
    bool qrCodeValid,
    String usernameValid,
  ) {
    transactionResultMessage = message;
    isTransactionValid = isValid;
    isQrCodeValid = qrCodeValid;
    if (usernameValid != null && usernameValid.isNotEmpty) {
      transactionUsername = usernameValid;
    } else {
      transactionUsername = "";
    }
  }

  @override
  void onClose() {
    _connectionSubscription?.cancel();
    _timer?.cancel();
    super.onClose();
  }
}
