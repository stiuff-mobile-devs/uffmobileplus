import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';

class BibliotecasController extends GetxController {
  BibliotecasController();

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

  final RxList<BibliotecasModules> bibliotecasModulesList = RxList([
    BibliotecasModules(
      iconSrc: 'assets/logos/logo_pergamum_mobile.svg',
      subtitle: 'pergamum'.tr,
      page: Routes.BIBLIOTECAS_WEB_VIEW,
      url: 'https://catalogobibliotecas.uff.br/login?redirect=/meupergamum',
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),
    BibliotecasModules(
      iconSrc: 'assets/logos/pre-cadastro.svg',
      subtitle: 'cadastro'.tr,
      page: Routes.BIBLIOTECAS_WEB_VIEW,
      url: "https://bibliotecas.uff.br/cadastro/",
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),
    BibliotecasModules(
      iconSrc: 'assets/logos/catalogo.svg',
      subtitle: 'catalogo'.tr,
      page: Routes.BIBLIOTECAS_WEB_VIEW,
      url: "https://catalogobibliotecas.uff.br/",
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),
    BibliotecasModules(
      iconSrc: 'assets/logos/ebooks.svg',
      subtitle: 'ebooks'.tr,
      page: Routes.BIBLIOTECAS_WEB_VIEW,
      url: "https://bibliotecas.uff.br/ebooks",
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),
    BibliotecasModules(
      iconSrc: 'assets/logos/fale_com_bibliotecario_so_logo.svg',
      subtitle: 'ask'.tr,
      page: Routes.BIBLIOTECAS_WEB_VIEW,
      url: "http://bibliotecas.uff.br/contato/",
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),
    BibliotecasModules(
      iconSrc: 'assets/logos/ferramentas.svg',
      subtitle: 'ferramentas'.tr,
      page: Routes.BIBLIOTECAS_WEB_VIEW,
      url: "https://bibliotecas.uff.br/pesquisa/",
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),
    BibliotecasModules(
      iconSrc: 'assets/logos/saber_uff.svg',
      subtitle: 'saber'.tr,
      page: Routes.BIBLIOTECAS_WEB_VIEW,
      url: "https://proxy.uff.br/login/index.html",
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),
    BibliotecasModules(
      iconSrc: 'assets/logos/logo_target_blue.svg',
      subtitle: 'target'.tr,
      page: Routes.BIBLIOTECAS_WEB_VIEW,
      url: "https://www.gedweb.com.br/uff/",
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
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
    bibliotecasModulesList.removeWhere((button) {
      final hasProfile = button.availableFor.contains(currentProfile);
      if (!hasProfile) return true;

      if (button.gdiGroups == null) return false;

      final hasGroupMatch = button.gdiGroups!.any(
        (btnGroup) =>
            currentGdiGroups.any((userGroup) => userGroup.gid == btnGroup.gid),
      );

      return !hasGroupMatch;
    });
    bibliotecasModulesList.refresh();
  }
}

class BibliotecasModules {
  final List<ProfileTypes> availableFor;
  final String iconSrc;
  final String subtitle;
  final String page;
  final String? url;
  final bool? interrogation;
  final List<GdiGroups>? gdiGroups;

  const BibliotecasModules({
    required this.availableFor,
    required this.iconSrc,
    required this.subtitle,
    required this.page,
    required this.url,
    this.interrogation,
    required this.gdiGroups,
  });
}