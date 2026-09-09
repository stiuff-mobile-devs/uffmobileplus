import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/carteirinha_validador/repository/carteirinha_validador_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_alert_dialog.dart';

class CarteirinhaValidadorController extends GetxController {
  CarteirinhaValidadorController();

  RxBool isBusy = false.obs;

  CarteirinhaValidadorRepository repository = CarteirinhaValidadorRepository();
  final AuthIduffService _auth = Get.find<AuthIduffService>();

  List<dynamic> validationData = [];

  Future<void> scanQrCode() async {
    var result = await Get.toNamed(Routes.LEITOR_QR_CODE);
    if (result != null) {
      await _validateCard(result);
    }
  }

  Future<void> _validateCard(String qrCodeText) async {
    isBusy.value = true;
    try {
      validationData = [];
      validationData = await repository.validateCard(qrCodeText, _auth);
      await _buildResult();
    }catch (e) {
      await _buildResult(e.toString());
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> _buildResult([String? errorMessage]) async {
    if (validationData.isNotEmpty) {
      Get.toNamed(Routes.CARTEIRINHA_VALIDADOR_RESULTADO);
    } else {
      if (Get.context != null) {
        final dialog = idUffAlertDialog(
          Get.context!,
          title: 'resultado'.tr,
          desc: errorMessage ?? 'carteirinha_invalida_dados_nao_encontrados'.tr,
          btnConfirmText: 'ok'.tr,
          // keep default dialogType to match project style
        );
        dialog.show();
      } else {
        Get.snackbar('resultado'.tr, errorMessage ?? 'carteirinha_invalida_dados_nao_encontrados'.tr);
      }
    }


  }
}
