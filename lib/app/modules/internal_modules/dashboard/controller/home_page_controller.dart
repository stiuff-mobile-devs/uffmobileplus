import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:googleapis/driveactivity/v2.dart';
import 'package:uffmobileplus/app/data/services/app_availability_service.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/data/services/deep_link_service.dart';
import 'package:uffmobileplus/app/data/services/responsive_layout_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/controller/restaurant_modules_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/controller/restaurants_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/data/models/campus_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/data/models/meal_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/models/discipline_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/models/weekday_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/repository/study_plan_repository.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/data/models/transcript_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/data/repository/transcript_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/external_modules_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/ui/widgets/app_recommendation_dialog.dart';

class HomePageController extends GetxController {

  RxBool isLoading = false.obs;

  final userName = '-'.obs;
  final userMatricula = '-'.obs;
  final userEmail = '-'.obs;
  final userCourse = '-'.obs;
  final userPhotoUrl = ''.obs;

  final shortcutRoutes = <String>[].obs;
  final isRemovingShortcuts = false.obs;
  final savedShortcuts = <DashboardShortcut>[].obs;
  final availableToAdd = <DashboardShortcut>[].obs;

  final RxBool isLoadingTodayClasses = true.obs;
  final RxList<Discipline> todayClasses = <Discipline>[].obs;

  final RxBool isLoadingTranscript = true.obs;
  final Rx<Transcript?> transcriptStats = Rx<Transcript?>(null);

  final RxBool isLoadingCampusMeals = true.obs;
  final RxList<TodayCampusMeal> campusMeals = <TodayCampusMeal>[].obs;

  late ExternalModulesServices _externalModulesServices;
  late ExternalModulesController _externalModulesController;
  UserDataRepository userDataRepository = UserDataRepository();
  late RestaurantModulesController _restaurantModulesController;
  late RestaurantsController _restaurantsController;
  late ResponsiveLayoutService _layoutService;

  final StudyPlanRepository _studyPlanRepository = StudyPlanRepository();
  final TranscriptRepository _transcriptRepository = TranscriptRepository();

  late Worker _servicesWorker;

  ResponsiveLayoutService get layoutService => _layoutService;

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



  @override
  void onInit() {
    super.onInit();
    _externalModulesController = Get.find<ExternalModulesController>();
    _restaurantModulesController = Get.find<RestaurantModulesController>();
    _restaurantsController = Get.find<RestaurantsController>();
    _layoutService = Get.find<ResponsiveLayoutService>();

    _bindServicesCatalog();
    _loadSavedShortcuts();
    _loadCampusMeals();
    _loadProfileData().then((_) {
      _loadTodayClasses();
      _loadTranscriptStats();
    });
  }

  WeekDay? _weekDayForToday() {
    switch (DateTime.now().weekday) {
      case DateTime.monday:
        return WeekDay.monday;
      case DateTime.tuesday:
        return WeekDay.tuesday;
      case DateTime.wednesday:
        return WeekDay.wednesday;
      case DateTime.thursday:
        return WeekDay.thursday;
      case DateTime.friday:
        return WeekDay.friday;
      case DateTime.saturday:
        return WeekDay.saturday;
      default:
        return null; // Domingo: sem aulas no plano de estudos.
    }
  }

  Future<void> _loadTodayClasses() async {
    try {
      final plan = await _studyPlanRepository.getStudyPlan(false);
      final weekday = _weekDayForToday();
      List<Discipline>? disciplines;
      if (weekday != null) {
        disciplines = plan?.plan?[weekday];
      }
      todayClasses.assignAll(disciplines ?? const <Discipline>[]);
    } catch (_) {
    } finally {
      isLoadingTodayClasses.value = false;
    }
  }

  Future<void> _loadTranscriptStats() async {
    try {
      final transcriptModel = await _transcriptRepository.getTranscript(false);
      transcriptStats.value = transcriptModel?.transcript;
    } catch (_) {
    } finally {
      isLoadingTranscript.value = false;
    }
  }

  Future<void> _loadCampusMeals() async {
    try {
      final results = await Future.wait(
        _restaurantsController.locations.map(_fetchCampusMeal),
      );
      campusMeals.assignAll(results);
    } catch (_) {
    } finally {
      isLoadingCampusMeals.value = false;
    }
  }

  Future<TodayCampusMeal> _fetchCampusMeal(Campus campus) async {
    final sigla = Campus.getSigla(campus.name);
    final isOpenNow = Campus.isActive(sigla);
    final currentShift = Campus.getShift(DateTime.now());

    MealModel? todaysMeal;
    if (isOpenNow && currentShift != 'undefined') {
      try {
        final meals =
            await _restaurantsController.restaurantRepository.getMealsByCampus(sigla);
        final now = DateTime.now();

        if (meals != null) {
          for (final meal in meals) {
            final mealDate = DateTime.tryParse(meal.date.toString());
            if (mealDate == null) continue;

            final isToday = mealDate.year == now.year &&
                mealDate.month == now.month &&
                mealDate.day == now.day;

            if (isToday && Campus.getShift(mealDate) == currentShift) {
              todaysMeal = meal;
              break;
            }
          }
        }
      } catch (_) {}
    }

    return TodayCampusMeal(
      campus: campus,
      shiftLabel: isOpenNow ? currentShift : null,
      meal: todaysMeal,
    );
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
    } else {
      shortcutRoutes.retainWhere(allRoutes.contains);
    }

    _rebuildShortcutCaches();
  }

  Future<void> _loadSavedShortcuts() async {
    try {
      final userData = await userDataRepository.getUserData();
      final saved = userData?.shortcutRoutes ?? <String>[];

      if (saved.isEmpty) {
        _rebuildShortcutCaches();
        await _persistShortcuts();
        return;
      }

      final validRoutes = allShortcutRoutes;
      shortcutRoutes.assignAll(saved.where(validRoutes.contains));
      _rebuildShortcutCaches();
    } catch (_) {}
  }

  Future<void> _persistShortcuts() async {
    try {
      await userDataRepository.updateShortcutRoutes(shortcutRoutes.toList());
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
    _rebuildShortcutCaches();
    _persistShortcuts();
  }

  void removeShortcut(DashboardShortcut service) {
    shortcutRoutes.remove(service.page);
    _rebuildShortcutCaches();
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

    _showAppRecommendationDialog();
  }

  Future<void> _showAppRecommendationDialog() async {
    final result = await AppAvailabilityService.checkBoth();

    try {
      if (!result.allInstalled) {
        await AppRecommendationDialog.show(result);
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    _servicesWorker.dispose();
    super.onClose();
  }

  void _rebuildShortcutCaches() {
    final byRoute = shortcutsByRoute;
    final saved = <DashboardShortcut>[];

    for (final route in shortcutRoutes) {
      final item = byRoute[route];
      if (item != null) {
        saved.add(item);
      }
    }

    savedShortcuts.assignAll(saved);

    final available = allShortcutItems
        .where((service) => !shortcutRoutes.contains(service.page))
        .toList(growable: false);
    availableToAdd.assignAll(available);
  }
}

class TodayCampusMeal {
  final Campus campus;
  final String? shiftLabel;
  final MealModel? meal;

  const TodayCampusMeal({
    required this.campus,
    required this.shiftLabel,
    required this.meal,
  });
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
