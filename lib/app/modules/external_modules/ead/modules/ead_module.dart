import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/ead_controller.dart';

class EadModule extends GetView<EadController> {
  const EadModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EAD'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: controller.openClassroom,
              child: const Text('Acessar Google Classroom'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.openMoodle,
              child: const Text('Acessar Moodle'),
            ),
          ],
        ),
      ),
    );
  }
}

