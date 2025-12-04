import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_catraca_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/area.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/operator_transaction.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/operator_transaction_offline.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/repository/catraca_online_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'dart:async';

class CatracaOnlineController extends GetxController {
  CatracaOnlineController();

  late ExternalCatracaService service;
  CatracaOnlineRepository repository = CatracaOnlineRepository();

  RxBool isAreaBusy = false.obs;
  RxBool isTransactionBusy = false.obs;
  RxBool isReadQRCodeBusy = false.obs;
  RxBool isDetailResultBusy = false.obs;
  RxBool isManualValidationBusy = false.obs;
  RxBool isOfflineMode = false.obs;
  RxString statusMessage = "Catraca Online".obs;
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

  late final String iduff;
  late String? token;

  bool isTransactionValid = false;
  bool isQrCodeValid = true;
  String transactionResultMessage = "";
  String transactionUsername = "";
  Timer? _syncTimer;

  @override
  void onInit() {
    super.onInit();
    _initAsync();
  }

  Future<void> _initAsync() async {
    service = Get.find<ExternalCatracaService>();
    await service.initialize();
    iduff = service.getUserIdUFF();
    await fetchAreas();
    startOfflineSync();
    update();
  }

  Future<void> fetchAreas() async {
    isAreaBusy.value = true;
    token = await service.getAccessToken();
    try {
      areas.value = await repository.getAreas(iduff, token);
      isOfflineMode.value = false;
      statusMessage.value = "Catraca Online";
    } catch (e) {
      areas.value = await getOffLineAreas();
      isOfflineMode.value = true;
      statusMessage.value = "Catraca Offline";
    }
    isAreaBusy.value = false;
  }

  Future<void> fetchOperatorTransactions() async {
    isTransactionBusy.value = true;
    token = await service.getAccessToken();

    try {
      operatorTransactionsOffline.value = await repository
          .getOperatorTransactionsOffline();
    } catch (e) {
      debugPrint('Erro ao buscar transações offline: $e');
    }

    try {
      operatorTransactionsFromFirebase.value = await repository
          .getOperatorTransactionsFromFirebase();
    } catch (e) {
      debugPrint('Erro ao buscar transações offline do firebase: $e');
    }

    try {
      operatorTransactions.value = await repository.getOperatorTransactions(
        iduff,
        token!,
        selectedArea.value.id.toString(),
      );
    } catch (e) {
      debugPrint('Erro ao buscar transações online: $e');
    }

    isTransactionBusy.value = false;
  }

  void selectArea(index) {
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
          statusMessage.value = "Catraca Online";
          isOfflineMode.value = false;
          token = await service.getAccessToken();

          Map responseMessage = await repository.validatePayment(
            qrCodeScanRes,
            iduff,
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
          statusMessage.value = "Catraca Offline";
          isOfflineMode.value = true;
        }
      }
      // Validar pagamento offline
      else if (matchCarteirinhaDigital != null) {
        try {
          statusMessage.value = "Catraca Offline";
          isOfflineMode.value = true;

          RegExp expIdUff = RegExp(r"iduff=([0-9]+)");
          Iterable<RegExpMatch> matches = expIdUff.allMatches(qrCodeScanRes);
          String idUffValue = matches.isNotEmpty
              ? matches.last.group(1) ?? ""
              : "";

          if (RegExp(r'^\d{11}$').hasMatch(idUffValue)) {
            OperatorTransactionOffline operatorTransactionOffline =
                OperatorTransactionOffline(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  idUffUser: idUffValue,
                  idUffOperator: iduff,
                  idCampus: selectedArea.value.id.toString(),
                  campus: selectedArea.value.nome,
                );

            bool saveOperatorTransactionsOffline = false;
            bool saveOperatorTransactionToFirebase = false;

            // Salvando no Firebase
            try {
              await repository
                  .saveOperatorTransactionToFirebase(operatorTransactionOffline)
                  .timeout(const Duration(seconds: 5));
              saveOperatorTransactionToFirebase = true;
            } catch (e) {
              debugPrint('Erro ao salvar transação no Firebase: $e');
              saveOperatorTransactionToFirebase = false;
              // Salvando no banco local
              try {
                await repository.saveOperatorTransactionsOffline(
                  operatorTransactionOffline,
                );
                saveOperatorTransactionsOffline = true;
              } catch (e) {
                saveOperatorTransactionsOffline = false;
                debugPrint('Erro ao salvar transação offline: $e');
              }
            }

            if (saveOperatorTransactionsOffline ||
                saveOperatorTransactionToFirebase) {
              transactionResultMessage =
                  "Transação salva em modo OFFLINE com sucesso!";
              transactionUsername = idUffValue;
              isTransactionValid = true;
              isQrCodeValid = true;
            } else {
              transactionResultMessage =
                  "Falha ao salvar a transação offline. Erro Interno.";
              isTransactionValid = false;
              isQrCodeValid = false;
              transactionUsername = idUffValue;
            }
          } else {
            isTransactionValid = false;
            isQrCodeValid = false;
            transactionResultMessage = "Código QR inválido.";
            transactionUsername = "";
          }
        } catch (e) {
          debugPrint('Erro ao validar pagamento offline: $e');
          isTransactionValid = false;
          isQrCodeValid = false;
          transactionResultMessage = "Erro ao validar pagamento offline.";
          transactionUsername = "";
        }
      } else {
        isTransactionValid = false;
        isQrCodeValid = false;
        transactionResultMessage = "Código QR inválido.";
        transactionUsername = '';
      }
    } catch (e) {
      debugPrint('Erro ao ler código QR offline: $e');
      isTransactionValid = false;
      isQrCodeValid = false;
      transactionResultMessage = "Erro ao ler código QR offline.";
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
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          idUffUser: cpf,
          idUffOperator: iduff,
          idCampus: selectedArea.value.id.toString(),
          campus: selectedArea.value.nome,
        );

    bool saveOperatorTransactionsOffline = false;
    bool saveOperatorTransactionToFirebase = false;

    // Salvando no Firebase
    try {
      await repository
          .saveOperatorTransactionToFirebase(operatorTransactionOffline)
          .timeout(const Duration(seconds: 5));
      saveOperatorTransactionToFirebase = true;
    } catch (e) {
      debugPrint('Erro ao salvar transação no Firebase: $e');
      saveOperatorTransactionToFirebase = false;
      // Salvando no banco local
      try {
        await repository.saveOperatorTransactionsOffline(
          operatorTransactionOffline,
        );
        saveOperatorTransactionsOffline = true;
      } catch (e) {
        saveOperatorTransactionsOffline = false;
        debugPrint('Erro ao salvar transação offline: $e');
      }
    }

    if (saveOperatorTransactionsOffline || saveOperatorTransactionToFirebase) {
      transactionResultMessage = "Transação salva em modo OFFLINE com sucesso!";
      transactionUsername = cpf;
      isTransactionValid = true;
      isQrCodeValid = true;
    } else {
      transactionResultMessage =
          "Falha ao salvar a transação offline. Erro Interno.";
      isTransactionValid = false;
      isQrCodeValid = false;
      transactionUsername = cpf;
    }
  }

  void manualValidation() {
    isOfflineMode.value = true;
    statusMessage.value = "Catraca Offline";
    Get.toNamed(Routes.VALIDAR_MANUALMENTE);
  }

  void getResultPage() {
    Get.toNamed(Routes.RESULTADO_PAGE);
  }

  void toggleMode() {
    isOfflineMode.value = !isOfflineMode.value;
    statusMessage.value = isOfflineMode.value
        ? "Catraca Offline"
        : "Catraca Online";
    fetchOperatorTransactions();
  }

  /// Inicia checagem periódica (30s) para enviar transações locais ao Firebase.
  void startOfflineSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _syncOfflineTransactions();
    });
  }

  /// Para a checagem periódica.
  void stopOfflineSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Tenta enviar transações salvas no Hive ao Firebase (timeout 5s).
  /// Ao enviar com sucesso, remove a transação local.
  Future<void> _syncOfflineTransactions() async {
    try {
      final pending = await repository
          .getOperatorTransactionsOffline(); // retorna List<OperatorTransactionOffline>
      if (pending.isEmpty) return;

      for (final tx in pending) {
        try {
          await repository
              .saveOperatorTransactionToFirebase(tx)
              .timeout(const Duration(seconds: 5));
          // remover local após sucesso no Firebase
          try {
            // Ajuste o nome do método de delete conforme implementação do repositório.
            await repository.deleteOperatorTransactionOffline(tx.id);
          } catch (e) {
            debugPrint('Erro ao apagar transação local: $e');
          }
        } catch (e) {
          debugPrint('Erro ao enviar transação ao Firebase: $e');
          // se falhar, mantém no Hive para tentar novamente na próxima execução
        }
      }
    } catch (e) {
      debugPrint('Erro na sincronização offline: $e');
    }
  }
}
