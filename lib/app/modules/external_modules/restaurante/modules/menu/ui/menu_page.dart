import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/ui/widgets/custom_polygon.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/ui/widgets/menu_widget.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../utils/ui_components/custom_app_bar.dart';
import '../controller/menu_controller.dart' as menu;
import '../controller/restaurants_controller.dart';
import '../data/models/campus_model.dart';
import 'meal_form_page.dart';

class MenuPage extends StatefulWidget {
  final Campus location;
  const MenuPage({
    super.key,
    required this.location,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  final menu.MenuController menuController = Get.find<menu.MenuController>();

  late AnimationController editAnimationController;
  late AnimationController deleteAnimationController;

  @override
  void initState() {
    menuController.selectedLocation = widget.location;
    menuController.fetchCards();
    // Future.delayed(const Duration(seconds: 1), () {
    //   if (menuController.getMeals().isEmpty) {
    //     debugPrint("initState on MealMenu retrying!");
    //     menuController.fetchCards();
    //   }
    // });
    super.initState();
    editAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    deleteAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    editAnimationController.dispose();
    deleteAnimationController.dispose();
    super.dispose();
  }

  Widget _buildBottomBar(BuildContext context, menu.MenuController controller) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 90.0,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomPolygon(
                points: [
                  const Offset(0, 0),
                  const Offset(0, 56),
                  Offset(MediaQuery.of(context).size.width, 56),
                  Offset(MediaQuery.of(context).size.width, 0),
                  Offset(MediaQuery.of(context).size.width * 0.75, 0),
                  Offset(MediaQuery.of(context).size.width / 2, 16),
                  Offset(MediaQuery.of(context).size.width * 0.25, 0),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedActionButton(
                        editAnimationController, controller.canEdit, Icons.edit,
                        () {
                      if (controller.canEdit.value) {
                        controller
                            .handleEditAction(controller.mealsPressedOnto);
                      }
                    }),
                    const SizedBox(width: 25),
                    _buildAnimatedActionButton(
                      deleteAnimationController,
                      controller.canDelete,
                      Icons.delete,
                      () {
                        if (controller.canDelete.value) {
                          controller
                              .handleDeleteAction(controller.mealsPressedOnto);
                        }
                      },
                      color: Colors.red,
                    ),
                    const SizedBox(width: 25),
                    _buildAnimatedCounter(
                        deleteAnimationController, controller.canDelete, () {},
                        color: Colors.transparent),
                    const SizedBox(width: 25),
                    _buildActionButton(
                      Icons.check_box_outline_blank,
                      () {},
                      isVisible: false,
                    ),
                    const SizedBox(width: 25),
                    _buildActionButton(Icons.add_circle, () {
                      Get.to(
                        const MealFormPage(),
                        transition: Transition.rightToLeft,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPanel(
      Campus location, RestaurantsController bController) {
    return Obx(() {
      final double screenWidth = MediaQuery.of(context).size.width;
      final double screenHeight = MediaQuery.of(context).size.height;
      return GestureDetector(
        onTap: () {
          menuController.toggleBlur();
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SizedBox(
            height: screenHeight * 0.275,
            child: Stack(
              children: [
                Container(
                  height: screenHeight * 0.275,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    height: screenHeight * 0.25,
                    decoration: BoxDecoration(
                      color: bController.evenDarkerBlue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Stack(
                          children: [
                            Image.asset(
                              location.panelImgPath ?? '',
                              width: screenWidth,
                              height: screenHeight * 0.1875,
                              fit: BoxFit.cover,
                            ),
                            if (menuController.isBlurred.value)
                              Positioned.fill(
                                child: Stack(
                                  children: [
                                    BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 5.0,
                                        sigmaY: 5.0,
                                      ),
                                      child: Container(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.3)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 50.0),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    "Horário de Almoço:\n${Campus.getSchedule(Campus.getSigla(location.name))[0].substring(11, 16)} às ${Campus.getSchedule(Campus.getSigla(location.name))[1].substring(11, 16)}",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: "Jost",
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                if (Campus.getSigla(
                                                            location.name) ==
                                                        'gr' ||
                                                    Campus.getSigla(
                                                            location.name) ==
                                                        'pv')
                                                  Flexible(
                                                    child: Text(
                                                      "Horário de Jantar:\n${Campus.getSchedule(Campus.getSigla(location.name))[2].substring(11, 16)} às ${Campus.getSchedule(Campus.getSigla(location.name))[3].substring(11, 16)}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: "Jost",
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (!menuController.isBlurred.value)
                              Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 2.0,
                                            top: 2.0,
                                            left: 8.0,
                                            right: 2.0),
                                        child: IntrinsicWidth(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Ver Horários',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: "Jost",
                                                ),
                                              ),
                                              SizedBox(width: 3),
                                              Icon(
                                                size: 20,
                                                Icons.arrow_drop_down,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6.0, right: 22.0),
                    child: Text(
                      location.name,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Jockey One',
                        fontSize: 24,
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
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 0.0),
                    child: IntrinsicWidth(
                      child: Container(
                        decoration:
                            const BoxDecoration(color: Colors.transparent),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(2, 2, 6, 2),
                          child: Row(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: (Campus.isActive(
                                            Campus.getSigla(location.name)))
                                        ? Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.green),
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: (Campus.isActive(
                                              Campus.getSigla(location.name)))
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  (Campus.isActive(
                                          Campus.getSigla(location.name))
                                      ? 'Aberto'
                                      : 'Fechado'),
                                  style: TextStyle(
                                    color: (Campus.isActive(
                                            Campus.getSigla(location.name)))
                                        ? Colors.green
                                        : Colors.red,
                                    fontFamily: 'Jost',
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAnimatedActionButton(AnimationController animationController,
      RxBool condition, IconData icon, Function() action,
      {color = Colors.white, isVisible = true}) {
    final opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));
    return Obx(() {
      if (condition.value) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
      return FadeTransition(
        opacity: opacityAnimation,
        child: SlideTransition(
          position: offsetAnimation,
          child: SizedBox(
            width: 45,
            height: 45,
            child: FloatingActionButton(
              elevation: (!isVisible) ? 0 : null,
              backgroundColor: (!isVisible)
                  ? Colors.transparent
                  : menuController.restaurantController.evenDarkerBlue,
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                      style: BorderStyle.solid,
                      color: (!isVisible)
                          ? Colors.transparent
                          : menuController.restaurantController.mediumDarkBlue,
                      width: 4)),
              onPressed: action,
              child: Icon(
                icon,
                size: 35,
                color: (!isVisible) ? Colors.transparent : color,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAnimatedCounter(AnimationController animationController,
      RxBool condition, Function() action,
      {color = Colors.white, isVisible = true}) {
    final opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));
    return Obx(() {
      if (condition.value) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
      return FadeTransition(
        opacity: opacityAnimation,
        child: SlideTransition(
          position: offsetAnimation,
          child: SizedBox(
            width: 45,
            height: 45,
            child: FloatingActionButton(
              elevation: (!isVisible) ? 0 : null,
              backgroundColor: (!isVisible)
                  ? Colors.transparent
                  : Colors.amber.withOpacity(0.4),
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                      style: BorderStyle.solid,
                      color: (!isVisible)
                          ? Colors.transparent
                          : Colors.amber.withOpacity(0.9),
                      width: 4)),
              onPressed: action,
              child: Text(
                '${menuController.mealsPressedOnto.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontFamily: "Jost",
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildActionButton(IconData icon, Function() action,
      {color = Colors.white, isVisible = true}) {
    return SizedBox(
      width: 45,
      height: 45,
      child: FloatingActionButton(
        elevation: (!isVisible) ? 0 : null,
        backgroundColor: (!isVisible)
            ? Colors.transparent
            : menuController.restaurantController.evenDarkerBlue,
        shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                style: BorderStyle.solid,
                color: (!isVisible)
                    ? Colors.transparent
                    : menuController.restaurantController.mediumDarkBlue,
                width: 4)),
        onPressed: action,
        child: Icon(
          icon,
          size: 35,
          color: (!isVisible) ? Colors.transparent : color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<menu.MenuController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: controller.restaurantController.darkBlue,
          appBar: customAppBar(
            (controller.restaurantController.isLoading ? '' : 'Refeições'),
            borderRadius: 0,
            actions: [
              IconButton(
                onPressed: () {
                  controller.fetchCards();
                },
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                onPressed: () {
                  Get.toNamed(Routes.WEB_VIEW, arguments: {
                    'url':
                        'https://citsmart.uff.br/citsmart/pages/knowledgeBasePortal/knowledgeBasePortal.load#/knowledge/4060',
                    'title': 'restaurant'.tr,
                  });
                },
                icon: const Icon(Icons.question_mark),
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  _buildLocationPanel(controller.selectedLocation,
                      controller.restaurantController),
                  const SizedBox(height: 10),
                  Expanded(
                    child: MenuWidget(
                      campus: controller.selectedLocation.name,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
              (controller.restaurantController.isAdminModeEnabled() ?? false)
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildBottomBar(context, controller),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          // floatingActionButton: FloatingActionButton(
          //   tooltip: 'Pagar Restaurante',
          //   splashColor: Colors.white,
          //   backgroundColor: controller.restaurantController.evenDarkerBlue,
          //   onPressed: () {
          //     Get.toNamed(
          //       Routes.PAY_RESTAURANT,
          //     );
          //   },
          //   child: SvgPicture.asset(
          //     'assets/images/qr-code.svg',
          //     width: 28,
          //     height: 28,
          //     color: Colors.white,
          //     semanticsLabel: 'Pagar Restaurante',
          //   ),
          // ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}
