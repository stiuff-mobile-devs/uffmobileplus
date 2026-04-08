import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/data/services/deep_link_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/controller/restaurant_modules_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/external_modules_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';

class HomePageController extends GetxController {

  RxBool isLoading = false.obs;

  final userName = '-'.obs;
  final userMatricula = '-'.obs;
  final userEmail = '-'.obs;
  final userCourse = '-'.obs;
  final userPhotoUrl = ''.obs;

  final shortcutRoutes = <String>[].obs;
  final isRemovingShortcuts = false.obs;

  late ExternalModulesServices _externalModulesServices;
  late ExternalModulesController _externalModulesController;
  late UserDataController _userDataController;
  late RestaurantModulesController _restaurantModulesController;

  late Worker _servicesWorker;

  List<DashboardShortcut> get allShortcutItems {
    final byRoute = <String, DashboardShortcut>{};

    for (final service in allServices) {
      byRoute[service.page] = DashboardShortcut(
        iconSrc: service.iconSrc,
        subtitle: service.subtitle,
        page: service.page,
        url: service.url,
        interrogation: service.interrogation,
      );
    }

    for (final module in restaurantModules) {
      byRoute[module.page] = DashboardShortcut(
        iconSrc: module.iconSrc,
        subtitle: module.subtitle,
        page: module.page,
        url: module.url,
        interrogation: module.interrogation,
      );
    }

    return byRoute.values.toList(growable: false);
  }

  Set<String> get allShortcutRoutes => allShortcutItems
      .map((shortcut) => shortcut.page)
      .toSet();

  Map<String, DashboardShortcut> get shortcutsByRoute => {
    for (final item in allShortcutItems) item.page: item,
  };

  List<ExternalModules> get allServices => List<ExternalModules>.from(
    _externalModulesController.externalModulesList,
  );

  List<RestaurantModules> get restaurantModules => List<RestaurantModules>.from(
    _restaurantModulesController.restaurantModulesList,
  );

    List<DashboardShortcut> get savedShortcuts => shortcutRoutes
      .map((route) => shortcutsByRoute[route])
      .whereType<DashboardShortcut>()
      .toList(growable: false);

    List<DashboardShortcut> get availableToAdd => allShortcutItems
      .where((service) => !shortcutRoutes.contains(service.page))
      .toList(growable: false);

  @override
  void onInit() {
    super.onInit();
    _userDataController = Get.find<UserDataController>();
    _externalModulesController = Get.find<ExternalModulesController>();
    _restaurantModulesController = Get.find<RestaurantModulesController>();

    _bindServicesCatalog();
    _loadSavedShortcuts();
    _loadProfileData();
  }

  void _bindServicesCatalog() {
    _syncShortcutsWithServices();
    // O worker é reativo à lista de serviços externos, garantindo que os atalhos sejam atualizados sempre que a lista de serviços mudar
    _servicesWorker = everAll(
      [
        _externalModulesController.externalModulesList,
        _restaurantModulesController.restaurantModulesList,
      ],
      (_) => _syncShortcutsWithServices(),
    );
  }

  // Sincroniza as rotas dos atalhos com os serviços disponíveis
  void _syncShortcutsWithServices() {
    final allRoutes = allShortcutRoutes;

    if (shortcutRoutes.isEmpty) {
      shortcutRoutes.assignAll(allRoutes);
      return;
    }

    shortcutRoutes.retainWhere(allRoutes.contains);
  }

  Future<void> _loadSavedShortcuts() async {
    try {
      final userData = await _userDataController.getUserData();
      final saved = userData?.shortcutRoutes ?? <String>[];

      if (saved.isEmpty) {
        await _persistShortcuts();
        return;
      }

      final validRoutes = allShortcutRoutes;
      shortcutRoutes.assignAll(saved.where(validRoutes.contains));
    } catch (_) {}
  }

  Future<void> _persistShortcuts() async {
    try {
      await _userDataController.updateShortcutRoutes(shortcutRoutes.toList());
    } catch (_) {}
  }

   Future<void> _loadProfileData() async {
    try {
      isLoading.value = true;
      _externalModulesServices = Get.find<ExternalModulesServices>();
      await _externalModulesServices.initialize();

      userName.value = _externalModulesServices.getUserName() ?? '-';
      userMatricula.value = _externalModulesServices.getUserMatricula();
      userCourse.value = _externalModulesServices.getUserCourse();
      userPhotoUrl.value = _externalModulesServices.getUserPhotoUrl();

      final email = await _externalModulesServices.getEmail();
      userEmail.value = email.isNotEmpty ? email : '-';
    } catch (_) {
      userName.value = '-';
      userMatricula.value = '-';
      userEmail.value = '-';
      userCourse.value = '-';
      userPhotoUrl.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  void addShortcut(DashboardShortcut service) {
    if (shortcutRoutes.contains(service.page)) {
      return;
    }
    shortcutRoutes.add(service.page);
    _persistShortcuts();
  }

  void removeShortcut(DashboardShortcut service) {
    shortcutRoutes.remove(service.page);
    _persistShortcuts();

    if (shortcutRoutes.isEmpty) {
      isRemovingShortcuts.value = false;
    }
  }

  void toggleRemoveShortcutMode() {
    isRemovingShortcuts.toggle();
  }

  void openShortcut(DashboardShortcut service) {
    Get.toNamed(
      service.page,
      arguments: {
        'url': service.url ?? '',
        'title': service.subtitle,
        'interrogation': service.interrogation ?? false,
      },
    );
  }

 

  @override
  void onReady() {
    super.onReady();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService().consumePendingNavigation();
    });
  }

  @override
  void onClose() {
    _servicesWorker.dispose();
    super.onClose();
  }
}

class DashboardShortcut {
  final String iconSrc;
  final String subtitle;
  final String page;
  final String? url;
  final bool? interrogation;

  const DashboardShortcut({
    required this.iconSrc,
    required this.subtitle,
    required this.page,
    this.url,
    this.interrogation,
  });
}
