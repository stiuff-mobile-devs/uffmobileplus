
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:radio_player/radio_player.dart';

class RadioController extends GetxController {
  final Rx<PlaybackState> playbackState = PlaybackState.paused.obs;
  set playbackState(value) => playbackState.value = value;

  final metadata = Metadata(artist: 'Unknown song', title: 'Unknown artist').obs;
  set metadata(value) => metadata.value = value;

  StreamSubscription? _playbackStateSubscription;
  StreamSubscription? _metadataSubscription;

  // Initializes the plugin and starts listening to streams.
  @override
  void onInit() {
    super.onInit();

    // Protege TODAS as chamadas de inicialização do plugin
    if (!kIsWeb) {
      // Set the initial radio station.
      RadioPlayer.setStation(
        title: 'Radio Player',
        url: 'https://s37.maxcast.com.br:8450/live',
      );

      RadioPlayer.metadataStream.listen(
        (metadata) {
          this.metadata = metadata;
        }
      );

      // Listen to playback state changes.
      _playbackStateSubscription = RadioPlayer.playbackStateStream.listen(
        (playbackState) {
          this.playbackState = playbackState;
        }
      );

      // Listen to metadata changes.
      _metadataSubscription = RadioPlayer.metadataStream.listen(
       (metadata) {
         this.metadata = metadata;
       }
      );
    }
  }

  /// Disposes of stream subscriptions.
  @override
  void dispose() {
    // Esta lógica de cancelamento é puramente Dart e funciona em todas as plataformas
    _playbackStateSubscription?.cancel();
    _metadataSubscription?.cancel();
    super.dispose();
  }

  @override
  void onClose() {
    // Protege o comando do plugin, mas executa o `super` sempre
    if (!kIsWeb) {
      RadioPlayer.reset();
    }
    super.onClose();
  }

  void toggleState() {
    // 1. Lógica do GetX/UI: Atualiza o estado visualmente em todas as plataformas
    if (playbackState.value.isPlaying) {
      playbackState.value = PlaybackState.paused;
    } else {
      playbackState.value = PlaybackState.playing;
    }

    // 2. Lógica do Plugin: Executa comandos de áudio SOMENTE no Mobile
    if (!kIsWeb) {
      if (playbackState.value.isPaused) {
        RadioPlayer.pause();
      } else {
        RadioPlayer.play();
      }
    }
  }

  String showMetadata() {
    String song;
    String artist;

    song = (metadata.value.title != null)
      ? "${metadata.value.title}"
      : "";
    
    artist = (metadata.value.artist != null)
      ? " - ${metadata.value.artist}"
      : "";

    return song + artist;
  }
}