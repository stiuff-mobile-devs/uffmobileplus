import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/um_infos_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/controller/auth_google_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_google_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_iduff_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/gdi_groups.dart';

class LoginController extends GetxController {
  bool showQrCode = false;
  late String versionCode;
  late final AuthGoogleController _loginGoogleController;
  late UmInfosService _umInfosService;
  late AuthIduffService _authIduffService;

  late final UserGoogleRepository _userGoogleRepository;
  UserDataRepository userDataRepository = UserDataRepository();
  UserIduffRepository userIduffRepository = UserIduffRepository();

  UserData _user = UserData();
  RxBool hasAdminPermission = false.obs;
  RxBool hasActiveIduffBondObs = false.obs;
  RxBool hasActiveGoogleBondObs = false.obs;

  @override
  Future<void> onInit() async {
    _loginGoogleController = Get.find<AuthGoogleController>();
    _umInfosService = Get.find<UmInfosService>();
    _authIduffService = Get.find<AuthIduffService>();
    _userGoogleRepository = UserGoogleRepository();

    versionCode = _umInfosService.version.value;
    _user = (await userDataRepository.getUserData()) ?? UserData();
    _checkAdminPermission(GdiGroupsEnum.controladoresDeAcesso.id);
    _loadBondStates();
    super.onInit();
  }

  Future<bool> hasActiveGoogleBond() async {
    final currentUser = fb.FirebaseAuth.instanceFor(
      app: Firebase.app('uffmobileplus'),
    ).currentUser;
    final storedUser = await _userGoogleRepository.getUserGoogleModel();
    final hasStoredUser = storedUser != null && storedUser.email.isNotEmpty;
    return currentUser != null && hasStoredUser;
  }

  Future<bool> hasActiveIduffBond() async {
    final storedUser = await userIduffRepository.getUserIduffModel();
    final hasStoredUser =
        storedUser != null && (storedUser.iduff?.isNotEmpty ?? false);
    final isLogged = storedUser?.authData?.isLogged ?? false;
    final accessToken = await _authIduffService.getAccessToken();
    final hasToken = accessToken != null && accessToken.isNotEmpty;
    return hasStoredUser && isLogged && hasToken;
  }

  Future<void> _loadBondStates() async {
    hasActiveIduffBondObs.value = await hasActiveIduffBond();
    hasActiveGoogleBondObs.value = await hasActiveGoogleBond();
  }

  Future<void> reloadBondStates() async {
    await _loadBondStates();
  }

  void _checkAdminPermission(final gdi) {
    final groups = _user.gdiGroups;
    if (groups == null || groups.isEmpty) {
      hasAdminPermission.value = false;
      return;
    }
    hasAdminPermission.value = groups.any(
      (group) =>
          group.gid == gdi,
    );
  }
  void loginIDUFF() {
    Get.offAllNamed(
      Routes.AUTH,
      arguments: true,
    ); //Esse argumento é para iniciar a função de login automaticamente apenas quando o usuario aperta em login com iduff
  }

  void loginGoogle() {
    _loginGoogleController.loginGoogle();
  }

  void goToCarteirinhaPage() {
    Get.toNamed(Routes.CARTEIRINHA_DIGITAL);
  }

  void loginAnonimous() {
    Get.offAllNamed(Routes.HOME);
  }

  void goToCatracaOnlinePage() {
    Get.toNamed(Routes.CATRACA_ONLINE);
  }

  void logoutGoogle() {
    _loginGoogleController.logout();
  }
}
