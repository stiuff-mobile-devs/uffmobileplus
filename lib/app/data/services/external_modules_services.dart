import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/notification_inbox_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/services/auth_google_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/utils/bond_actions.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/utils/bond_status.dart'
    as bond_status;
import 'package:uffmobileplus/app/modules/internal_modules/user/utils/crash_reporter_user.dart';
import 'package:uffmobileplus/app/utils/gdi_groups.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';
import 'package:uffmobileplus/app/utils/user_storage_key.dart';

class ExternalModulesServices extends GetxService {
  late UserDataController _userDataController;
  final UserDataRepository _userDataRepository = UserDataRepository();

  UserGoogleModel _userGoogleModel = UserGoogleModel(email: '');
  UserData _userData = UserData();

  late AuthIduffService _auth;
  late final AuthGoogleService _authGoogle = AuthGoogleService();

  bool isExpired = false;

  void handleTimeout() {
    isExpired = true;
  }

  ExternalModulesServices() {
    initialize();
  }

  Future<void> initialize() async {
    _userDataController = Get.find<UserDataController>();
    _auth = Get.find<AuthIduffService>();

    _userData = (await _userDataRepository.getUserData()) ?? UserData();
    _userGoogleModel =
        (await _userDataRepository.getUserGoogleModel()) ??
        UserGoogleModel(email: '');

    // Roda a cada abertura da Home e após um novo login: mantém o usuário
    // (hash) e o perfil atuais nos relatórios do Crashlytics.
    await syncCrashReporterUser();

    // Caixa de notificações da Central de Comunicação: separa por usuário.
    await NotificationInboxService().setUser(_storageSeed());
  }

  /// iduff ou, sem ele, o uid do Google. `null` sem usuário.
  String? _storageSeed() {
    final iduff = _userData.iduff;
    if (iduff != null && iduff.isNotEmpty) return iduff;
    final googleId = _userGoogleModel.id;
    if (googleId != null && googleId.isNotEmpty) return googleId;
    return null;
  }

  /// Chave para separar por usuário o que os módulos guardam no aparelho
  /// (Hive). `null` sem usuário.
  String? getUserStorageKey() {
    final seed = _storageSeed();
    return seed == null ? null : userStorageKey(seed);
  }

  Future<String> getEmail() async {
    final token = await _auth.getAccessToken();
    final userInfo = await _auth.getUserInfo(token);
    return userInfo["email"];
  }

  String? getUserName() {
    return _userData.name;
  }

  String getUserMatricula() {
    return _userData.matricula ?? "";
  }

  String getUserIdUFF() {
    return _userData.iduff ?? "";
  }

  String getUserCourse() {
    return _userData.curso ?? "";
  }

  String? getUserPhotoUrl() {
    return _userData.fotoUrl;
  }

  String getUserValidity() {
    return _userData.dataValidadeMatricula ?? "";
  }

  String getUserBond() {
    return _userData.bond ?? "";
  }

  Future<String> getQrCodeData() async {
    return _userData.textoQrCodeCarteirinha ?? "";
  }

  Future<String> updateQrCodeData() async {
    return await _userDataController.updateQrData();
  }

  Future<String?> getAccessToken() {
    return _auth.getAccessToken();
  }

  /// Token do Firebase (conta Google) para as APIs que pedem `token_google`.
  /// Renova o token na rede; quem chama deve limitar o tempo de espera.
  Future<String?> getFirebaseIdToken() => _authGoogle.getFirebaseIdToken();

  /// Perfil escolhido pelo usuário (graduação, docente...). `null` se ainda
  /// não houver usuário salvo.
  ProfileTypes? getUserProfileType() {
    return _userData.profileType;
  }

  String getUserBondId() {
    return _userData.bondId ?? "";
  }

  List<GdiGroups>? getUserGdiGroups() {
    return _userData.gdiGroups;
  }

  /// Há uma sessão IdUFF ativa (refresh token salvo e não expirado).
  Future<bool> hasActiveIduffBond() => bond_status.hasActiveIduffBond();

  /// Há uma sessão Google ativa (conta salva + sessão Firebase válida).
  Future<bool> hasActiveGoogleBond() => bond_status.hasActiveGoogleBond();

  /// Conecta ou desconecta o IdUFF com as confirmações das Configurações.
  /// Os dois caminhos saem da tela atual (autenticação ou login).
  Future<void> toggleIduffBond({String? loginNote, String? logoutNote}) async {
    if (await hasActiveIduffBond()) {
      await BondActions.confirmIduffLogout(note: logoutNote);
    } else {
      await BondActions.confirmIduffLogin(note: loginNote);
    }
  }

  /// Conecta ou desconecta o Google sem sair da tela atual. Devolve `true`
  /// se a vinculação mudou (e relê o usuário salvo).
  Future<bool> toggleGoogleBond({String? logoutNote}) async {
    final bool changed;
    if (await hasActiveGoogleBond()) {
      changed = await BondActions.confirmGoogleLogout(
        note: logoutNote,
        stayOnScreen: true,
      );
    } else {
      changed = await BondActions.confirmGoogleLogin() != null;
    }
    if (changed) await initialize();
    return changed;
  }

  /// Headers de autorização da conta Google para os [scopes], para os módulos
  /// chamarem APIs do Google em nome do usuário. Com [interactive] = false
  /// não abre tela e devolve `null` sem conta ou sem permissão.
  Future<Map<String, String>?> getGoogleAuthHeaders(
    List<String> scopes, {
    bool interactive = false,
  }) =>
      _authGoogle.authorizationHeaders(scopes, interactive: interactive);

  String? getUserEmailGoogle() {
    return _userGoogleModel.email;
  }

  String? getUserNameGoogle() {
    return _userGoogleModel.name ?? "";
  }

  String? getUserPhotoUrlGoogle() {
    return _userGoogleModel.urlImage ?? "";
  }

  bool isInGroup(GdiGroupsEnum gdiGroup) {
    final groupsList = getUserGdiGroups();
    if (groupsList == null) return false;
    for (var group in groupsList) {
      if (group.gid! == gdiGroup.id) {
        return true;
      }
    }
    return false;
  }

  List<String>? getShortcutRoutes() {
    return _userData.shortcutRoutes;
  }
}
