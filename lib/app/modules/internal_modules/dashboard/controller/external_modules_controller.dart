import 'package:get/get.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

class ExternalModulesController extends GetxController {
  ExternalModulesController();

  @override
  void onInit() {
    // TODO: talvez refatorar.
    Get.appendTranslations({
      'pt_BR' : {
        'carteirinha_digital' : 'Carteirinha Digital',
        'restaurante' : 'Restaurante',
        'plano_estudos' : 'Plano de Estudos',
        'radio_pop_goiaba' : 'Radio Pop Goiaba'
      },
      'en_US' : {
        'carteirinha_digital' : 'Digital ID Card',
        'restaurante' : 'Restaurant',
        'plano_estudos' : 'Study Plan',
        'radio_pop_goiaba' : 'Radio Pop Goiaba'
      },
      'it_IT' : {
        'restaurante' : 'Ristorante'
      }
    });
    super.onInit();
  }

  List<ExternalModules> externalModulesList = [
    ExternalModules(
      iconSrc: 'assets/carteirinha_digital/icons/carteirinha.svg',
      subtitle: 'carteirinha_digital'.tr, 
      page: Routes.CARTEIRINHA_DIGITAL,
      url: '',
      interrogation: false,
      //availableFor: [ProfileTypes.student, ProfileTypes.professor, ProfileTypes.employee],
      //gdiGroups: null
    ),

    ExternalModules(
      iconSrc: 'assets/icons/bandejapp.svg',
      subtitle: 'restaurante'.tr,
      page: Routes.RESTAURANT_MODULES,
      url: '',
      interrogation: false,
      //availableFor: [ProfileTypes.student, ProfileTypes.professor, ProfileTypes.employee],
      //gdiGroups: null
    ),

    ExternalModules(
      iconSrc: 'assets/icons/plano.svg',
      subtitle: 'plano_estudos'.tr,
      page: Routes.STUDY_PLAN,
      url: '',
      interrogation: false,
    ),

    ExternalModules(
      iconSrc: 'assets/radio/icons/radio.svg',
      subtitle: 'radio_pop_goiaba'.tr, 
      page: Routes.RADIO,
      url: '',
      interrogation: false,
    ),

    ExternalModules(
      iconSrc: 'assets/icons/historico.svg',
      subtitle: 'Histórico',
      page: Routes.HISTORICO,
      url: '',
      interrogation: false
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
