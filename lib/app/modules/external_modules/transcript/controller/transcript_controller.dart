import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/data/models/transcript_discipline.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/data/models/transcript_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/data/repository/transcript_repository.dart';

class TranscriptController extends GetxController {
  final TranscriptRepository _repository = TranscriptRepository();

  TranscriptModel? transcript;
  RxBool isLoading = true.obs;
  final RxMap<int, bool> expandedSemesters = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchTranscript(false);
  }

  void toggleSemester(int semester) {
    expandedSemesters[semester] = !(expandedSemesters[semester] ?? false);
  }

  bool isSemesterExpanded(int semester) => expandedSemesters[semester] ?? false;

  List<TranscriptDiscipline> getDisciplinesForSemester(int semester) {
    final all = transcript?.transcript?.disciplinas ?? <TranscriptDiscipline>[];
    return all.where((d) => d.anosemestre == semester).toList()
      ..sort((a, b) => (a.nome ?? '').compareTo(b.nome ?? ''));
  }

  _fetchTranscript(bool isRefresh) async {
    transcript = await _repository.getTranscript(isRefresh);
    expandedSemesters
      ..clear()
      ..addEntries(
        List<int>.from(getOrderedSemesters()).map((s) => MapEntry(s, false)),
      );
    isLoading.value = false;
  }

  getTranscript() {
    return transcript?.transcript;
  }

  refreshTranscript() {
    isLoading.value = true;
    _fetchTranscript(true);
  }

  /// Retorna uma lista de semestres ordenados.
  getOrderedSemesters() {
    final disciplinas = transcript?.transcript?.disciplinas;
    if (disciplinas == null) return <int>[];
    return disciplinas
        .map((d) => d.anosemestre) // Mapeia uma disciplina, para o seu semestre
        .whereType<int>() // mantém apenas os semestre que são inteiros
        .toSet() // remove semestres duplicados
        .toList() // transforma conjunto em lista
      ..sort(); // ordena a lista
  }
}
