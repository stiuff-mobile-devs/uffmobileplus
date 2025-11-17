import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:siri_wave/siri_wave.dart';
import 'package:radio_player/radio_player.dart';
import 'package:uffmobileplus/app/modules/external_modules/radio/controller/radio_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class Radio extends GetView<RadioController> {
  const Radio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: (MediaQuery.sizeOf(context).height),
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              foregroundColor: Colors.white,
              // TODO: traduzir?
              // TODO: essa string deveria vir de outro lugar?
              title: Text("Radio Pop Goiaba"),
              centerTitle: true,
              elevation: 8,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.appBarTopGradient(),
                ),
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.question_mark),
                ),
              ],
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Logo(),
                    PlayPauseButton(),
                    Track(),
                    About(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlayPauseButton extends GetView<RadioController> {
  const PlayPauseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.toggleState(),
      child: Center(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: (MediaQuery.sizeOf(context).width) * 0.65,
                  height: (MediaQuery.sizeOf(context).height) * 0.35,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/radio/images/pop-goiaba_3_sf.png',
                      ),
                      fit: BoxFit.cover,
                      opacity: 0.4,
                    ),
                  ),
                ),
                Obx(
                  () => Icon(
                    controller.playbackState.value == PlaybackState.playing
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 120,
                  ),
                ),
              ],
            ),
            SiriAnimation(),
          ],
        ),
      ),
    );
  }
}

class Track extends GetView<RadioController> {
  const Track({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        height: 100,
        child: Marquee(
          text: controller.showMetadata(),
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            //fontWeight: FontWeight.bold
          ),
          blankSpace: 100,
        ),
      ),
    );
  }
}

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.sizeOf(context).width) * 0.93,
      alignment: Alignment.bottomCenter,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Sobre',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            'A Rádio Pop Goiaba/UFF, é um projeto de extensão da Universidade Fluminense, vinculada ao NUFEP - Núcleo Fluminense de Estudos e Pesquisas da UFF que é coordenado pelo professor Roberto Kant de Lima.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Image.asset(
        'assets/radio/images/Logo-PopGoiaba.png',
        height: (MediaQuery.sizeOf(context).height) * 0.125,
      ),
    );
  }
}

class SiriAnimation extends GetView<RadioController> {
  const SiriAnimation({super.key});

  @override
  Widget build(BuildContext context){
    return Obx(() {

      final isPlaying = controller.playbackState.value == PlaybackState.playing;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isPlaying
            ? 
              SizedBox(
                key: const ValueKey('wave'),
                width: (MediaQuery.sizeOf(context).width) * 0.50,
                height: 120,
                child: SiriWaveform.ios9(
                  controller: controller.siriController,
                  options: IOS9SiriWaveformOptions(
                    height: 120,
                    width: 120,
                  ),
                ),
              )
            : 
              Container(),
        );
      }
    );
  }
}
