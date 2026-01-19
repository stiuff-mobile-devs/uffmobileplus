import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/um_infos_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/controller/auth_google_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/gdi_groups.dart';

class LoginController extends GetxController {
  bool showQrCode = false;
  late String versionCode;
  late final AuthGoogleController _loginGoogleController;
  late UmInfosService _umInfosService;
  late UserDataController _userDataController;
  UserData _user = UserData();
  RxBool hasAdminPermission = false.obs;

  @override
  Future<void> onInit() async {
    _loginGoogleController = Get.find<AuthGoogleController>();
    _umInfosService = Get.find<UmInfosService>();
    versionCode = _umInfosService.version.value;
    _userDataController = Get.find<UserDataController>();
    _user = (await _userDataController.getUserData()) ?? UserData();
    _checkAdminPermission();
    super.onInit();
  }

  void _checkAdminPermission() {
    final groups = _user.gdiGroups;
    if (groups == null || groups.isEmpty) {
      hasAdminPermission.value = false;
      return;
    }
    hasAdminPermission.value = groups.any(
      (group) =>
          group.gid == GdiGroupsEnum.adminCardapioRestauranteUniversitario.id,
    );
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
