import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/deep_link_service.dart';

class HomePageController extends GetxController {
  RxBool isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService().consumePendingNavigation();
    });
  }
}
