import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart' as waves;
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:radio_player/radio_player.dart';
import 'package:uffmobileplus/app/modules/external_modules/radio/controller/radio_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class RadioPopGoiabaPage extends StatelessWidget {
  const RadioPopGoiabaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              foregroundColor: Colors.white,
              // TODO: traduzir?
              // TODO: essa string deveria vir de outro lugar?
              title: const Text("Radio Pop Goiaba"),
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
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    AudioWaves(),
                    SizedBox(height: 30),
                    PlayPauseButton(),
                    SizedBox(height: 30),
                    Track()
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
      child: Obx(() => Icon(
        controller.playbackState.value == PlaybackState.playing
        ? Icons.pause
        : Icons.play_arrow,
        color: Colors.white,
        size: 120
      )
      )
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
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white, 
            //fontWeight: FontWeight.bold
          ),
          blankSpace: 100,
        ),
      )
    );
  }
}

class AudioWaves extends GetView<RadioController> {
  const AudioWaves({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      final double width = MediaQuery.of(context).size.width * 0.7;
      const double height = 80;

      // Estado 'tocando', vai mostrar a animação.
      if (controller.playbackState.value.isPlaying) {
        // CORREÇÃO: Usando o prefixo 'waves.'
        return waves.LiveWaveform(
          waveformType: waves.WaveformType.long, 
          waveColor: Colors.white,
          width: width, 
          height: height, 
          maxDuration: const Duration(milliseconds: 500), 
        );
      } else {
        // Se estiver pausado/parado, mostra um placeholder para manter o layout
        return Container(
          height: height, 
          width: width,
        );
      }
    });
  }
}
