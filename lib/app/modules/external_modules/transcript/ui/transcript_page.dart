import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/transcript/controller/transcript_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class TranscriptPage extends StatelessWidget {
  const TranscriptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient()
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              foregroundColor: Colors.white,
              title: Text("Histórico"),
              centerTitle: true,
              elevation: 8,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () {}, 
                  icon: const Icon(Icons.question_mark)
                ),
              ],
            ),
            SliverExpasionPanelList()
          ],
        ),
      ),
    );
  }
}

class CustomCircularProgressIndicator extends GetView<TranscriptController> {
  const CustomCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3.5,
          ),
        ),
      ),
    );
  }
}

class SliverExpasionPanelList extends GetView<TranscriptController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() =>
      SliverToBoxAdapter(
        child: controller.isLoading.value
          ? CustomCircularProgressIndicator()
          : //Text("${controller.getTranscript().toJson()['cr']}")
          SemesterExpansionPanelList()
      ),
    );
  }
}

class SemesterExpansionPanelList extends GetView<TranscriptController> {
  const SemesterExpansionPanelList({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        // You may want to handle expansion state here
        // TODO: talvez criar um controller para isso
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                "${controller.getTranscript().toJson()['disciplinas'][0]['anosemestre']}"
              )
            );
          }, 
          body: Placeholder(),
          // TODO: o 
          isExpanded: false,
        ),
      ],
    );
  }
}