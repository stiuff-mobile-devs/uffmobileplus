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
import 'package:uffmobileplus/app/modules/internal_modules/login/controller/login_controller.dart';
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
    await _loadSectionPrefs();

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

  /// Recarrega tudo que depende do usuário logado. Chamado depois de um login
  /// feito com a Home já aberta: o controller não é recriado nesse caso, então
  /// sem isto a dashboard só mostrava os dados novos ao reabrir o app.
  Future<void> reloadSession() async {
    await _externalModulesServices.initialize();
    await _loadProfileData();

    isLoadingTodayClasses.value = true;
    isLoadingTranscript.value = true;
    await Future.wait([_loadTodayClasses(), _loadTranscriptStats()]);

    // Os workers de _bindServicesCatalog ressincronizam os atalhos quando
    // estas listas mudam.
    await Future.wait([
      _externalModulesController.reload(),
      _restaurantModulesController.reload(),
    ]);
    await _loadSavedShortcuts();

    if (Get.isRegistered<LoginController>()) {
      await Get.find<LoginController>().reloadUserData();
    }
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
          orElse: () => _restaurantsController.locations.first
        );
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
          todayMeals.sort(
            (a, b) => DateTime.parse(
              a.date.toString(),
            ).compareTo(DateTime.parse(b.date.toString())),
          );

          final schedule = Campus.getSchedule(sigla);

          for (var m in todayMeals) {
            final d = DateTime.parse(m.date.toString());
            DateTime? endTime;

            if (d.hour < 15) {
              // Almoço
              if (schedule.length >= 2 && schedule[1] != 'null') {
                endTime = DateTime.parse(schedule[1]);
              } else {
                endTime = DateTime(now.year, now.month, now.day, 15, 0);
              }
            } else {
              // Jantar
              if (schedule.length >= 4 && schedule[3] != 'null') {
                endTime = DateTime.parse(schedule[3]);
              } else {
                endTime = DateTime(now.year, now.month, now.day, 20, 0);
              }
            }

            if (now.isBefore(endTime)) {
              todaysMeal = m;
              break;
            }
          }

          final baseDate = todaysMeal != null 
              ? DateTime.parse(todaysMeal.date.toString()) 
              : now;
          
          mealShift = Campus.getShift(baseDate);

          if (mealShift == 'undefined') {
            mealShift = (baseDate.hour < 15) ? 'almoco'.tr : 'jantar'.tr;
          }
        }
      }
    } catch (_) {}

    return TodayCampusMeal(
      campus: campus,
      shiftLabel: Campus.isActive(sigla) ? mealShift : null,
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
  }

  /// Move o atalho de [oldIndex] para [newIndex] (posição final, já
  /// ajustada; é o que o `onReorderItem` do ReorderableListView entrega).
  void reorderShortcut(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= shortcutRoutes.length) return;
    final route = shortcutRoutes.removeAt(oldIndex);
    shortcutRoutes.insert(newIndex.clamp(0, shortcutRoutes.length), route);
    _rebuildShortcutCaches();
    _persistShortcuts();
  }

  // ---------------- SEÇÕES DA HOME ----------------
  // Ordem e visibilidade ficam no aparelho (SharedPreferences), como o
  // restaurante padrão: continuam valendo depois de sair da conta.

  static const String _sectionsOrderKey = 'home_sections_order';
  static const String _sectionsHiddenKey = 'home_sections_hidden';

  static const List<HomeSection> defaultSectionOrder = [
    HomeSection.studyPlan,
    HomeSection.restaurant,
    HomeSection.shortcuts,
    HomeSection.transcript,
    HomeSection.news,
  ];

  final sectionOrder = <HomeSection>[...defaultSectionOrder].obs;
  final hiddenSections = <HomeSection>{}.obs;

  List<HomeSection> get visibleSections =>
      sectionOrder.where((s) => !hiddenSections.contains(s)).toList();

  Future<void> _loadSectionPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final byName = {for (final s in HomeSection.values) s.name: s};

      // Ignora nomes desconhecidos e acrescenta no fim seções novas que
      // ainda não estavam salvas (atualizações futuras do app).
      final saved = (prefs.getStringList(_sectionsOrderKey) ?? const [])
          .map((n) => byName[n])
          .whereType<HomeSection>()
          .toList();
      final order = [
        ...saved,
        ...defaultSectionOrder.where((s) => !saved.contains(s)),
      ];
      sectionOrder.assignAll(order);

      hiddenSections.assignAll(
        (prefs.getStringList(_sectionsHiddenKey) ?? const [])
            .map((n) => byName[n])
            .whereType<HomeSection>(),
      );
    } catch (e) {
      debugPrint('Erro ao carregar seções da Home: $e');
    }
  }

  Future<void> _persistSectionPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _sectionsOrderKey,
        sectionOrder.map((s) => s.name).toList(),
      );
      await prefs.setStringList(
        _sectionsHiddenKey,
        hiddenSections.map((s) => s.name).toList(),
      );
    } catch (e) {
      debugPrint('Erro ao salvar seções da Home: $e');
    }
  }

  /// Move a seção [delta] posições entre as seções visíveis (-1 sobe, 1 desce).
  void moveSection(HomeSection section, int delta) {
    final visible = visibleSections;
    final from = visible.indexOf(section);
    final to = from + delta;
    if (from < 0 || to < 0 || to >= visible.length) return;

    // Troca de lugar com a vizinha visível, mantendo as ocultas onde estão.
    final neighbor = visible[to];
    final i = sectionOrder.indexOf(section);
    final j = sectionOrder.indexOf(neighbor);
    sectionOrder[i] = neighbor;
    sectionOrder[j] = section;
    _persistSectionPrefs();
  }

  void hideSection(HomeSection section) {
    hiddenSections.add(section);
    _persistSectionPrefs();
  }

  void showSection(HomeSection section) {
    hiddenSections.remove(section);
    _persistSectionPrefs();
  }

  void resetSections() {
    sectionOrder.assignAll(defaultSectionOrder);
    hiddenSections.clear();
    _persistSectionPrefs();
  }

  void openShortcut(DashboardShortcut service) {
    Get.toNamed(
      service.page,
      arguments: {
        'url': service.url ?? '',
        'title': service.subtitle.tr,
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

/// Seções da Home que o usuário pode reordenar e ocultar. O `name` é salvo
/// nas preferências, então não renomeie os valores.
enum HomeSection { studyPlan, restaurant, shortcuts, transcript, news }

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
  /// Translation KEY, not display text.
  ///
  /// These lists are field initialisers, evaluated once when the controller is
  /// constructed, so resolving `.tr` here would freeze the label in whatever
  /// language was active at startup. Call `.tr` at the render site instead, so
  /// the label follows `Get.updateLocale`.
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
