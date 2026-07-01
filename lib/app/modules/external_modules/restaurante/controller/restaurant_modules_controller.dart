import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/services/firebase_users_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_google_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_google_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/gdi_groups.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';

class RestaurantModulesController extends GetxController {
  RestaurantModulesController();

  bool isOperator = false;
  late UserData _usermodel;
  late UserGoogleModel _userGoogleModel;
  UserDataRepository userDataRepository = UserDataRepository();
  UserGoogleRepository userGoogleRepository = UserGoogleRepository();
  FirebaseUsersService firebaseUsersService = FirebaseUsersService();

  @override
  Future<void> onInit() async {
    super.onInit();

    _usermodel = (await userDataRepository.getUserData()) ?? UserData();
    _userGoogleModel = (await userGoogleRepository.getUserGoogleModel()) ?? UserGoogleModel(email: '');

    await _isOperator();

    await filterButtonList(
      _usermodel.profileType ?? ProfileTypes.anonymous,
      _usermodel.gdiGroups ?? <GdiGroups>[],
      _usermodel.gdiGroupsGoogle?.gdiGroups ?? <GdiGroups>[],
    );
  }
  Future<void> _isOperator() async {
    final operatorsEmails = await firebaseUsersService.getOperators();
    isOperator = operatorsEmails.contains(_userGoogleModel.email);
  }

  final RxList<RestaurantModules> restaurantModulesList = RxList([
    RestaurantModules(
      iconSrc: 'assets/icons/cardapio.svg',
      subtitle: 'menu'.tr,
      page: Routes.BANDEJAPP,
      url: '',
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),

    RestaurantModules(
      iconSrc: 'assets/restaurant/icons/qr-code.svg',
      subtitle: 'Pagar Restaurante'.tr,
      page: Routes.PAY_RESTAURANT,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: null,
    ),

    RestaurantModules(
      iconSrc: 'assets/restaurant/icons/recarga.svg',
      subtitle: 'Recarregar Cartão'.tr,
      page: Routes.RECHARGE_CARD,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: null,
    ),
    RestaurantModules(
      iconSrc: 'assets/restaurant/icons/saldo-extrato.svg',
      subtitle: 'Saldo e Extrato'.tr,
      page: Routes.BALANCE_STATEMENT,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: null,
    ),

    RestaurantModules(
      iconSrc: 'assets/icons/validator_qr_code.svg',
      subtitle: 'Catraca'.tr,
      page: Routes.CATRACA_ONLINE,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: [
        GdiGroups(
          GdiGroupsEnum.controladoresDeAcesso.id,
          'Controladores de Acesso', null, null, null
        ),
      ],
    ),
  ]);

  void navigateTo(
    String route, {
    String webViewUrl = '',
    String appBarTitle = '',
    bool interrogation = false,
  }) {
    Get.toNamed(
      route,
      arguments: {
        'url': webViewUrl,
        'title': appBarTitle,
        'interrogation': interrogation,
      },
    );
  }

  Future<void> filterButtonList(
    ProfileTypes currentProfile,
    List<GdiGroups> currentGdiGroups,
    List<GdiGroups> currentGdiGroupsGoogle,
  ) async {
    restaurantModulesList.removeWhere((button) {
      if (button.isOperator == true && isOperator) return false;

      final hasProfile = button.availableFor.contains(currentProfile);
      if (!hasProfile) return true;

      if (button.gdiGroups == null) return false;

      final hasGroupMatch = button.gdiGroups!.any(
        (btnGroup) =>
            currentGdiGroups.any((userGroup) => userGroup.gid == btnGroup.gid) ||
            currentGdiGroupsGoogle.any((userGroup) => userGroup.gid == btnGroup.gid),
      );

      return !hasGroupMatch;
    });
    restaurantModulesList.refresh();
  }
}

class RestaurantModules {
  final List<ProfileTypes> availableFor;
  final String iconSrc;
  final String subtitle;
  final String page;
  final String? url;
  final bool? interrogation;
  final bool? isOperator;
  final List<GdiGroups>? gdiGroups;

  const RestaurantModules({
    required this.availableFor,
    required this.iconSrc,
    required this.subtitle,
    required this.page,
    this.url,
    this.interrogation,
    this.isOperator,
    required this.gdiGroups,
  });
}
