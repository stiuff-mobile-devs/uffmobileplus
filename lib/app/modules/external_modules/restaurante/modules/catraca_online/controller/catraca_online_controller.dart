import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_catraca_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/area.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/operator_transaction.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/operator_transaction_offline.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/repository/catraca_online_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

class CatracaOnlineController extends GetxController {
  CatracaOnlineController();

  late ExternalCatracaService service;
  CatracaOnlineRepository repository = CatracaOnlineRepository();

  RxBool isAreaBusy = false.obs;
  RxBool isTransactionBusy = false.obs;
  RxBool isReadQRCodeBusy = false.obs;
  RxBool isNotFirstLoad = false.obs;
  RxBool isDetailResultBusy = false.obs;
  RxBool isManualValidationBusy = false.obs;
  RxBool isOfflineMode = false.obs;
  RxString statusMessage = "Catraca Online".obs;
  Rx<AreaModel> selectedArea = AreaModel().obs;

  late RxList<AreaModel> areas = <AreaModel>[].obs;

  late RxList<OperatorTransactionModel> operatorTransactions =
      <OperatorTransactionModel>[].obs;

  Rx<OperatorTransactionModel> selectedTransaction =
      OperatorTransactionModel().obs;

  late final String iduff;
  late String? token;

  bool isTransactionValid = false;
  bool isQrCodeValid = true;
  String transactionResultMessage = "";
  String transactionUsername = "";

  @override
  void onInit() {
    super.onInit();
    _initAsync();
  }

  Future<void> _initAsync() async {
    service = Get.find<ExternalCatracaService>();
    await service.initialize();
    iduff = service.getUserIdUFF();
    fetchAreas();
    update();
  }

  Future<void> fetchAreas() async {
    isAreaBusy.value = true;
    token = await service.getAccessToken();
    try {
      //Forçar error
      throw Exception("Forçando modo offline para testes");
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
      //Forçar error
      throw Exception("Forçando modo offline para testes");
      operatorTransactions.value = await repository.getOperatorTransactions(
        iduff,
        token!,
        selectedArea.value.id.toString(),
      );
      isOfflineMode.value = false;
      statusMessage.value = "Catraca Online";
    } catch (e) {
      isOfflineMode.value = true;
      statusMessage.value = "Catraca Offline";
    }

    isTransactionBusy.value = false;
  }

  void selectArea(index) {
    selectedArea.value = areas[index];
    fetchOperatorTransactions();
    Get.toNamed(Routes.VALIDAR_PAGAMENTO);
  }

  void readCode() {
    Get.toNamed(Routes.RESULTADO_PAGE);
  }

  void loadingQrCodeData() async {
    isReadQRCodeBusy.value = true;
    isNotFirstLoad.value = true;
    isOfflineMode.value = true; //TODO: So para testar o modo offline

    if (isOfflineMode.value) {
      statusMessage.value = "Catraca Offline";

      try {
        String? qrCodeScanRes = await _scanQRCode();

        if (qrCodeScanRes == null || qrCodeScanRes == "-1") {
          isReadQRCodeBusy.value = false;
          Get.back();
          return;
        }

        RegExp exp2 = RegExp(r"iduff=([0-9]+)");

        RegExpMatch? regMatch2 = exp2.firstMatch(qrCodeScanRes);

        if (regMatch2 != null) {
          String fullMatch = qrCodeScanRes;
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

            await repository.saveOperatorTransactionsOffline(
              operatorTransactionOffline,
            );
            await repository.saveOperatorTransactionToFirebase(
              operatorTransactionOffline,
            );

            transactionResultMessage = "Transação salva offline com sucesso!";
            transactionUsername = idUffValue;
            isTransactionValid = true;
            isQrCodeValid = true;
          } else {
            isTransactionValid = false;
            isQrCodeValid = false;
          }
        }
      } catch (e) {
        debugPrint('Erro ao ler código QR offline: $e');
      }
      isReadQRCodeBusy.value = false;
    } else {
      statusMessage.value = "Catraca Online";
      try {
        String? qrCodeScanRes = await _scanQRCode();

        if (qrCodeScanRes == null || qrCodeScanRes == "-1") {
          Get.back();
        } else {
          RegExp exp = RegExp(
            "^ididentificacao_iduff=([0-9]|[A-z])*&hash=([0-9]|[a-z]){40}\$",
          );

          String? match = exp.stringMatch(qrCodeScanRes);

          if (match == qrCodeScanRes) {
            Map responseMessage = await repository.validatePayment(
              qrCodeScanRes,
              iduff,
              token!,
              selectedArea.value.id.toString(),
            );
            transactionResultMessage = responseMessage["message"];
            isTransactionValid = responseMessage["valid"];

            if (responseMessage["name"] != null) {
              transactionUsername = responseMessage["name"];
            } else {
              transactionUsername = "";
            }
            isQrCodeValid = true;
          } else {
            isQrCodeValid = false;
          }
        }
      } catch (e) {}
    }
    isReadQRCodeBusy.value = false;
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
}
