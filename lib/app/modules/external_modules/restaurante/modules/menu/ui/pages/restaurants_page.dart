import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/ui/widgets/custom_polygon.dart';
import '../../../../../../../routes/app_routes.dart';
import '../../../../../../../utils/color_pallete.dart';
import '../../../../../../../utils/ui_components/custom_alert_dialog.dart';
import '../../../../../../../utils/ui_components/custom_app_bar.dart';
import '../../../../../../../utils/ui_components/custom_progress_display.dart';
import '../../controller/restaurants_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/campus_model.dart';
import 'meal_form_page.dart';
import 'menu_page.dart';

class RestaurantsPage extends StatefulWidget {
  const RestaurantsPage({super.key});

  @override
  State<RestaurantsPage> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  final restaurantsController = Get.find<RestaurantsController>();
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    if (prefs != null) {
      prefs!.setBool('hasShownWarning', false);
      prefs!.setBool('hasShownGdiFailureWarning', false);
    }
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  void _showGdiFailureSign() {
    if (prefs == null) return;

    bool hasShownGdiFailureWarning =
        prefs!.getBool('hasShownGdiFailureWarning') ?? false;
    if (!hasShownGdiFailureWarning &&
        restaurantsController.isAdminModeEnabled() == null) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        await customAlertDialog(
          Get.context!,
          title: "O GDI Falhou! :(",
          desc:
          "O serviço de Gestão de Identidade apresentou instabilidade. Algumas funções do módulo podem estar indisponíveis.",
          onConfirm: () {
            prefs!.setBool('hasShownGdiFailureWarning', true);
          },
          btnConfirmColor: const Color.fromARGB(255, 91, 45, 199),
          btnConfirmText: "Estou ciente e desejo continuar.",
          dismissOnTouchOutside: true,
          dismissOnBackKeyPress: true,
        ).show();
      });
    }
  }

  Widget _buildLocationCard(
      Campus location, int index, RestaurantsController controller) {
    Widget img = SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: SizedBox(
                width: 95,
                height: 95,
                child: Image.asset(
                  location.iconImgPath ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: controller.mediumDarkBlue, width: 8),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          Center(
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                    color: Colors.black.withValues(alpha: 0.3),
                    width: 8,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          Align(
            alignment:
            (index % 2 == 0) ? Alignment.topLeft : Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: (Campus.isActive(Campus.getSigla(location.name)))
                        ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    )
                        : const SizedBox.shrink(),
                  ),
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: (Campus.isActive(Campus.getSigla(location.name)))
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Widget txt = Padding(
      padding: index % 2 == 0
          ? const EdgeInsets.only(right: 8.0)
          : const EdgeInsets.only(left: 8.0),
      child: SizedBox(
          child: Column(
            children: [
              Align(
                alignment:
                index % 2 == 0 ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  location.colorId.shouldReference,
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'Jockey One', fontSize: 24),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment:
                index % 2 == 0 ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  location.shortAddress,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Jockey One',
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment:
                index % 2 == 0 ? Alignment.centerRight : Alignment.centerLeft,
                child: SizedBox(
                  width: 220,
                  height: 30,
                  child: FloatingActionButton(
                    backgroundColor: location.colorId.color,
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: null, // Botão agora não faz nada
                    child: const Text(
                      'Ver Refeições',
                      style: TextStyle(
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
              ),
            ],
          )),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: Stack(
        children: [
          Container(
            width: 500,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              width: 500,
              height: 100,
              decoration: BoxDecoration(
                color: controller.evenDarkerBlue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: OverflowBox(
                minHeight: 0.0,
                maxHeight: double.infinity,
                minWidth: 0.0,
                maxWidth: double.infinity,
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: SizedBox(
                    width: 350,
                    height: 120,
                    child: (index % 2 == 0)
                        ? Row(
                      children: [
                        img,
                        const SizedBox(width: 10),
                        Expanded(child: txt),
                      ],
                    )
                        : Row(
                      children: [
                        Expanded(child: txt),
                        const SizedBox(width: 10),
                        img,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: controller.evenDarkerBlue,
                onTap: () {
                  Get.to(
                    MenuPage(
                      location: location,
                    ),
                    transition: Transition.rightToLeft,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
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
            : restaurantsController.evenDarkerBlue,
        shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                style: BorderStyle.solid,
                color: (!isVisible)
                    ? Colors.transparent
                    : restaurantsController.mediumDarkBlue,
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

  Widget _buildBottomBar(
      BuildContext context, RestaurantsController controller) {
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
                    const SizedBox(width: 25),
                    // _buildActionButton(
                    //   Icons.history,
                    //       () {},
                    //   color: Colors.transparent,
                    // ),
                    const SizedBox(width: 25),
                    _buildActionButton(
                      Icons.add_circle,
                          () {
                        if (controller.isAdminModeEnabled() ?? false) {
                          Get.to(
                            const MealFormPage(),
                            transition: Transition.rightToLeft,
                          );
                        }
                      },
                      isVisible: controller.isAdminModeEnabled() ?? false,
                    ),
                    const SizedBox(width: 25),
                    // _buildActionButton(
                    //   Icons.email_outlined,
                    //       () {},
                    //   color: Colors.transparent,
                    // ),
                    const SizedBox(width: 25),
                    // _buildActionButton(
                    //   Icons.map_outlined,
                    //       () => Get.to(const LocationsPage(),
                    //       transition: Transition.rightToLeft),
                    //   color: Colors.white,
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantsController>(
      builder: (restaurantsController) {
        if (!restaurantsController.isLoading) {
          _showGdiFailureSign();
        }
        return Scaffold(
          backgroundColor: Colors.blueAccent,
          appBar: AppBar(
            centerTitle: true,
            elevation: 8,
            foregroundColor: Colors.white,
            title: const Text("Restaurantes"),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: AppColors.appBarTopGradient(),
              ),
            ),
          ),
          body: restaurantsController.isLoading
              ? const Center(
              child: CustomProgressDisplay(
                brightMode: true,
              ))
              : Stack(
            children: [
              SizedBox.expand(
                child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.darkBlueToBlackGradient(),
              ))),
              Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Column(
                    children: restaurantsController.locations
                        .asMap()
                        .entries
                        .map((entry) {
                      int index = entry.key;
                      Campus loc = entry.value;
                      return _buildLocationCard(
                          loc, index, restaurantsController);
                    }).toList() +
                        [
                          const SizedBox(
                            height: 95,
                          )
                        ],
                  ),
                ),
              ),
              _buildBottomBar(context, restaurantsController),
            ],
          ),
        );
      },
    );
  }
}
