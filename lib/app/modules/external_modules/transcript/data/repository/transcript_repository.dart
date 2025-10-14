import 'package:uffmobileplus/app/modules/external_modules/transcript/data/provider/transcript_provider.dart';

class TranscriptRepository {
  final TranscriptProvider _transcriptAPI = TranscriptProvider();

  // TODO: controller tem que passar pelo repository
  getTranscript(bool isRefresh) {
    return _transcriptAPI.getTranscript(isRefresh);
  }
}