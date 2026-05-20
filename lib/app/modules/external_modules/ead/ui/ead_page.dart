import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/ead_controller.dart';

class EadPage extends GetView<EadController> {
  const EadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ead'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: controller.openClassroom,
              child: Text('google_classroom'.tr),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.openMoodle,
              child: Text('moodle'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
