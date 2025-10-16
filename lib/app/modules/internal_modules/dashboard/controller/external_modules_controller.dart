import 'package:get/get.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/base_translation_keys.dart';

class ExternalModulesController extends GetxController {
  ExternalModulesController();

  List<ExternalModules> externalModulesList = [
    ExternalModules(
      iconSrc: 'assets/carteirinha_digital/icons/carteirinha.svg',
      subtitle: 'Carteirinha Digital', // TODO: traduzir
      page: Routes.CARTEIRINHA_DIGITAL,
      url: '',
      interrogation: false,
      //availableFor: [ProfileTypes.student, ProfileTypes.professor, ProfileTypes.employee],
      //gdiGroups: null
    ),

    ExternalModules(
      iconSrc: 'assets/icons/bandejapp.svg',
      subtitle: BaseTranslationKeys.restaurant,
      page: Routes.RESTAURANT_MODULES,
      url: '',
      interrogation: false,
      //availableFor: [ProfileTypes.student, ProfileTypes.professor, ProfileTypes.employee],
      //gdiGroups: null
    ),

    ExternalModules(
      iconSrc: 'assets/icons/plano.svg',
      subtitle: 'Plano de Estudos',
      page: Routes.STUDY_PLAN,
      url: '',
      interrogation: false,
    ),
    ExternalModules(
      iconSrc: 'assets/radio/icons/radio.svg',
      subtitle: 'Radio Pop Goiaba', // TODO: traduzir
      page: Routes.RADIO,
      url: '',
      interrogation: false,
    ),
    ExternalModules(
      iconSrc: 'assets/atividades_proex/icons/atividades-proex.svg', 
      subtitle: 'Atividades PROEX',
      page: Routes.ATIVIDADES_PROEX,
      url: '',
      interrogation: false,
    )
  ];

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
}

class ExternalModules {
  //final List<ProfileTypes> availableFor;
  final String iconSrc;
  final String subtitle;
  final String page;
  final String? url;
  final bool? interrogation;
  //final List<GdiGroups>? gdiGroups;

  const ExternalModules({
    //required this.availableFor,
    required this.iconSrc,
    required this.subtitle,
    required this.page,
    this.url,
    this.interrogation,
    //this.gdiGroups})
  });
}
