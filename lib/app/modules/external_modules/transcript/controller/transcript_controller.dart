import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/data/models/transcript_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/data/repository/transcript_repository.dart';

class TranscriptController extends GetxController {
  final TranscriptRepository _repository = TranscriptRepository();

  TranscriptModel? transcript;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchTranscript(false);
  }

  _fetchTranscript(bool isRefresh) async {
    transcript = await _repository.getTranscript(isRefresh);
    isLoading.value = false;
    update();
  }

  getTranscript() {
    return transcript?.transcript; // TODO: estranho
  }

  refreshTranscript() {
    isLoading.value = true;
    update();
    _fetchTranscript(true);
  }
}