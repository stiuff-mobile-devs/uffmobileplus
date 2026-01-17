import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';

class ExternalModulesController extends GetxController {
  ExternalModulesController();

  late UserDataController _userDataController;
  late UserData _usermodel;

  final RxList<ExternalModules> externalModulesList = RxList([
    ExternalModules(
      iconSrc: 'assets/carteirinha_digital/icons/carteirinha.svg',
      subtitle: 'carteirinha_digital'.tr,
      page: Routes.CARTEIRINHA_DIGITAL,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/icons/bandejapp.svg',
      subtitle: 'restaurante'.tr,
      page: Routes.RESTAURANT_MODULES,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/icons/plano.svg',
      subtitle: 'plano_estudos'.tr,
      page: Routes.STUDY_PLAN,
      url: '',
      interrogation: false,
      availableFor: [ProfileTypes.grad, ProfileTypes.pos],
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/radio/icons/radio.svg',
      subtitle: 'radio_pop_goiaba'.tr,
      page: Routes.RADIO,
      url: '',
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/icons/historico.svg',
      subtitle: 'Histórico', // TODO: traduzir // TODO: traduzir
      page: Routes.HISTORICO,
      url: '',
      interrogation: false,
      availableFor: [ProfileTypes.grad, ProfileTypes.pos],
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/papers/icons/pesquisas.svg',
      subtitle: 'periodicos'.tr,
      page: Routes.PAPERS,
      url: '',
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/icons/uniteve.svg',
      subtitle: 'Unitevê', // TODO: traduzir
      page: Routes.UNITEVE,
      url: '',
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/icons/monitora_uff.png',
      subtitle: 'monitora_uff'.tr,
      page: Routes.MONITORA_UFF,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/icons/atendimento.svg',
      subtitle: 'central_de_atendimento'.tr,
      page: Routes.CENTRAL_DE_ATENDIMENTO,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: null,
    ),
  ]);

  @override
  Future<void> onInit() async {
    super.onInit();

    _userDataController = Get.find<UserDataController>();
    _usermodel = (await _userDataController.getUserData())!;

    await filterButtonList(
      _usermodel.profileType!,
      _usermodel.gdiGroups ?? <GdiGroups>[],
    );

    // TODO: talvez refatorar.
    Get.appendTranslations({
      'pt_BR': {
        'carteirinha_digital': 'Carteirinha Digital',
        'restaurante': 'Restaurante',
        'plano_estudos': 'Plano de Estudos',
        'radio_pop_goiaba': 'Radio Pop Goiaba',
        'periodicos': 'Periódicos',
      },
      'en_US': {
        'carteirinha_digital': 'Digital ID Card',
        'restaurante': 'Restaurant',
        'plano_estudos': 'Study Plan',
        'radio_pop_goiaba': 'Radio Pop Goiaba',
        'periodicos': 'Papers',
      },
      'it_IT': {'restaurante': 'Ristorante'},
      'pt_BR': {'monitora_uff': 'Monitora UFF'},
      'en_US': {'monitora_uff': 'Monitora UFF'},
    });
  }

  // TODO: parece redundante; melhor usar Get.toNamed direto?
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
    externalModulesList.removeWhere((button) {
      final hasProfile = button.availableFor.contains(currentProfile);
      if (!hasProfile) return true;

      if (button.gdiGroups == null) return false;

      final hasGroupMatch = button.gdiGroups!.any(
        (btnGroup) =>
            currentGdiGroups.any((userGroup) => userGroup.gid == btnGroup.gid),
      );

      return !hasGroupMatch;
    });
    externalModulesList.refresh();
  }
}

class ExternalModules {
  final List<ProfileTypes> availableFor;
  final String iconSrc;
  final String subtitle;
  final String page;
  final String? url;
  final bool? interrogation;
  final List<GdiGroups>? gdiGroups;

  const ExternalModules({
    required this.availableFor,
    required this.iconSrc,
    required this.subtitle,
    required this.page,
    this.url,
    this.interrogation,
    required this.gdiGroups,
  });
}
