import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/um_infos_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/controller/auth_google_controller.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

class LoginController extends GetxController {
  bool showQrCode = false;
  late String versionCode;
  late final AuthGoogleController _loginGoogleController;
  late UmInfosService _umInfosService;

  @override
  onInit() {
    _loginGoogleController = Get.find<AuthGoogleController>();
    _umInfosService = Get.find<UmInfosService>();
    versionCode = _umInfosService.version.value;
    super.onInit();
  }

  loginIDUFF() {
    Get.offAllNamed(
      Routes.AUTH,
      arguments: true,
    ); //Esse argumento é para iniciar a função de login automaticamente apenas quando o usuario aperta em login com iduff
  }

  loginGoogle() {
    _loginGoogleController.loginGoogle();
  }

  goToCarteirinhaPage() {
    Get.toNamed(Routes.CARTEIRINHA_DIGITAL);
  }

  loginAnonimous() {
    Get.offAllNamed(Routes.HOME);
  }

  goToCatracaOnlinePage() {
    Get.toNamed(Routes.CATRACA_ONLINE);
  }
}
