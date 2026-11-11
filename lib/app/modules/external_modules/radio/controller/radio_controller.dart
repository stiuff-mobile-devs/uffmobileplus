import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radio_player/radio_player.dart';
import 'package:siri_wave/siri_wave.dart';

/// Player da Rádio Pop Goiaba, compartilhado entre o card da Home e a tela
/// da rádio (registrado como permanente na `DashboardBinding`).
///
/// O player nativo (sessão de mídia + notificação do sistema) só é criado
/// quando o usuário toca em play, e é encerrado ao parar ou fechar o app.
/// Qualquer chamada ao plugin cria a sessão no Android, por isso nada é
/// chamado no `onInit`.
class RadioController extends GetxController with WidgetsBindingObserver {
  static const String _stationTitle = 'Rádio Pop Goiaba';
  static const String _stationUrl = 'https://s37.maxcast.com.br:8450/live';

  final Rx<PlaybackState> playbackState = PlaybackState.paused.obs;
  set playbackState(PlaybackState value) => playbackState.value = value;

  final metadata = _defaultMetadata().obs;
  set metadata(Metadata value) => metadata.value = value;

  StreamSubscription? _playbackStateSubscription;
  StreamSubscription? _metadataSubscription;

  /// A estação já foi configurada no player nativo (sessão criada).
  bool _stationReady = false;

  /// Evita dois toques seguidos disparando chamadas sobrepostas.
  bool _busy = false;

  final IOS9SiriWaveformController siriController = IOS9SiriWaveformController(
    amplitude: 1.0,
    speed: 0.20,
    color1: Colors.cyanAccent.withValues(),
    color2: Colors.blueAccent.withValues(),
    color3: Colors.white.withValues(),
  );

  static Metadata _defaultMetadata() => Metadata(
        artist: 'radio_artista_desconhecido'.tr,
        title: 'radio_faixa_desconhecida'.tr,
      );

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // Só escuta os eventos (EventChannel); não cria a sessão de mídia.
    _playbackStateSubscription = RadioPlayer.playbackStateStream.listen((
      state,
    ) {
      // Depois de parar, ignora eventos atrasados do player antigo.
      if (_stationReady) playbackState.value = state;
    });

    _metadataSubscription = RadioPlayer.metadataStream.listen((data) {
      if (_stationReady) metadata.value = data;
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _playbackStateSubscription?.cancel();
    _metadataSubscription?.cancel();
    stop();
    super.onClose();
  }

  /// Fechar o app encerra o player e remove a notificação.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) stop();
  }

  /// Play/parar do card da Home e da tela da rádio.
  Future<void> toggleState() async {
    if (_busy) return;
    _busy = true;
    try {
      final current = playbackState.value;
      if (current.isPlaying || current.isBuffering) {
        await stop();
      } else {
        await _play();
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> _play() async {
    try {
      if (!_stationReady) {
        await RadioPlayer.setStation(title: _stationTitle, url: _stationUrl);
        _stationReady = true;
      }
      playbackState.value = PlaybackState.buffering;
      await RadioPlayer.play();
    } catch (e) {
      debugPrint('Erro ao tocar a rádio: $e');
      await stop();
    }
  }

  /// Para a rádio e encerra o player nativo (some da notificação).
  Future<void> stop() async {
    final hadSession = _stationReady;
    _stationReady = false;
    playbackState.value = PlaybackState.paused;
    metadata.value = _defaultMetadata();
    if (!hadSession) return;
    try {
      await RadioPlayer.reset();
    } catch (e) {
      debugPrint('Erro ao encerrar o player da rádio: $e');
    }
  }

  String showMetadata() {
    String song;
    String artist;

    song = (metadata.value.title != null) ? "${metadata.value.title}" : "";

    artist = (metadata.value.artist != null)
        ? " - ${metadata.value.artist}"
        : "";

    return song + artist;
  }
}
