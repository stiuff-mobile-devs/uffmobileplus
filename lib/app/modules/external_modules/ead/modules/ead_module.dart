import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/ead_controller.dart';

class EadModule extends GetView<EadController> {
  const EadModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ead'.tr),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: controller.openClassroom,
              child: Text('acessar_google_classroom'.tr),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.openMoodle,
              child: Text('acessar_moodle'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

