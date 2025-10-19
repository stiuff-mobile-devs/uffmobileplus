import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/menu_controller.dart' as menu;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../../controller/restaurants_controller.dart';
import '../../data/models/campus_model.dart';
import '../../data/models/meal_model.dart';
import '../../data/repository/restaurant_repository.dart';
import '../details_page.dart';
import 'custom_polygon.dart';

class MenuWidget extends StatefulWidget {
  final String campus;

  const MenuWidget({
    super.key,
    required this.campus,
  });

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  late final restaurantRepository = Get.find<RestaurantRepository>();
  // late final gdiProvider = Get.find<GdiProvider>();
  // late final userRepository = Get.find<UserRepository>();
  late final menuController = Get.put(menu.MenuListController());

  int indexIsLoading = -1;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildMealCard(
      MealModel meal, int index, menu.MenuListController menuListController) {
    DateTime data = DateTime.parse(meal.date.toString());
    String type = data.hour == 12 || (data.hour == 11 && data.minute == 15)
        ? "Almoço"
        : "Jantar";
    String diaSemana = menuListController.getDayOfWeek(data.weekday);
    var currentMeals = menuController.MMController.getMeals();
    // MealModel prev = currentMeals[(index - 1) < 0 ? 0 : index - 1];
    MealModel post = currentMeals[(index + 1) > currentMeals.length - 1
        ? currentMeals.length - 1
        : index + 1];
    DateTime postData = DateTime.parse(post.date.toString());
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onHorizontalDragUpdate: (details) =>
                  menuListController.handleDragUpdate(index, details.delta.dx,
                      MediaQuery.of(context).size.width),
              onHorizontalDragEnd: (details) async =>
                  await menuListController.handleDragEnd(index, meal),
              onTap: () async {
                if (menuController.indexIsLoading.value == -1) {
                  await menuListController.handleTap(index, meal);
                }
              },
              onLongPress: () => menuListController.handlePress(index, meal),
              child: HorizontalMargin(
                left: (menuListController.containerLeftValues.isEmpty
                    ? 0
                    : menuListController.containerLeftValues[index]),
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                  child: Opacity(
                    opacity: (menuListController.containerOpacityValues.isEmpty
                        ? 1.0
                        : menuListController.containerOpacityValues[index]),
                    child: Stack(
                      children: [
                        _buildAcceptedStatus(index, meal),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Stack(
                            children: [
                              Container(
                                height: 300,
                                width: 400,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  // color: Colors.blue.withOpacity(0.3),
                                  color: (menuListController
                                          .getPressedOnto()
                                          .contains(meal)
                                      ? Colors.amber.withOpacity(0.4)
                                      : Colors.black.withOpacity(0.4)),
                                  border: Border.all(
                                    color: (menuListController
                                            .getPressedOnto()
                                            .contains(meal)
                                        ? Colors.amber
                                        : Colors.black),
                                    width: 10.5,
                                  ),
                                ),
                              ),
                              const Positioned(
                                width: 320,
                                height: 28,
                                top: 10.0,
                                right: 0.0,
                                child: CustomPolygon(
                                  points: [
                                    Offset(314.5, 0),
                                    Offset(314.5, 25),
                                    Offset(125, 25),
                                    Offset(110, 25 / 2),
                                    Offset(125, 0),
                                  ],
                                ),
                              ),
                              Positioned(
                                width: 320,
                                height: 56,
                                top: 10,
                                left: 5.5,
                                child: Column(
                                  children: [
                                    CustomPolygon(
                                      points: const [
                                        Offset(0, 0),
                                        Offset(0, 25),
                                        Offset(125, 25),
                                        Offset(110, 25 / 2),
                                        Offset(125, 0),
                                      ],
                                      color: Campus.getColor(meal.campus!)
                                          .withOpacity(0.80),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              // color: Colors.blue.withOpacity(0.3),
                            ),
                            width: 400,
                            height: 400,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // _buildAcceptedStatus(index, meal),
                                _buildMealHeader(diaSemana, data, type,
                                    menuListController, meal),
                                _buildMealDetails(meal),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: 120,
              child: InkWell(
                splashColor: Colors.blue.withOpacity(0.2),
                onTap: () async {
                  Get.to(
                    DetailsPage(
                      meal: meal,
                    ),
                    transition: Transition.rightToLeft,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Campus.getColor(meal.campus!).withOpacity(0.80),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Center(
                        child: Text(
                          'Ver Detalhes >>',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Jockey One',
                            fontSize: 16,
                            height: -0.05,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        ('${data.day.toString()}/${data.month.toString()}/${data.year.toString()}' !=
                '${postData.day.toString()}/${postData.month.toString()}/${postData.year.toString()}')
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Container(
                  width: 322.5,
                  height: 2.5,
                  decoration: BoxDecoration(
                      color: menuListController
                          .restaurantsController.evenDarkerBlue),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildMealHeader(String diaSemana, DateTime data, String type,
      menu.MenuListController controller, MealModel meal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 4.0, 4.0, 0.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 7.0, 8.0, 8.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5.5),
                child: SizedBox(
                  width: 90,
                  child: Center(
                    child: Text(
                      diaSemana,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Jockey One',
                        fontSize: 18,
                        height: -0.05,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 100.0, top: 0.1),
                child: Text(
                  '${data.day.toString()}/${data.month.toString()}/${data.year.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Jockey One',
                    fontSize: 18,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 24.0, top: 0.1, right: 0.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  decoration: BoxDecoration(
                      color: (type == 'Almoço')
                          ? Colors.transparent
                          : Colors.transparent),
                  child: Text(
                    type,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Jockey One',
                      fontSize: 18,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1.25),
                child: (type == "Almoço")
                    ? Icon(
                        Icons.sunny,
                        size: 20,
                        color: (!controller.MMController.mealsPressedOnto
                                .contains(meal))
                            ? Colors.amber
                            : Colors.black,
                      )
                    : Icon(
                        Icons.nightlight_round,
                        size: 20,
                        color: Colors.blue[900],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealDetails(MealModel meal) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '⦿ ${menuController.getShortField(meal.main!.isEmpty ? '-' : meal.main!)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    height: 2),
              ),
              Text(
                '⦿ ${menuController.getShortField(meal.garnish!.isEmpty ? '-' : meal.garnish!)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    height: 2),
              ),
              Text(
                '⦿ ${menuController.getShortField(meal.side!.isEmpty ? '-' : meal.side!)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    height: 2),
              ),
              Text(
                '⦿ ${menuController.getShortField(meal.salad1!.isEmpty ? '-' : meal.salad1!)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    height: 2),
              ),
              Text(
                '⦿ ${menuController.getShortField(meal.salad2!.isEmpty ? '-' : meal.salad2!, maxLength: 8)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    height: 2),
              ),
              Text(
                '⦿ ${menuController.getShortField(meal.dessert!.isEmpty ? '-' : meal.dessert!, maxLength: 8)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    height: 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptedStatus(int index, MealModel meal) {
    return Obx(() {
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              // color: Colors.blue.withOpacity(0.3),
            ),
            width: 400,
            height: 175 + 30,
          ),
          Positioned(
            right: 10,
            child: Container(
              width: 170,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                color: (menuController.indexIsLoading.value == index)
                    ? Colors.transparent
                    : menuController.MMController.checkAccepted(meal)
                        ? Colors.green.withOpacity(0.7)
                        : Colors.red.withOpacity(0.7),
                // color: Colors.blue.withOpacity(0.3),
              ),
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0),
                  child: (menuController.indexIsLoading.value == index)
                      ? const Center(
                          child: SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              color: Colors.amber,
                            ),
                          ),
                        )
                      : Text(
                          menuController.MMController.checkAccepted(meal)
                              ? 'PRESENÇA CONFIRMADA'
                              : 'PRESENÇA NÃO CONFIRMADA',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Jockey One',
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _loadingOrEmpty(RestaurantsController restaurantsController,
      int howManyMealsToday, menu.MenuListController menuListController) {
    if (restaurantsController.isFetchLoading == 1) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 140),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.amber,
            ),
          ),
        ),
      );
    } else if (restaurantsController.isFetchLoading == 0) {
      if (howManyMealsToday == 0) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 140),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 1.20,
              child: const Text(
                "Ainda não há refeições disponíveis para este refeitório.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Jockey One',
                  fontSize: 20,
                ),
              ),
            ),
          ),
        );
      }
    } else {
      debugPrint("Indicador isFetchLoading inválido.");
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    var currentMeals = menuController.MMController.getMeals();
    currentMeals.sort((a, b) => DateTime.parse(a.date.toString())
        .compareTo(DateTime.parse(b.date.toString())));
    int howManyMealsToday = menuController.MMController.getMeals()
        .where((meal) => menuController.checkDate(
            DateTime.parse(meal.date.toString()), meal.campus))
        .length;
    // Initializing
    menuController.containerLeftValues
        .addAll(List.generate(currentMeals.length, (index) => 0.0));
    menuController.containerOpacityValues
        .addAll(List.generate(currentMeals.length, (index) => 1.0));
    return (menuController.restaurantsController.isFetchLoading == 1 ||
            (menuController.restaurantsController.isFetchLoading == 0 &&
                howManyMealsToday == 0))
        ? _loadingOrEmpty(menuController.restaurantsController,
            howManyMealsToday, menuController)
        : SizedBox(
            child: OverflowBox(
                maxWidth: 1200,
                child: Scrollbar(
                    controller: menuController.scrollController,
                    thumbVisibility:
                        menuController.scrollController.hasClients &&
                            menuController.scrollController.offset > 0,
                    thickness: 4.0,
                    radius: const Radius.circular(4.0),
                    child: SingleChildScrollView(
                      controller: menuController.scrollController,
                      child: Obx(() => Padding(
                            padding:
                                const EdgeInsets.only(left: 5.0, right: 5.0),
                            child: Column(
                              children: currentMeals
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    MealModel meal = entry.value;
                                    DateTime data =
                                        DateTime.parse(meal.date.toString());
                                    if (!menuController.checkDate(
                                        data, meal.campus)) {
                                      return const SizedBox.shrink();
                                    }
                                    return Obx(() => _buildMealCard(
                                        meal, index, menuController));
                                  }).toList() +
                                  [
                                    SizedBox(
                                      height: menuController
                                                  .restaurantsController
                                                  .isAdminModeEnabled() ??
                                              false
                                          ? 65
                                          : 0,
                                    )
                                  ],
                            ),
                          )),
                    ))));
  }
}
