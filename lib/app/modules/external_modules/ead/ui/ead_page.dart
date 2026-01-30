import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/ead_controller.dart';

class EadPage extends GetView<EadController> {
  const EadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EAD'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: controller.openClassroom,
              child: const Text('Google Classroom'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.openMoodle,
              child: const Text('Moodle'),
            ),
          ],
        ),
      ),
    );
  }
}
