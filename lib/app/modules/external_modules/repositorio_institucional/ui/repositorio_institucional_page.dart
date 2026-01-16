import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/repositorio_institucional/controller/repositorio_institucional_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RepositorioInstitucionalPage extends GetView<RepositorioInstitucionalController> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
    appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: Text('repositorio_institucional'.tr),
        flexibleSpace: Container(
        decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
      ),
    ),
    backgroundColor: AppColors.lightBlue(),
    body: WebViewWidget(controller: controller.webController),
    );
  }
}