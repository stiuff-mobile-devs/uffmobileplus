import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/gdi_groups.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';

class RestaurantModulesController extends GetxController {
  RestaurantModulesController();

  late UserDataController _userDataController;
  late UserData _usermodel;

  @override
  Future<void> onInit() async {
    super.onInit();

    _userDataController = Get.find<UserDataController>();
    _usermodel = (await _userDataController.getUserData()) ?? UserData();

    await filterButtonList(
      _usermodel.profileType ?? ProfileTypes.anonymous,
      _usermodel.gdiGroups ?? <GdiGroups>[],
    );
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
          'Controladores de Acesso',
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
  ) async {
    restaurantModulesList.removeWhere((button) {
      final hasProfile = button.availableFor.contains(currentProfile);
      if (!hasProfile) return true;

      if (button.gdiGroups == null) return false;

      final hasGroupMatch = button.gdiGroups!.any(
        (btnGroup) =>
            currentGdiGroups.any((userGroup) => userGroup.gid == btnGroup.gid),
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
  final List<GdiGroups>? gdiGroups;

  const RestaurantModules({
    required this.availableFor,
    required this.iconSrc,
    required this.subtitle,
    required this.page,
    this.url,
    this.interrogation,
    required this.gdiGroups,
  });
}
