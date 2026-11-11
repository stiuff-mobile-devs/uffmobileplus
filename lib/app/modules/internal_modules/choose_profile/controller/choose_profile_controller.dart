import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_umm_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_umm_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/gdi_groups.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';

class ChooseProfileController extends GetxController {
  ChooseProfileController();

  final UserUmmRepository userUmmRepository = UserUmmRepository();
  final UserDataRepository _userDataRepository = UserDataRepository();

  late UserDataController _userDataController;

  UserData _user = UserData();
  UserUmmModel userUmm = UserUmmModel();
   late AuthIduffService _auth;

  String matricula = '';
  String? iduff;

  final RxBool _userDataLoaded = false.obs;
  RxBool hasControlPermission = false.obs;

  RxBool isBusy = true.obs;

  bool hasGradButNoGradInfo = false;

  int gradQtd = 0;
  int posQtd = 0;
  int teacherQtd = 0;
  int employeeQtd = 0;
  int outsourcedQtd = 0;
  int postDocResearcherStudentQtd = 0;

  int totalProfileQtd = 0;

  @override
  void onInit() async {
    super.onInit();
    _userDataController = Get.find<UserDataController>();
    iduff = await _userDataRepository.getIduff();
    _auth = Get.find<AuthIduffService>();

    bool askSelection = false;
    if (Get.arguments != null && Get.arguments is Map) {
      askSelection = Get.arguments['ask_selection'] == true;
    }

    final savedData = await _userDataRepository.getUserData();
    final hasMatricula = savedData != null &&
                         savedData.matricula != null &&
                         savedData.matricula!.isNotEmpty;

    if (!askSelection && hasMatricula) {
      Get.offAllNamed(Routes.HOME);
      return;
    }

    await _getUserData();
    await fetchData();
  }

  Future<void> _getUserData() async {
    _user = (await _userDataRepository.getUserData()) ?? UserData();
    _userDataLoaded.value = true;
    _checkControlPermission();
  }

  void _checkControlPermission() {
    try {
      final groups = _user.gdiGroups;
      if (groups == null || groups.isEmpty) {
        hasControlPermission.value = false;
        return;
      }
      hasControlPermission.value = groups.any(
        (group) => group.gid == GdiGroupsEnum.controladoresDeAcesso.id,
      );
    } catch (e) {
      debugPrint("Error checking control permission: $e");
      hasControlPermission.value = false;
    }
  }

  Future<void> fetchData() async {
    isBusy.value = true;

    // Zera os contadores: sem isso, "Atualizar" duplicava as listas
    teacherQtd = 0;
    employeeQtd = 0;
    outsourcedQtd = 0;
    postDocResearcherStudentQtd = 0;
    hasGradButNoGradInfo = false;
    matricula = '';

    try {
      userUmm = await userUmmRepository.getUserData(iduff, await _auth.getAccessToken() ?? "");
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      await _failAndLogout(
        'erro_carregar_dados_usuario'.tr,
        'erro_carregar_dados_usuario_msg'.tr,
      );
      return;
    }

    List<InnerObject> bonds = activeBonds();
    if (bonds.isEmpty) {
      debugPrint("Nenhum vínculo ativo encontrado na UMM");
      await _failAndLogout(
        'nenhum_perfil_encontrado'.tr,
        'nenhum_perfil_encontrado_msg'.tr,
      );
      return;
    }

    //Verifica se o usuario tem algum perfil de graduação
    gradQtd = userUmm.grad?.matriculas?.length ?? 0;

    //Verifica se o usuario tem algum perfil de pós-graduação
    posQtd = userUmm.pos?.alunos?.length ?? 0;

    //Verifica os outros perfis
    for (InnerObject bond in bonds) {
      //Verifica se o perfil é de graduação e se o usuario não tem informações de graduação
      if (bond.vinculacao?.vinculoId == UffBondIds.undergraduate_student) {
        hasGradButNoGradInfo = gradQtd == 0;
        matricula = bond.vinculacao?.matricula?.toString() ?? "";
      }
      //Verifica se o perfil é de docente
      if (bond.vinculacao?.vinculoId == UffBondIds.teacher) {
        teacherQtd++;
      }
      //Verifica se o perfil é de funcionário
      if (bond.vinculacao?.vinculoId == UffBondIds.employee) {
        employeeQtd++;
      }
      //Verifica se o perfil é de terceirizado
      if (bond.vinculacao?.vinculoId == UffBondIds.outsourced) {
        outsourcedQtd++;
      }
      //Verifica se o perfil é de pesquisador de pós-doutorado
      if (bond.vinculacao?.vinculoId == UffBondIds.post_doc_researcher_student) {
        postDocResearcherStudentQtd++;
      }
    }

    debugPrint(
      "gradqtd: $gradQtd / posqtd: $posQtd / teacherQtd: $teacherQtd / employeeQtd: $employeeQtd / outsourcedQtd: $outsourcedQtd / postDocQtd: $postDocResearcherStudentQtd",
    );

    final gradSelectableQtd = gradQtd > 0
        ? gradQtd
        : (hasGradButNoGradInfo ? 1 : 0);
    totalProfileQtd = gradSelectableQtd +
        posQtd +
        teacherQtd +
        employeeQtd +
        outsourcedQtd +
        postDocResearcherStudentQtd;

    if (totalProfileQtd == 1) {
      await _autoSelectSingleProfile();
      isBusy.value = false;
      return;
    }

    isBusy.value = false;
  }

  Future<void> _autoSelectSingleProfile() async {
    if (gradQtd == 1) {
      await saveUserDataBeforeChooseProfile(
        ProfileTypes.grad,
        userUmm.grad?.matriculas?.first.matricula?.toString() ?? "",
      );
      return;
    }

    if (hasGradButNoGradInfo) {
      await saveUserDataBeforeChooseProfile(ProfileTypes.grad, matricula);
      return;
    }

    if (posQtd == 1) {
      await saveUserDataBeforeChooseProfile(
        ProfileTypes.pos,
        userUmm.pos?.alunos?.first.matricula?.toString() ?? "",
      );
      return;
    }

    if (postDocResearcherStudentQtd == 1) {
      await saveUserDataBeforeChooseProfile(
        ProfileTypes.post_doc_researcher_student,
        postDocBonds().first.vinculacao?.matricula ?? "",
      );
      return;
    }

    /*
    if (teacherQtd == 1) {
      InnerObject bond = _bondById(UffBondIds.teacher);
      await saveUserDataBeforeChooseProfile(
        ProfileTypes.teacher,
        bond.vinculacao?.matricula?.toString() ?? "",
      );
      return;
    }

    if (employeeQtd == 1) {
      InnerObject bond = _bondById(UffBondIds.employee);
      await saveUserDataBeforeChooseProfile(
        ProfileTypes.employee,
        bond.vinculacao?.matricula?.toString() ?? "",
      );
      return;
    }

    if (outsourcedQtd == 1) {
      InnerObject bond = _bondById(UffBondIds.outsourced);
      await saveUserDataBeforeChooseProfile(
        ProfileTypes.outsourced,
        bond.vinculacao?.matricula?.toString() ?? "",
      );
    }*/
    return;
  }

  InnerObject _bondById(String bondId) {
    return activeBonds().firstWhere(
      (bond) => bond.vinculacao?.vinculoId == bondId,
    );
  }

  List<InnerObject> activeBonds() {
    final outer = userUmm.activeBond?.objects?.outerObject;
    if (outer == null || outer.length < 2) return [];
    return outer[1].innerObjects ?? [];
  }

  /// Só os vínculos ativos de um tipo (cada seção da tela usa o índice
  /// desta lista, não o de todos os vínculos).
  List<InnerObject> bondsOf(String vinculoId) {
    return activeBonds()
        .where((bond) => bond.vinculacao?.vinculoId == vinculoId)
        .toList();
  }

  /// Só os vínculos de pesquisador de pós-doutorado.
  List<InnerObject> postDocBonds() =>
      bondsOf(UffBondIds.post_doc_researcher_student);

  Future<void> saveUserDataBeforeChooseProfile(
    ProfileTypes profileType,
    String matricula,
  ) async {
    isBusy.value = true;

    try {
      await _userDataController.saveUserData(userUmm, matricula, profileType);
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      debugPrint("Erro ao salvar dados do perfil ($profileType): $e");
      isBusy.value = false;
      await _failAndLogout(
        'erro_salvar_dados_usuario'.tr,
        'erro_salvar_dados_usuario_msg'.tr,
      );
    } finally {
      isBusy.value = false;
    }
  }

  /// Mostra o erro e espera o OK antes de voltar ao login (um snackbar
  /// sumia na troca de tela e o usuário não via o motivo).
  Future<void> _failAndLogout(String title, String message) async {
    isBusy.value = false;
    await AppPopups.alert(
      title: title,
      message: message,
      type: PopupType.error,
      dismissible: false,
    );
    _logoutIduff();
  }

  void goToCarteirinhaPage() {
    Get.toNamed(Routes.CARTEIRINHA_DIGITAL);
  }

  void goToCatracaOnlinePage() {
    Get.toNamed(Routes.CATRACA_ONLINE);
  }

  void _logoutIduff() {
    _userDataRepository.deleteUserIduffModel();
    userUmmRepository.deleteUserUmmModel();
    Get.offAllNamed(Routes.LOGIN);
  }
}
