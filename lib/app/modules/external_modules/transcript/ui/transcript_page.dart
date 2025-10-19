import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/controller/transcript_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/data/models/transcript_discipline.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class TranscriptPage extends StatelessWidget {
  const TranscriptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TranscriptController>();
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Histórico"),
        centerTitle: true,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: const Icon(Icons.question_mark)),
        ],
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Obx(
          () => controller.isLoading.value
              ? const CustomCircularProgressIndicator()
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  child: const SemesterExpansionPanelList(),
                ),
        ),
      ),
    );
  }
}

/// Widget exibido quando o histórico estiver carregando.
class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3.5),
      ),
    );
  }
}

class SemesterExpansionPanelList extends GetView<TranscriptController> {
  const SemesterExpansionPanelList({super.key});

  String _formatYearSemester(int value) {
    final s = value.toString();
    if (s.length <= 1) return s;
    String year = s.substring(0, s.length - 1);
    String semester = s.substring(s.length - 1);
    return '$year.$semester';
  }

  @override
  Widget build(BuildContext context) {
    final semesters = List<int>.from(controller.getOrderedSemesters());
    return Obx(() {
      return ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          controller.toggleSemester(semesters[index]);
        },
        children: semesters.map((semester) {
          final expanded = controller.isSemesterExpanded(semester);
          final disciplines = controller.getDisciplinesForSemester(semester);

          return ExpansionPanel(
            canTapOnHeader: true,
            headerBuilder: (_, _) => ListTile(
              title: Text('Semestre ${_formatYearSemester(semester)}'),
              subtitle: Text('${disciplines.length} disciplinas'),
            ),
            body: Column(
              children: disciplines.isEmpty
                  ? const [ListTile(title: Text('Semestre vazio'))]
                  : disciplines.map((d) {
                      return Column(
                        children: [
                          TranscriptDisciplineCard(discipline: d),
                          const Divider(height: 0),
                        ],
                      );
                    }).toList(),
            ),
            isExpanded: expanded,
          );
        }).toList(),
      );
    });
  }
}

/// Card correspondente a cada disciplina exibida quando o painel de um semestre
/// é expandido.
class TranscriptDisciplineCard extends StatelessWidget {
  final TranscriptDiscipline discipline;

  const TranscriptDisciplineCard({super.key, required this.discipline});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(discipline.nome ?? discipline.codigoDisciplina ?? '—'),
      subtitle: Text(
        'Código: ${discipline.codigoDisciplina ?? '-'} • CH: ${discipline.cargahoraria ?? '-'}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Nota: ${discipline.nota ?? '-'}'),
          Text(
            discipline.statusHistorico ?? '',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
