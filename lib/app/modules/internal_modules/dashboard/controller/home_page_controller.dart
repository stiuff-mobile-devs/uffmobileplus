import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uffmobileplus/app/data/services/app_availability_service.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/data/services/deep_link_service.dart';
import 'package:uffmobileplus/app/data/services/responsive_layout_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/controller/restaurant_modules_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/cardapio/controller/restaurants_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/cardapio/data/models/campus_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/cardapio/data/models/meal_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/models/discipline_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/models/weekday_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/repository/study_plan_repository.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/data/models/transcript_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/data/repository/transcript_repository.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/external_modules_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/repository/user_data_repository.dart';
import 'package:uffmobileplus/app/ui/widgets/app_recommendation_dialog.dart';

class HomePageController extends GetxController {
  final UserDataRepository _userDataRepository = UserDataRepository();
  final StudyPlanRepository _studyPlanRepository = StudyPlanRepository();
  final TranscriptRepository _transcriptRepository = TranscriptRepository();

  late ExternalModulesServices _externalModulesServices;
  late ResponsiveLayoutService _layoutService;

  late ExternalModulesController _externalModulesController;
  late RestaurantModulesController _restaurantModulesController;
  late RestaurantsController _restaurantsController;

  RxBool isLoading = false.obs;

  final userName = '--'.obs;
  final userMatricula = ''.obs;
  final userEmail = ''.obs;
  final userCourse = ''.obs;
  final userPhotoUrl = ''.obs;

  final shortcutRoutes = <String>[].obs;
  final savedShortcuts = <DashboardShortcut>[].obs;
  final availableToAdd = <DashboardShortcut>[].obs;

  final isRemovingShortcuts = false.obs;

  final RxBool isLoadingTodayClasses = true.obs;
  final RxList<Discipline> todayClasses = <Discipline>[].obs;

  final RxBool isLoadingTranscript = true.obs;
  final Rx<Transcript?> transcriptStats = Rx<Transcript?>(null);

  final RxBool isLoadingCampusMeals = true.obs;
  final RxList<TodayCampusMeal> campusMeals = <TodayCampusMeal>[].obs;

  late Worker _servicesWorker;

  ResponsiveLayoutService get layoutService => _layoutService;

  @override
  Future<void> onInit() async {
    super.onInit();
    isLoading.value = true;

    _externalModulesController = Get.find<ExternalModulesController>();
    _restaurantModulesController = Get.find<RestaurantModulesController>();
    _restaurantsController = Get.find<RestaurantsController>();
    _layoutService = Get.find<ResponsiveLayoutService>();
    _externalModulesServices = Get.find<ExternalModulesServices>();
    await _externalModulesServices.initialize();

    await _loadProfileData().then((_) async {
      await _loadTodayClasses();
      await _loadTranscriptStats();
    });
    await _bindServicesCatalog();
    await _loadSavedShortcuts();
    await _loadCampusMeals();
    isLoading.value = false;
  }

  @override
  void onReady() {
    super.onReady();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService().consumePendingNavigation();
    });

    _showAppRecommendationDialog();
  }

  Future<void> _loadProfileData() async {
    try {
      String email = '';

      userName.value =
          _externalModulesServices.getUserName() ??
          _externalModulesServices.getUserNameGoogle() ??
          "";
      userMatricula.value = _externalModulesServices.getUserMatricula();
      userCourse.value = _externalModulesServices.getUserCourse();
      userPhotoUrl.value =
          _externalModulesServices.getUserPhotoUrl() ??
          _externalModulesServices.getUserPhotoUrlGoogle() ??
          "";
      try {
        email = await _externalModulesServices.getEmail();
      } catch (e) {}
      userEmail.value = email.isNotEmpty
          ? email
          : _externalModulesServices.getUserEmailGoogle() ?? "";

      debugPrint('''
        👤 --- DADOS DO PERFIL ---
        📛 Nome:      ${userName.value}
        🎓 Matrícula: ${userMatricula.value}
        📚 Curso:     ${userCourse.value}
        ✉️ Email:     ${userEmail.value}
        🖼️ Foto URL:  ${userPhotoUrl.value}
        ---------------------------
        ''');
    } catch (_) {
      userName.value = '-';
      userMatricula.value = '-';
      userEmail.value = '-';
      userCourse.value = '-';
      userPhotoUrl.value = '';
    }
  }

  Future<void> _loadTodayClasses() async {
    try {
      final plan = await _studyPlanRepository.getStudyPlan(false);
      final weekday = _weekDayForToday();
      List<Discipline>? disciplines;
      if (weekday != null) {
        disciplines = plan?.plan?[weekday];
        disciplines?.sort((a, b) {
          if (a.startTime == null && b.startTime == null) return 0;
          if (a.startTime == null) return 1;
          if (b.startTime == null) return -1;
          return a.startTime!.compareTo(b.startTime!);
        });
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

  final RxBool hasDefaultRestaurant = false.obs;

  Future<void> reloadCampusMeals() async {
    isLoadingCampusMeals.value = true;
    await _loadCampusMeals();
  }

  Future<void> _loadCampusMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final defaultRes = prefs.getString('default_restaurant');

      if (defaultRes != null && defaultRes.isNotEmpty) {
        hasDefaultRestaurant.value = true;
        
        final campus = _restaurantsController.locations.firstWhere(
            (c) => c.name == defaultRes, 
            orElse: () => _restaurantsController.locations.first);
            
        final result = await _fetchCampusMeal(campus);
        campusMeals.assignAll([result]);
      } else {
        hasDefaultRestaurant.value = false;
        campusMeals.clear();
      }
    } catch (_) {
    } finally {
      isLoadingCampusMeals.value = false;
    }
  }

  Future<TodayCampusMeal> _fetchCampusMeal(Campus campus) async {
    final sigla = Campus.getSigla(campus.name);
    final now = DateTime.now();

    bool isOpenOrSoon = false;
    if (now.weekday != 6 && now.weekday != 7) {
      final schedule = Campus.getSchedule(sigla);
      for (int i = 0; i < schedule.length; i += 2) {
        if (schedule[i] == 'null') continue;
        final openTime = DateTime.parse(schedule[i]);
        final closeTime = DateTime.parse(schedule[i + 1]);
        final oneHourBefore = openTime.subtract(const Duration(hours: 1));
        if (now.isAfter(oneHourBefore) && now.isBefore(closeTime)) {
          isOpenOrSoon = true;
          break;
        }
      }
    }

    if (!isOpenOrSoon) {
      return TodayCampusMeal(
        campus: campus,
        shiftLabel: null,
        meal: null,
      );
    }

    MealModel? todaysMeal;
    String? mealShift;

    try {
      final meals = await _restaurantsController.restaurantRepository
          .getMealsByCampus(sigla)
          .timeout(const Duration(seconds: 8), onTimeout: () => <MealModel>[]);

      if (meals != null && meals.isNotEmpty) {
        final todayMeals = meals.where((meal) {
          final mealDate = DateTime.tryParse(meal.date.toString());
          if (mealDate == null) return false;
          return mealDate.year == now.year &&
              mealDate.month == now.month &&
              mealDate.day == now.day;
        }).toList();

        if (todayMeals.isNotEmpty) {
          todayMeals.sort((a, b) => DateTime.parse(a.date.toString()).compareTo(DateTime.parse(b.date.toString())));
          todaysMeal = todayMeals.firstWhere(
            (m) {
              final d = DateTime.parse(m.date.toString());
              return d.hour >= now.hour;
            },
            orElse: () => todayMeals.last,
          );
          
          final d = DateTime.parse(todaysMeal!.date.toString());
          mealShift = Campus.getShift(d);
          if (mealShift == 'undefined') {
             mealShift = (d.hour < 15) ? 'Almoço' : 'Jantar';
          }
        }
      }
    } catch (_) {}

    return TodayCampusMeal(
      campus: campus,
      shiftLabel: mealShift ?? (Campus.isActive(sigla) ? Campus.getShift(now) : null),
      meal: todaysMeal,
    );
  }

  Future<void> _bindServicesCatalog() async {
    _syncShortcutsWithServices();
    // O worker é reativo à lista de serviços externos, garantindo que os atalhos sejam atualizados sempre que a lista de serviços mudar
    _servicesWorker = everAll([
      _externalModulesController.externalModulesList,
      _restaurantModulesController.restaurantModulesList,
    ], (_) => _syncShortcutsWithServices());
  }

  // Sincroniza as rotas dos atalhos com os serviços disponíveis
  void _syncShortcutsWithServices() {
    final allRoutes = allShortcutRoutes;
    shortcutRoutes.retainWhere(allRoutes.contains);
    _rebuildShortcutCaches();
  }

  Future<void> _loadSavedShortcuts() async {
    try {
      final userData = await _userDataRepository.getUserData();
      final saved = userData?.shortcutRoutes ?? <String>[];
      final validRoutes = allShortcutRoutes;
      final filteredSaved = saved.where(validRoutes.contains).toList();

      const defaultShortcuts = <String>[
        '/carteirinha_digital',
        '/pay_restaurant',
      ];

      // Corrige contas que ficaram com todos os serviços marcados como atalho
      // por um bug anterior que pré-selecionava tudo por padrão.
      final looksAutoSeeded =
          validRoutes.isNotEmpty && filteredSaved.length == validRoutes.length;

      if (looksAutoSeeded || filteredSaved.isEmpty) {
        shortcutRoutes.assignAll(defaultShortcuts);
        await _persistShortcuts();
      } else {
        shortcutRoutes.assignAll(filteredSaved);
      }

      _rebuildShortcutCaches();
    } catch (_) {}
  }

  Future<void> _persistShortcuts() async {
    try {
      await _userDataRepository.updateShortcutRoutes(shortcutRoutes.toList());
    } catch (_) {}
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

  Future<void> _showAppRecommendationDialog() async {
    final result = await AppAvailabilityService.checkBoth();

    try {
      if (!result.allInstalled) {
        await AppRecommendationDialog.show(result);
      }
    } catch (_) {}
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

  Set<String> get allShortcutRoutes =>
      allShortcutItems.map((shortcut) => shortcut.page).toSet();

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
  void onClose() {
    _servicesWorker.dispose();
    super.onClose();
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
