import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/ui/widgets/custom_polygon.dart';
import '../../../../../../../routes/app_routes.dart';
import '../../../../../../../utils/color_pallete.dart';
import '../../../../../../../utils/ui_components/custom_app_bar.dart';
import '../../controller/details_controller.dart';
import '../../data/models/campus_model.dart';
import '../../data/models/meal_model.dart';

class DetailsPage extends StatefulWidget {
  final MealModel meal;
  const DetailsPage({super.key, required this.meal});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final DetailsController detailsController = Get.find<DetailsController>();

  final TransformationController _transformationController =
      TransformationController();
  double _scale = 1.0;

  void _zoomIn() {
    _scale = (_scale >= 4.0 ? 4.0 : _scale + 0.5);
    _applyScale();
  }

  void _zoomOut() {
    _scale = (_scale <= 1.0 ? 1.0 : _scale - 0.5);
    _applyScale();
  }

  void _applyScale() {
    _transformationController.value = Matrix4.identity()..scale(_scale);
  }

  Widget _buildMealPost(MealModel meal) {
    return Stack(
      children: [
        Container(
          width: 350,
          height: 615,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: 350,
            height: 585,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: detailsController.restaurantsController.evenDarkerBlue,
            ),
            child: Center(
              child: FutureBuilder(
                  future: Future.delayed(const Duration(seconds: 1), () {
                    return detailsController.createMealMenuVisualizer(meal);
                  }),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    return (snapshot.connectionState == ConnectionState.waiting)
                        ? const CircularProgressIndicator(
                            color: Colors.amber,
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 10,
                                  offset: Offset(0, 0),
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: InteractiveViewer(
                                transformationController:
                                    _transformationController,
                                panEnabled: true,
                                minScale: 1.0,
                                maxScale: 4.0,
                                child: SizedBox(
                                  width: 282.5,
                                  height: 498,
                                  child: Image.memory(
                                      Uint8List.fromList(snapshot.data)),
                                ),
                              ),
                            ),
                          );
                  }),
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 32.5,
          child: Text(
            Campus.getName(widget.meal.campus ?? ''),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Jockey One',
              fontSize: 30,
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
      ],
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
            : detailsController.restaurantsController.evenDarkerBlue,
        shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                style: BorderStyle.solid,
                color: (!isVisible)
                    ? Colors.transparent
                    : detailsController.restaurantsController.mediumDarkBlue,
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

  Widget _buildBottomBar(BuildContext context, DetailsController controller) {
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
                    _buildActionButton(
                      Icons.zoom_in,
                      () => _zoomIn(),
                    ),
                    const SizedBox(width: 25),
                    _buildActionButton(
                      Icons.zoom_out,
                      () => _zoomOut(),
                    ),
                    const SizedBox(width: 25),
                    _buildActionButton(
                      Icons.check_box_outline_blank,
                      () {},
                      isVisible: false,
                    ),
                    const SizedBox(width: 25),
                    _buildActionButton(
                      Icons.check_box_outline_blank,
                      () {},
                      isVisible: false,
                    ),
                    const SizedBox(width: 25),
                    _buildActionButton(
                      Icons.share,
                      () {
                        controller.shareImage(widget.meal);
                      },
                    ),
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
    return GetBuilder<DetailsController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: detailsController.restaurantsController.darkBlue,
          appBar: AppBar(
            centerTitle: true,
            elevation: 8,
            foregroundColor: Colors.white,
            title: const Text("Detalhes da Refeição"),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: AppColors.appBarTopGradient(),
              ),
            ),
          ),
          body: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildMealPost(widget.meal),
                  ],
                ),
              ),
              _buildBottomBar(context, controller)
            ],
          ),
        );
      },
    );
  }
}
