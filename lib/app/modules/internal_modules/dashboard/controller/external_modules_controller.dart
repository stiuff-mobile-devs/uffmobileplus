import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/gdi_groups.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';

class ExternalModulesController extends GetxController {
  ExternalModulesController();

  
  UserDataRepository userDataRepository = UserDataRepository();
  UserData _usermodel = UserData();
  
   @override
  Future<void> onInit() async {
    super.onInit();
    _usermodel = (await userDataRepository.getUserData()) ?? UserData();

    await filterButtonList(
      _usermodel.profileType ?? ProfileTypes.anonymous,
      _usermodel.gdiGroups ?? <GdiGroups>[],
      _usermodel.gdiGroupsGoogle?.gdiGroups ?? <GdiGroups>[],
    );
  }

  final RxList<ExternalModules> externalModulesList = RxList([
    ExternalModules(
      iconSrc: 'assets/carteirinha_digital/icons/carteirinha.svg',
      subtitle: 'carteirinha_digital',
      page: Routes.CARTEIRINHA_DIGITAL,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/icons/bandejapp.svg',
      subtitle: 'restaurante',
      page: Routes.RESTAURANT_MODULES,
      url: '',
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),
    // Bibliotecas
    ExternalModules(
      iconSrc: 'assets/icons/biblioteca.svg',
      subtitle: 'bibliotecas',
      page: Routes.BIBLIOTECAS,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/icons/plano.svg',
      subtitle: 'plano_estudos',
      page: Routes.STUDY_PLAN,
      url: '',
      interrogation: false,
      availableFor: [ProfileTypes.grad, ProfileTypes.pos],
      gdiGroups: null,
    ),

     ExternalModules(
      iconSrc: 'assets/icons/historico.svg',
      subtitle: 'historico',
      page: Routes.HISTORICO,
      url: '',
      interrogation: false,
      availableFor: [ProfileTypes.grad, ProfileTypes.pos],
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/busuff/icons/onibus.svg',
      subtitle: 'BusUFF',
      page: Routes.BUSUFF,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: null,
    ),
    
    ExternalModules(
      iconSrc: 'assets/cdc/icons/cdc.svg',
      subtitle: 'central_de_comunicacao',
      page: Routes.CDC,
      url: '',
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/icons/banco_de_ideias.svg',
      subtitle: 'banco_de_ideias',
      page: Routes.BANCO_DE_IDEIAS,
      url: '',
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/radio/icons/radio.svg',
      subtitle: 'radio_pop_goiaba',
      page: Routes.RADIO,
      url: '',
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/papers/icons/pesquisas.svg',
      subtitle: 'periodicos',
      page: Routes.PAPERS,
      url: '',
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/icons/uniteve.svg',
      subtitle: 'uniteve',
      page: Routes.UNITEVE,
      url: '',
      interrogation: false,
      availableFor: everyone,
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/icons/monitora_uff.png',
      subtitle: 'monitora_uff',
      page: Routes.MONITORA_UFF,
      url: '',
      interrogation: false,
      availableFor: everyone,
      gdiGroups:  [
        GdiGroups(
          null,
          null,
          null,
          null,
          null,
        ),
      ],
    ),

    ExternalModules(
      iconSrc: 'assets/icons/ead.svg',
      subtitle: 'ead',
      page: Routes.EAD,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/icons/repositorio_uff.svg',
      subtitle: 'repositorio_institucional',
      page: Routes.REPOSITORIO_INSTITUCIONAL,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/icons/internacional.svg',
      subtitle: 'internacional',
      page: Routes.INTERNACIONAL,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: null,
    ),
    
    ExternalModules(
      iconSrc: 'assets/icons/sos.svg',
      subtitle: 'sos',
      page: Routes.SOS,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: null,
    ),
    
    ExternalModules(
      iconSrc: 'assets/icons/atendimento.svg',
      subtitle: 'central_de_atendimento',
      page: Routes.CENTRAL_DE_ATENDIMENTO,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: null,
    ),

    ExternalModules(
      iconSrc: 'assets/carteirinha_digital/icons/validador_carteirinha.svg',
      subtitle: 'validador_carteirinha',
      page: Routes.CARTEIRINHA_VALIDADOR,
      url: '',
      interrogation: false,
      availableFor: everyoneLogged,
      gdiGroups: null,
    ),
  ]);

 

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
    List<GdiGroups> currentGdiGroupsGoogle
  ) async {
    externalModulesList.removeWhere((button) {
      final hasProfile = button.availableFor.contains(currentProfile);
      if (!hasProfile) return true;

      if (button.gdiGroups == null) return false;

       if (currentGdiGroupsGoogle.any(
          (userGroup) =>
              userGroup.email == 'grupos.harpia@id.uff.br' || userGroup.email == 'bombeiros.harpia@id.uff.br' || userGroup.email == 'campo-monitorauff.harpia@id.uff.br'
        )) {
          return false;
        }
        
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
  /// Translation KEY, not display text.
  ///
  /// These lists are field initialisers, evaluated once when the controller is
  /// constructed, so resolving `.tr` here would freeze the label in whatever
  /// language was active at startup. Call `.tr` at the render site instead, so
  /// the label follows `Get.updateLocale`.
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
