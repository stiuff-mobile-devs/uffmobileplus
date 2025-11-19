import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/papers/controller/papers_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class PapersPage extends GetView<PapersController> {
  const PapersPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: Text('periodicos'.tr),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
      ),
      backgroundColor: AppColors.lightBlue(),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Column(
          children: [
            const SizedBox(height: 22),
            Center(
              child: Text(
                'escolha'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 35),
            SizedBox(
              width: 150,
              height: 150,
              child: IconButton(
                onPressed: () {
                  controller.goPapers();
                },
                icon: Image.asset('assets/papers/logos/capes_logo.png'),
              ),
            ),
            Center(
              child: Text(
                'CAPES',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
