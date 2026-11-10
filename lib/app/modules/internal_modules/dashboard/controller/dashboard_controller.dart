import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  static const int homeTab = 0;
  static const int servicesTab = 1;

  final RxInt currentIndex = homeTab.obs;
  late final PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: homeTab);
  }

  /// Troca de aba pela barra inferior ou pelo menu lateral.
  void goToTab(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
    if (pageController.hasClients) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Chamado pelo PageView, inclusive quando o usuário desliza entre as abas.
  void onPageChanged(int index) => currentIndex.value = index;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
