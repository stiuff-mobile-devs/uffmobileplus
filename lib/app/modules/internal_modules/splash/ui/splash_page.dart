import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/modules/internal_modules/splash/controller/splash_controller.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      body: GetBuilder<SplashController>(
          builder: (SplashController controller) {
            return Stack(
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 1200),
                  opacity: controller.visibleStrip ? 1.0 : 0.0,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.access_time,
                            size: controller.findIconSize(), color: Colors.white),
                        Icon(Icons.settings,
                            size: controller.findIconSize(), color: Colors.white),
                        Icon(Icons.account_balance,
                            size: controller.findIconSize(), color: Colors.white),
                        Icon(Icons.edit,
                            size: controller.findIconSize(), color: Colors.white),
                        Icon(Icons.directions_bus,
                            size: controller.findIconSize(), color: Colors.white),
                        Icon(Icons.access_time,
                            size: controller.findIconSize(), color: Colors.white),
                        Icon(Icons.settings,
                            size: controller.findIconSize(), color: Colors.white),
                        Icon(Icons.wifi,
                            size: controller.findIconSize(), color: Colors.white),
                        Icon(Icons.local_library,
                            size: controller.findIconSize(), color: Colors.white),
                        Icon(Icons.format_list_bulleted,
                            size: controller.findIconSize(), color: Colors.white),
                        Icon(Icons.restaurant,
                            size: controller.findIconSize(), color: Colors.white),
                        Icon(Icons.library_books,
                            size: controller.findIconSize(), color: Colors.white),
                        Icon(Icons.settings,
                            size: controller.findIconSize(), color: Colors.white),
                        Icon(Icons.wifi,
                            size: controller.findIconSize(), color: Colors.white),
                        Icon(Icons.local_library,
                            size: controller.findIconSize(), color: Colors.white),
                      ],
                    ),
                  ),
                ),
                AnimatedContainer(
                  curve: Curves.fastOutSlowIn,
                  duration: const Duration(milliseconds: 1300),
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: controller.animatedMargin),
                  child: SizedBox(
                    width: controller.findLogoSize(),
                    height: controller.findLogoSize(),
                    child: Card(
                      color: Colors.white,
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset(
                          'assets/logos/logo_um+.png',
                          height: 240.0,
                          alignment: Alignment.center,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }
}
