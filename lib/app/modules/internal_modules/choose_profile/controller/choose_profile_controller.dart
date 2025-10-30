import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/controller/auth_iduff_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_umm_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_umm_model.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/errors_mensages.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';

class ChooseProfileController extends GetxController {

  ChooseProfileController();

  late final UserUmmController _userUmmController;
  late final UserDataController _userDataController;
  late final AuthIduffController _authIduffController;

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
  void onInit() async{
    iduff = Get.arguments;
    _userUmmController = Get.find<UserUmmController>();
    super.onInit();
    fetchData();
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

    debugPrint("gradqtd: $gradQtd / posqtd: $posQtd / teacherQtd: $teacherQtd / employeeQtd: $employeeQtd / outsourcedQtd: $outsourcedQtd");
    totalProfileQtd =
        gradQtd + posQtd + teacherQtd + employeeQtd + outsourcedQtd;
     isBusy.value = false;
    }

    List<InnerObject> activeBonds() {
    return userUmm.activeBond!.objects!.outerObject![1].innerObjects!;
  }

  void saveUserDataBeforeChooseProfile(ProfileTypes profileType, String matricula) async {
    isBusy.value = true;
    

    try {
      await _userDataController.saveUserData(userUmm, matricula, profileType);
    } catch (e) {
      await _authIduffController.loginFailed(ErrorMessage.erro005);
    }
    isBusy.value = false;
    Get.offAllNamed(Routes.HOME);
  }
  
}