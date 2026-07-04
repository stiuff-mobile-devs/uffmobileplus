import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/area.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/operator_transaction.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/operator_transaction_offline.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/repository/catraca_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_google_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_google_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'dart:async';

class CatracaController extends GetxController {
  CatracaController();

  late ExternalModulesServices externalModulesServices;

  CatracaOnlineRepository repository = CatracaOnlineRepository();
  UserGoogleRepository userGoogleRepository = UserGoogleRepository();

  UserGoogleModel _userGoogleModel = UserGoogleModel(email: '');

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
  String? operatorEmail;
  String? identificador;

  String? token;

  bool isTransactionValid = false;
  bool isQrCodeValid = true;
  String transactionResultMessage = "";
  String transactionUsername = "";

  StreamSubscription<InternetStatus>? _connectionSubscription;
  Timer? _timer;
  int secondsRefresh = 60;

  @override
  Future<void> onInit() async {
    super.onInit();
    _initAsync();
    _startInternetMonitoring();
  }

  Future<void> _initAsync() async {
    externalModulesServices = Get.find<ExternalModulesServices>();
    await externalModulesServices.initialize();
    _userGoogleModel =
        (await userGoogleRepository.getUserGoogleModel()) ??
        UserGoogleModel(email: '');

    String iduff = externalModulesServices.getUserIdUFF();
    String email = _userGoogleModel.email;

    if (iduff == "" && email != "") {
      identificador = email;
      operatorEmail = email;
    } else if (iduff != "" && email == "") {
      identificador = iduff;
      operatorIdUff = iduff;
    } else if (iduff != "" && email != "") {
      identificador = iduff;
      operatorIdUff = iduff;
      operatorEmail = email;
    }

    await fetchAreas();
    update();
  }

  Future<void> fetchAreas() async {
    isAreaBusy.value = true;
    await repository.cleanMore24hTransactionsOffline();
    token = await externalModulesServices.getAccessToken();
    try {
      areas.value = await repository.getAreas(operatorIdUff ?? '', token);
      isOfflineMode.value = false;
      statusMessage.value = 'catraca_online'.tr;
    } catch (e) {
      areas.value = await getOffLineAreas();
      isOfflineMode.value = true;
      statusMessage.value = 'catraca_offline'.tr;
    }
    isAreaBusy.value = false;
  }

  Future<void> fetchOperatorTransactions() async {
    isTransactionBusy.value = true;
    await repository.cleanMore24hTransactionsOffline();
    token = await externalModulesServices.getAccessToken();

    try {
      operatorTransactionsOffline.value = await repository
          .getOperatorTransactionsOffline();
    } catch (e) {
      debugPrint('Erro ao buscar transações offline: $e');
    }

    try {
      operatorTransactionsFromFirebase.value = await repository
          .getOperatorTransactionsFromFirebase(identificador ?? '');
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

    isTransactionBusy.value = false;
    syncOfflineTransactions();
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

  Future<void> loadingQrCodeData() async {
    isReadQRCodeBusy.value = true;

    try {
      isTransactionBusy.value = true;
      String? qrCodeScanRes = await _scanQRCode();

      if (qrCodeScanRes == null || qrCodeScanRes == "-1") {
        isReadQRCodeBusy.value = false;
        Get.back();
        return;
      }

      // Carteirinha Digital
      RegExp expCarteirinhaDital = RegExp(r"iduff=([0-9]+)");
      RegExpMatch? matchCarteirinhaDigital = expCarteirinhaDital.firstMatch(
        qrCodeScanRes,
      );

      // Carteirinha de Pagamento
      RegExp expCarteirinhaPagamento = RegExp(
        "^ididentificacao_iduff=([0-9]|[A-z])*&hash=([0-9]|[a-z]){40}\$",
      );
      String? matchCarteirinhaPagamento = expCarteirinhaPagamento.stringMatch(
        qrCodeScanRes,
      );

      // Validar pagamento online
      if (matchCarteirinhaPagamento == qrCodeScanRes) {
        try {
          statusMessage.value = 'catraca_online'.tr;
          isOfflineMode.value = false;
          token = await externalModulesServices.getAccessToken();

          Map responseMessage = await repository.validatePayment(
            qrCodeScanRes,
            operatorIdUff!,
            token!,
            selectedArea.value.id.toString(),
          );

          transactionResultMessage = responseMessage["message"];
          isTransactionValid = responseMessage["valid"];
          isQrCodeValid = true;

          if (responseMessage["name"] != null) {
            transactionUsername = responseMessage["name"];
          } else {
            transactionUsername = "";
          }
        } catch (e) {
          debugPrint('Erro ao validar pagamento online: $e');
          isTransactionValid = false;
          isQrCodeValid = false;
          statusMessage.value = 'catraca_offline'.tr;
          isOfflineMode.value = true;
        }
      }
      // Validar pagamento offline
      else if (matchCarteirinhaDigital != null) {
        try {
          statusMessage.value = 'catraca_offline'.tr;
          isOfflineMode.value = true;

          RegExp expIdUff = RegExp(r"iduff=([0-9]+)");
          Iterable<RegExpMatch> matches = expIdUff.allMatches(qrCodeScanRes);
          String idUffValue = matches.isNotEmpty
              ? matches.last.group(1) ?? ""
              : "";

          if (RegExp(r'^\d{11}$').hasMatch(idUffValue)) {
            OperatorTransactionOffline operatorTransactionOffline =
                OperatorTransactionOffline(
                  idUffUser: idUffValue,
                  idUffOperator: identificador,
                  idCampus: selectedArea.value.id.toString(),
                  campus: selectedArea.value.nome,
                );

            bool isDuplicate = await repository.isTransactionDuplicated(
              operatorTransactionOffline.idUffUser ?? '',
              operatorTransactionOffline.entryTime,
            );

            if (isDuplicate) {
              transactionResultMessage = 'transacao_duplicada'.tr;
              transactionUsername = idUffValue;
              isTransactionValid = false;
              isQrCodeValid = true;
            } else {
              // Salvando no banco local

              await repository.saveOperatorTransactionsOffline(
                operatorTransactionOffline,
              );

              transactionResultMessage = 'transacao_offline_salva_sucesso'.tr;
              transactionUsername = idUffValue;
              isTransactionValid = true;
              isQrCodeValid = true;
            }
          } else {
            isTransactionValid = false;
            isQrCodeValid = false;
            transactionResultMessage = 'codigo_qr_invalido'.tr;
            transactionUsername = "";
          }
        } catch (e) {
          debugPrint('Erro ao validar pagamento offline: $e');
          isTransactionValid = false;
          isQrCodeValid = false;
          transactionResultMessage = 'erro_validar_pagamento_offline'.tr;
          transactionUsername = "";
        }
      } else {
        isTransactionValid = false;
        isQrCodeValid = false;
        transactionResultMessage = 'codigo_qr_invalido'.tr;
        transactionUsername = '';
      }
    } catch (e) {
      debugPrint('Erro ao ler código QR offline: $e');
      isTransactionValid = false;
      isQrCodeValid = false;
      transactionResultMessage = 'erro_ler_qr_offline'.tr;
      transactionUsername = "";
    }
    isReadQRCodeBusy.value = false;
    return;
  }

  Future<String?> _scanQRCode() async {
    final result = await Get.toNamed(Routes.LEITOR_QRCODE);
    return result as String?;
  }

  void goToDetalhado(OperatorTransactionModel transaction) {
    selectedTransaction.value = transaction;
    Get.toNamed(
      Routes.RESULTADO_DETALHADO_PAGE,
      arguments: {'operatorTransaction': transaction},
    );
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
          idUffUser: cpf,
          idUffOperator: identificador,
          idCampus: selectedArea.value.id.toString(),
          campus: selectedArea.value.nome,
        );
    bool isDuplicate = await repository.isTransactionDuplicated(
      operatorTransactionOffline.idUffUser ?? '',
      operatorTransactionOffline.entryTime,
    );
    if (isDuplicate) {
      transactionResultMessage = 'transacao_duplicada'.tr;
      transactionUsername = cpf;
      isTransactionValid = false;
      isQrCodeValid = true;
    } else {
      try {
        await repository.saveOperatorTransactionsOffline(
          operatorTransactionOffline,
        );
        isOfflineMode = true.obs;
        statusMessage.value = "Catraca Online";
        transactionResultMessage = "Transação salva localmente com sucesso!";
        transactionUsername = cpf;
        isTransactionValid = true;
        isQrCodeValid = true;
      } catch (e) {
        debugPrint('Erro ao salvar transação offline: $e');
        transactionResultMessage =
            "Falha ao salvar a transação. Erro Interno. Tente novamente.";
        isTransactionValid = false;
        isQrCodeValid = false;
        transactionUsername = cpf;
      }
    }
  }

  void manualValidation() {
    Get.toNamed(Routes.VALIDAR_MANUALMENTE);
  }

  void getResultPage() {
    Get.toNamed(Routes.RESULTADO_PAGE);
  }

  /// Tenta enviar transações salvas no Hive ao Firebase (timeout 5s).
  Future<void> syncOfflineTransactions() async {
    try {
      List<OperatorTransactionOffline> allTransactions = await repository
          .getOperatorTransactionsOffline();

      // Filtra apenas o que ainda NÃO foi sincronizado
      List<OperatorTransactionOffline> pending = allTransactions
          .where((tx) => tx.isSynced == false)
          .toList();

      if (pending.isEmpty) return;

      for (OperatorTransactionOffline tx in pending) {
        try {
          // Envia para o Firebase
          await repository
              .saveOperatorTransactionToFirebase(tx)
              .timeout(const Duration(seconds: 5));

          // Atualiza o status localmente para sincronizado
          try {
            // Cria uma cópia ou nova instância alterando apenas a flag
            final updatedTx = tx.copyWith(isSynced: true);

            // Salva por cima do registro antigo no Hive usando o id
            await repository.saveOperatorTransactionsOffline(updatedTx);
          } catch (e) {
            debugPrint('Erro ao atualizar status de sincronização local: $e');
          }
        } catch (e) {
          debugPrint('Erro ao enviar transação ao Firebase: $e');
          // Se falhar (timeout ou sem rede), continua isSynced = false para tentar na próxima
        }
      }
    } catch (e) {
      debugPrint('Erro na sincronização offline: $e');
    }
  }

  void _startInternetMonitoring() {
    // Escuta as mudanças de status da internet
    _connectionSubscription = InternetConnection().onStatusChange.listen((
      InternetStatus status,
    ) {
      switch (status) {
        case InternetStatus.connected:
          _startTimer(secondsRefresh);
          break;
        case InternetStatus.disconnected:
          _timer?.cancel();
          break;
      }
    });
  }

  void _startTimer(int secondsRefresh) {
    _timer = Timer.periodic(Duration(seconds: secondsRefresh), (timer) {
      debugPrint('Sincronizando catraca...');
      syncOfflineTransactions();
    });
  }

  @override
  void onClose() {
    _connectionSubscription?.cancel();
    _timer?.cancel();
    super.onClose();
  }
}
