import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_umm_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_umm_model.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/gdi_groups.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';

class ChooseProfileController extends GetxController {
  ChooseProfileController();

  late final UserUmmController _userUmmController;
  late final UserDataController _userDataController;
  UserData _user = UserData();
  RxBool _userDataLoaded = false.obs;
  RxBool hasAdminPermission = false.obs;

  RxBool isBusy = false.obs;
  late final String? iduff;
  late UserUmmModel userUmm;

  bool hasGradButNoGradInfo = false;
  late int gradQtd = 0;
  late int posQtd = 0;
  late int teacherQtd = 0;
  late int employeeQtd = 0;
  late int outsourcedQtd = 0;
  int totalProfileQtd = 0;
  String matricula = '';

  @override
  void onInit() async {
    iduff = Get.arguments;
    _userUmmController = Get.find<UserUmmController>();
    _userDataController = Get.find<UserDataController>();
    await getUserData();
    super.onInit();
    fetchData();
  }

  getUserData() async {
    _user = (await _userDataController.getUserData()) ?? UserData();
    _userDataLoaded.value = true;
    _checkAdminPermission();
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

  void fetchData() async {
    isBusy.value = true;
    userUmm = await _userUmmController.getUserData(iduff);

    List<InnerObject> bonds =
        userUmm.activeBond!.objects!.outerObject![1].innerObjects!;

    //Verifica se o usuario tem algum perfil de graduação
    if (userUmm.grad!.matriculas != null) {
      gradQtd = userUmm.grad!.matriculas!.length;
    }

    //Verifica se o usuario tem algum perfil de pós-graduação
    posQtd = userUmm.pos!.alunos!.length;

    //Verifica os outros perfis
    for (InnerObject bond in bonds) {
      //Verifica se o perfil é de graduação e se o usuario não tem informações de graduação
      if (bond.vinculacao!.vinculoId == UffBondIds.undergraduate_student) {
        hasGradButNoGradInfo = gradQtd == 0;
        matricula = bond.vinculacao!.matricula!;
      }
      //Verifica se o perfil é de docente
      if (bond.vinculacao!.vinculoId == UffBondIds.teacher) {
        teacherQtd++;
      }
      //Verifica se o perfil é de funcionário
      if (bond.vinculacao!.vinculoId == UffBondIds.employee) {
        employeeQtd++;
      }
      //Verifica se o perfil é de terceirizado
      if (bond.vinculacao!.vinculoId == UffBondIds.outsourced) {
        outsourcedQtd++;
      }
    }

    /*if (hasGradButNoGradInfo) {
      handleTap(
        Routes.DASHBOARD,
        ProfileTypes.grad,
        reg: matricula,
      );
    }*/

    debugPrint(
      "gradqtd: $gradQtd / posqtd: $posQtd / teacherQtd: $teacherQtd / employeeQtd: $employeeQtd / outsourcedQtd: $outsourcedQtd",
    );

    final gradSelectableQtd = gradQtd > 0 ? gradQtd : (hasGradButNoGradInfo ? 1 : 0);
    totalProfileQtd =
        gradSelectableQtd + posQtd + teacherQtd + employeeQtd + outsourcedQtd;

    if (totalProfileQtd == 1) {
      await _autoSelectSingleProfile();
      return;
    }

    isBusy.value = false;
  }

  Future<void> _autoSelectSingleProfile() async {
    if (gradQtd == 1) {
      await saveUserDataBeforeChooseProfile(
        ProfileTypes.grad,
        userUmm.grad!.matriculas!.first.matricula!,
      );
      return;
    }

    if (hasGradButNoGradInfo) {
      await saveUserDataBeforeChooseProfile(
        ProfileTypes.grad,
        matricula,
      );
      return;
    }

    if (posQtd == 1) {
      await saveUserDataBeforeChooseProfile(
        ProfileTypes.pos,
        userUmm.pos!.alunos!.first.matricula!,
      );
      return;
    }

    if (teacherQtd == 1) {
      final bond = _bondById(UffBondIds.teacher);
      await saveUserDataBeforeChooseProfile(
        ProfileTypes.teacher,
        bond.vinculacao!.matricula!,
      );
      return;
    }

    if (employeeQtd == 1) {
      final bond = _bondById(UffBondIds.employee);
      await saveUserDataBeforeChooseProfile(
        ProfileTypes.employee,
        bond.vinculacao!.matricula!,
      );
      return;
    }

    if (outsourcedQtd == 1) {
      final bond = _bondById(UffBondIds.outsourced);
      await saveUserDataBeforeChooseProfile(
        ProfileTypes.outsourced,
        bond.vinculacao!.matricula!,
      );
    }
  }

  InnerObject _bondById(String bondId) {
    return activeBonds().firstWhere(
          (bond) => bond.vinculacao!.vinculoId == bondId,
        );
  }

  List<InnerObject> activeBonds() {
    return userUmm.activeBond!.objects!.outerObject![1].innerObjects!;
  }

  Future<void> saveUserDataBeforeChooseProfile(
    ProfileTypes profileType,
    String matricula,
  ) async {
    isBusy.value = true;

    try {
      await _userDataController.saveUserData(userUmm, matricula, profileType);
    } catch (e) {}
    isBusy.value = false;
    Get.offAllNamed(Routes.HOME);
  }

  goToCarteirinhaPage() {
    Get.toNamed(Routes.CARTEIRINHA_DIGITAL);
  }

  goToCatracaOnlinePage() {
    Get.toNamed(Routes.CATRACA_ONLINE);
  }
}
