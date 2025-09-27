import 'package:get/get.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/base_translation_keys.dart';

class RestaurantModulesController extends GetxController {

  RestaurantModulesController();

  List<RestaurantModules> restaurantModulesList = [
    RestaurantModules(
        iconSrc: 'assets/icons/validator_qr_code.svg',
        subtitle: BaseTranslationKeys.onlineTurnstile,
        page: Routes.ONLINE_TURNSTILE,
        url: '',
        interrogation: false,
        //availableFor: [ProfileTypes.student, ProfileTypes.professor, ProfileTypes.employee],
        //gdiGroups: null
    )
  ];

   void navigateTo(
    String route,
    {
      String webViewUrl = '',
      String appBarTitle = '',
      bool interrogation = false
    }
    ){
    Get.toNamed(route, arguments: {
      'url': webViewUrl,
      'title': appBarTitle,
      'interrogation': interrogation
    });
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

  const RestaurantModules(
      {
        //required this.availableFor,
      required this.iconSrc,
      required this.subtitle,
      required this.page,
      this.url,
      this.interrogation,
      //this.gdiGroups})
      });

      
}