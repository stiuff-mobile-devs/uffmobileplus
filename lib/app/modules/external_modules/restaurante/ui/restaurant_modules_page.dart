import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/controller/restaurant_modules_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class RestaurantModulesPage extends StatelessWidget {
  const RestaurantModulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: GetBuilder<RestaurantModulesController>(
          init: RestaurantModulesController(),
          builder: (controller) {
            return Obx(() {
              final modules = controller.restaurantModulesList;
              final moduleCount = modules.length;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = _crossAxisCountForWidth(
                    constraints.maxWidth,
                  );
                  final childAspectRatio = constraints.maxWidth < 360
                      ? 0.86
                      : constraints.maxWidth < 600
                          ? 0.92
                          : 0.98;

                  return CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        foregroundColor: Colors.white,
                        title: Text('restaurante_universitario'.tr),
                        centerTitle: true,
                        elevation: 8,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(10),
                          ),
                        ),
                        flexibleSpace: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.appBarTopGradient(),
                          ),
                        ),
                        actions: <Widget>[
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.question_mark),
                          ),
                        ],
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final restaurantModule = modules[index];
                            return _moduleCard(
                              restaurantModule: restaurantModule,
                              controller: controller,
                            );
                          }, childCount: moduleCount),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: childAspectRatio,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            });
          },
        ),
      ),
    );
  }

  int _crossAxisCountForWidth(double width) {
    if (width < 360) return 2;
    if (width < 600) return 3;
    if (width < 900) return 4;
    return 5;
  }

  Widget _moduleCard({
    required RestaurantModules restaurantModule,
    required RestaurantModulesController controller,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.white.withOpacity(0.08),
        highlightColor: Colors.white.withOpacity(0.04),
        onTap: () async {
          await Future.delayed(const Duration(milliseconds: 80));
          controller.navigateTo(
            restaurantModule.page,
            interrogation: restaurantModule.interrogation ?? false,
            webViewUrl: restaurantModule.url!,
            appBarTitle: restaurantModule.subtitle,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: AppColors.appBarTopGradient(),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.cyan.withOpacity(0.30),
                              Colors.blue.withOpacity(0.18),
                              AppColors.darkBlue().withOpacity(0.08),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.16),
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            restaurantModule.iconSrc,
                            width: 28,
                            height: 28,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        restaurantModule.subtitle.tr,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
