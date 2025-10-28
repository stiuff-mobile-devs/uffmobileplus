import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_transcript_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/controller/transcript_controller.dart';

class TranscriptBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TranscriptController>(() => TranscriptController());
    Get.put<ExternalTranscriptService>(ExternalTranscriptService(), permanent: true);
  }
}