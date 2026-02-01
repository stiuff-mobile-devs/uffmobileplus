import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/central_de_atendimento/controller/central_de_atendimento_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CentralDeAtendimentoPage extends GetView<CentralDeAtendimentoController> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          elevation: 8,
          foregroundColor: Colors.white,
          title: Text('central_de_atendimento'.tr),
          flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
          ),
        ),
        backgroundColor: AppColors.lightBlue(),
        body: WebViewWidget(controller: controller.webController),
    );
  }
}