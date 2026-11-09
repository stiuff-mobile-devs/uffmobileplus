import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';
//import 'package:uffmobileplus/app/data/providers/firebase/firebase_analytics_service.dart';
//import 'package:uffmobileplus/app/data/repositories/user_repository.dart';
import 'package:uffmobileplus/app/utils/ui_components/uri_launcher_helper.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPageController extends GetxController {
  //final FirebaseAnalyticsService firebaseAnalyticsService = Get.find();
  //final UserRepository userRepository = Get.find();

  void goDocPage() {
    /* Get.toNamed(Routes.WEB_VIEW, arguments: {
      'url': '',
      'title': 'services'.tr,
    });*/
    AppPopups.info('page_under_development'.tr);
  }

  // final _obj = ''.obs;
  // set obj(value) => _obj.value = value;
  // get obj => _obj.value;
  String url = Get.arguments['url'];
  String title = Get.arguments['title'];
  bool interrogation = Get.arguments['interrogation'] ?? false;
  WebViewController wvc = WebViewController();

  @override
  void onInit() {
   /* firebaseAnalyticsService.logScreen(
        "webview", url, userRepository.getCurrentProfile().name);*/
    wvc
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));
    super.onInit();
  }

  void closeWebView() {
    customCloseWebView();
  }
}
