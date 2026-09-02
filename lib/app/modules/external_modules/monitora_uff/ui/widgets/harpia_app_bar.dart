import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/google_groups_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class HarpiaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HarpiaAppBar({super.key});

  HarpiaGoogleGroupsController get googleGroupsController => Get.find<HarpiaGoogleGroupsController>();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: AppColors.appBarBottomGradient()),
      ),
      title: Obx(() => Text(
        'harpia_grupo_observado'.trParams({'group': '${googleGroupsController.observedGroup}'}),
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
      )),
      centerTitle: true,
      elevation: 8,
      foregroundColor: Colors.white,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            tooltip: 'abrir_menu'.tr,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}