import 'package:get/get.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

// TODO: refletir se as responsabilidades desse controller estão adequadas.
class RestaurantModulesController extends GetxController {
  RestaurantModulesController();

  @override
  void onInit() {
    // TODO: talvez seja melhor refatorar de modo que essa chamada fique fora do controller.
    Get.appendTranslations({
      'pt_BR' : {
        'catraca_online' : 'Catraca Online',
      },
      'en_US' : {
        'catraca_online' : 'Online Turnstile'
      },
      'it_IT' : {
        'catraca_online' : 'Tornello Online'
      }
    });
    super.onInit();
  }

  List<RestaurantModules> restaurantModulesList = [
    RestaurantModules(
      iconSrc: 'assets/icons/validator_qr_code.svg',
      subtitle: 'catraca_online'.tr,
      page: Routes.CATRACA_ONLINE,
      url: '',
      interrogation: false,
      //availableFor: [ProfileTypes.student, ProfileTypes.professor, ProfileTypes.employee],
      //gdiGroups: null
    ),
  ];

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

class RestaurantModules {
  //final List<ProfileTypes> availableFor;
  final String iconSrc;
  final String subtitle;
  final String page;
  final String? url;
  final bool? interrogation;
  //final List<GdiGroups>? gdiGroups;

  const RestaurantModules({
    //required this.availableFor,
    required this.iconSrc,
    required this.subtitle,
    required this.page,
    this.url,
    this.interrogation,
    //this.gdiGroups})
  });
}
