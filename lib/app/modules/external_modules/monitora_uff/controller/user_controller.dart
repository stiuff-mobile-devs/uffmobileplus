import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/data/provider/firebase_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_google_repository.dart';

class UserController extends GetxController {
  final _user = Rxn<UserModel>();
  UserModel? get user => _user.value;
  String? _googleName;

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

      try {
        final googleUser = await UserGoogleRepository().getUserGoogleModel();
        _googleName = googleUser?.name;
      } catch (e) {
        // Ignora caso não tenha usuário google
      }

      _user.value = await _initializeUser();
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserModel?> _initializeUser() async {
    // final email = await _externalModulesServices.getEmail();
    final googleUser = await UserGoogleRepository().getUserGoogleModel();
    final email = googleUser?.email ?? "";
    if (email.isEmpty) return null;

    return await FirebaseProvider().getUserByEmail(email);
  }

  bool isAdmin() => _user.value?.funcao == 'administrador';

  bool isMonitor() => _user.value?.funcao == 'monitor';

  void deleteUser(String email) => FirebaseProvider().deleteUserByEmail(email);

  String getUserName() {
    return user!.nome ??
        //_externalModulesServices.getUserName() ??
        _googleName ??
        "Nome não informado";
  }
}
