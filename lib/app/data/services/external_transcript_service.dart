import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';

/* TODO: Classe idêntica à ExternalStudyPlanService senão pelo Nome.
Criar uma genérica */
class ExternalTranscriptService extends GetxService {
  late UserDataController _userDataController;
  late AuthIduffService _authIduffService;
  late UserData? _userData;
  
  ExternalTranscriptService() {
    _initialize();
  }

  Future<void> _initialize() async {
    _userDataController = Get.find<UserDataController>();
    _authIduffService = Get.find<AuthIduffService>();
    _userData = await _userDataController.getUserData();
  }

  String getUserMatricula() {
    return _userData!.matricula ?? "-";
  }

  String getUserBondId() {
    return _userData!.bondId ?? "";
  }

  Future<String?> getAccessToken() async {
    return await _authIduffService.getAccessToken();
  }
}
