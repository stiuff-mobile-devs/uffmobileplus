import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/data/services/deep_link_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/external_modules_controller.dart';

class HomePageController extends GetxController {
  RxBool isLoading = false.obs;
  final userName = '-'.obs;
  final userMatricula = '-'.obs;
  final userEmail = '-'.obs;
  final userCourse = '-'.obs;
  final userPhotoUrl = ''.obs;
  final shortcutRoutes = <String>[].obs;

  late ExternalModulesServices _externalModulesServices;
  late ExternalModulesController _externalModulesController;
  late Worker _servicesWorker;

  @override
  void onInit() {
    super.onInit();
    _bindServicesCatalog();
    _loadProfileData();
  }

  void _bindServicesCatalog() {
    _externalModulesController = Get.find<ExternalModulesController>();

    _syncShortcutsWithServices();
    _servicesWorker = ever<List<ExternalModules>>(
      _externalModulesController.externalModulesList,
      (_) => _syncShortcutsWithServices(),
    );
  }

  void _syncShortcutsWithServices() {
    final allRoutes = allServices.map((service) => service.page).toSet();

    if (shortcutRoutes.isEmpty) {
      shortcutRoutes.assignAll(allRoutes);
      return;
    }

    shortcutRoutes.retainWhere(allRoutes.contains);
  }

  List<ExternalModules> get allServices => List<ExternalModules>.from(
    _externalModulesController.externalModulesList,
  );

  List<ExternalModules> get savedShortcuts => allServices
      .where((service) => shortcutRoutes.contains(service.page))
      .toList(growable: false);

  List<ExternalModules> get availableToAdd => allServices
      .where((service) => !shortcutRoutes.contains(service.page))
      .toList(growable: false);

  void addShortcut(ExternalModules service) {
    if (shortcutRoutes.contains(service.page)) {
      return;
    }
    shortcutRoutes.add(service.page);
  }

  void removeShortcut(ExternalModules service) {
    shortcutRoutes.remove(service.page);
  }

  void openService(ExternalModules service) {
    Get.toNamed(
      service.page,
      arguments: {
        'url': service.url ?? '',
        'title': service.subtitle,
        'interrogation': service.interrogation ?? false,
      },
    );
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
