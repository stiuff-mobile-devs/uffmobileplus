import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
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
  final UserDataRepository userDataRepository = UserDataRepository();
  late UserDataController _userDataController;

  UserData _user = UserData();

  late UserUmmModel userUmm;
  String matricula = '';
  String? iduff;

  final RxBool _userDataLoaded = false.obs;
  RxBool hasControlPermission = false.obs;

  RxBool isBusy = false.obs;

  bool hasGradButNoGradInfo = false;

  int gradQtd = 0;
  int posQtd = 0;
  int teacherQtd = 0;
  int employeeQtd = 0;
  int outsourcedQtd = 0;

  int totalProfileQtd = 0;

  @override
  void onInit() async {

    super.onInit();
    _userDataController = Get.find<UserDataController>();
    iduff = Get.arguments;
    await getUserData();
    await fetchData();
  }

  Future<void> getUserData() async {
    _user = (await userDataRepository.getUserData()) ?? UserData();
    _userDataLoaded.value = true;
    _checkControlPermission();
  }

  void _checkControlPermission() {
    final groups = _user.gdiGroups;
    if (groups == null || groups.isEmpty) {
      hasControlPermission.value = false;
      return;
    }
    hasControlPermission.value = groups.any(
      (group) => group.gid == GdiGroupsEnum.controladoresDeAcesso.id,
    );
  }

  Future<void> fetchData() async {
    isBusy.value = true;

    try {
      userUmm = await userUmmRepository.getUserData(iduff);
    } catch (e) {
      isBusy.value = false;
      throw Exception("Erro ao obter dados do usuário: $e");
           
    }

    List<InnerObject> bonds =
        userUmm.activeBond?.objects?.outerObject?[1].innerObjects ?? [];

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
    }

    debugPrint(
      "gradqtd: $gradQtd / posqtd: $posQtd / teacherQtd: $teacherQtd / employeeQtd: $employeeQtd / outsourcedQtd: $outsourcedQtd",
    );

    final gradSelectableQtd = gradQtd > 0
        ? gradQtd
        : (hasGradButNoGradInfo ? 1 : 0);
    totalProfileQtd =
        gradSelectableQtd + posQtd + teacherQtd + employeeQtd + outsourcedQtd;

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
    return userUmm.activeBond?.objects?.outerObject?[1].innerObjects ?? [];
  }

  Future<void> saveUserDataBeforeChooseProfile(
    ProfileTypes profileType,
    String matricula,
  ) async {
    isBusy.value = true;

    try {
      await _userDataController.saveUserData(userUmm, matricula, profileType);
    } catch (e) {
      throw Exception("Erro ao salvar dados do usuário: $e");
    }
    isBusy.value = false;
    Get.offAllNamed(Routes.HOME);
  }

  void goToCarteirinhaPage() {
    Get.toNamed(Routes.CARTEIRINHA_DIGITAL);
  }

  void goToCatracaOnlinePage() {
    Get.toNamed(Routes.CATRACA_ONLINE);
  }
}
