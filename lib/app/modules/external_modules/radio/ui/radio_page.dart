import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:radio_player/radio_player.dart';
import 'package:siri_wave/siri_wave.dart';
import 'package:uffmobileplus/app/modules/external_modules/radio/controller/radio_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class Radio extends StatelessWidget {
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

class PlayPauseButton extends StatefulWidget {
  const PlayPauseButton({super.key});

  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

// Classe State
class _PlayPauseButtonState extends State<PlayPauseButton> {
  // Encontra o RadioController
  final RadioController controller = Get.find<RadioController>();

  // 1. Inicializa o Controller do Siri Wave
  final IOS9SiriWaveformController siriController = IOS9SiriWaveformController(
    amplitude: 0.0, // Começa parado
    speed: 0.20,
    // Cores:
    color1: Colors.cyanAccent.withOpacity(0.8),
    color2: Colors.blueAccent.withOpacity(0.8),
    color3: Colors.white.withOpacity(0.8),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.toggleState(),

      child: Obx(() {
        final isPlaying =
            controller.playbackState.value == PlaybackState.playing;

        // 2. Controla a amplitude: 0.8 quando estiver tocando, 0.0 quando pausado.
        // Faz a animação parar.
        siriController.amplitude = isPlaying ? 0.8 : 0.0;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isPlaying
              ? // Se estiver tocando, mostra o Siri Wave
                SizedBox(
                  key: const ValueKey('wave'),
                  width: 120,
                  height: 120,
                  child: SiriWaveform.ios9(
                    controller: siriController,
                    options: const IOS9SiriWaveformOptions(
                      height: 120,
                      width: 120,
                    ),
                  ),
                )
              : // Se não estiver tocando, mostra o icone play
                Icon(
                  Icons.play_arrow,
                  key: const ValueKey('play'),
                  color: Colors.white,
                  size: 120,
                ),
        );
      }),
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
