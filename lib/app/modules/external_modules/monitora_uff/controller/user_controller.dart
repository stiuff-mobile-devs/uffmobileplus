import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/data/provider/firebase_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_model.dart';

class UserController extends GetxController {
  final _user = Rxn<UserModel>();
  UserModel? get user => _user.value;

  final allFirebaseUsers = <UserModel>[].obs;

  final isLoading = true.obs;

  late final ExternalModulesServices _externalModulesServices;

  @override
  Future<void> onInit() async {
    super.onInit();
    _loadInitialData();
    allFirebaseUsers.bindStream(FirebaseProvider().streamAllUsers());
  }

  Future<void> _loadInitialData() async {
    try {
      _externalModulesServices = Get.find<ExternalModulesServices>();
      await _externalModulesServices.initialize();

      _user.value = await _initializeUser();
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserModel?> _initializeUser() async {
    final email = await _externalModulesServices.getEmail();
    return await FirebaseProvider().getUserByEmail(email);
  }

  bool isAdmin() => _user.value?.funcao == 'administrador';

  bool isMonitor() => _user.value?.funcao == 'monitor';

  void deleteUser(String email) => FirebaseProvider().deleteUserByEmail(email);
}
