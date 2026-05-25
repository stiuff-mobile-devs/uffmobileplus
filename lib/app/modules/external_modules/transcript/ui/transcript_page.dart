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
        title: Text("historico".tr),
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
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CustomCircularProgressIndicator();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 420 ? 12.0 : 20.0;
              final contentWidth = constraints.maxWidth > 980
                  ? 920.0
                  : constraints.maxWidth;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  12,
                  horizontalPadding,
                  20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: const _TranscriptContent(),
                  ),
                ),
              );
            },
          );
        }),
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

class _TranscriptContent extends GetView<TranscriptController> {
  const _TranscriptContent();

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
    final disciplinesCount = semesters.fold<int>(
      0,
      (total, semester) => total + controller.getDisciplinesForSemester(semester).length,
    );

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.cyan.withOpacity(0.30),
                        Colors.blue.withOpacity(0.18),
                        AppColors.darkBlue().withOpacity(0.08),
                      ],
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.16)),
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'historico'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${semesters.length} ${'semestre'.tr} • $disciplinesCount ${'disciplinas'.tr}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (semesters.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Text(
                'semestre_vazio'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                ),
              ),
            )
          else
            ...semesters.map((semester) {
              final expanded = controller.isSemesterExpanded(semester);
              final disciplines = controller.getDisciplinesForSemester(semester);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.16),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: AppColors.appBarTopGradient(),
                          ),
                        ),
                        ExpansionPanelList(
                          elevation: 0,
                          expandedHeaderPadding: EdgeInsets.zero,
                          materialGapSize: 0,
                          expansionCallback: (int index, bool isExpanded) {
                            controller.toggleSemester(semester);
                          },
                          children: [
                            ExpansionPanel(
                              canTapOnHeader: true,
                              backgroundColor: Colors.transparent,
                              headerBuilder: (_, _) => ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 4,
                                ),
                                title: Text(
                                  '${'semestre'.tr} ${_formatYearSemester(semester)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  '${disciplines.length} ${'disciplinas'.tr}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.72),
                                  ),
                                ),
                              ),
                              body: Column(
                                children: disciplines.isEmpty
                                    ? [
                                        ListTile(
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 4,
                                          ),
                                          title: Text(
                                            'semestre_vazio'.tr,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.85),
                                            ),
                                          ),
                                        ),
                                      ]
                                    : disciplines.map((discipline) {
                                        return Column(
                                          children: [
                                            TranscriptDisciplineCard(
                                              discipline: discipline,
                                            ),
                                            Divider(
                                              height: 1,
                                              color: Colors.white.withOpacity(0.08),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                              ),
                              isExpanded: expanded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      title: Text(
        discipline.nome ?? discipline.codigoDisciplina ?? '—',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${'codigo'.tr}: ${discipline.codigoDisciplina ?? '-'} • CH: ${discipline.cargahoraria ?? '-'}',
        style: TextStyle(color: Colors.white.withOpacity(0.72)),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${'nota'.tr}: ${discipline.nota ?? '-'}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            discipline.statusHistorico ?? '',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }
}
