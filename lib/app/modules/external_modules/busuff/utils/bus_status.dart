import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/data/model/busuff_model.dart';

enum BusStatus { moving, stopped, noSignal }

/// Velocidade (m/s) abaixo da qual o ônibus é considerado parado. É o mesmo
/// limite que o marcador usa para trocar a seta pelo quadrado.
const double stoppedSpeedThreshold = 3;

/// Idade máxima da última posição para o ônibus ainda aparecer no mapa. A API
/// é consultada a cada 5 s; 2 min toleram uma falha curta de sinal sem
/// mostrar por muito tempo um ônibus que já saiu de operação.
const Duration maxPositionAge = Duration(minutes: 2);

/// Decide o que o cartão da rota mostra a partir da última posição recebida.
/// [bus] é `null` quando a API nunca devolveu posição para a placa.
BusStatus busStatusOf(BusuffModel? bus, DateTime now) {
  final timestamp = bus?.timestamp;
  if (bus == null ||
      timestamp == null ||
      bus.latitude == null ||
      bus.longitude == null ||
      now.difference(timestamp) > maxPositionAge) {
    return BusStatus.noSignal;
  }
  final speed = bus.speed ?? 0;
  return speed > stoppedSpeedThreshold ? BusStatus.moving : BusStatus.stopped;
}

/// "há 5 s", "há 18 min", "há 2 h". Idades acima de um dia não são mostradas.
String formatElapsed(Duration elapsed) {
  if (elapsed.isNegative) elapsed = Duration.zero;
  if (elapsed.inMinutes < 1) {
    return 'busuff_ha_segundos'.trParams({'n': '${elapsed.inSeconds}'});
  }
  if (elapsed.inHours < 1) {
    return 'busuff_ha_minutos'.trParams({'n': '${elapsed.inMinutes}'});
  }
  return 'busuff_ha_horas'.trParams({'n': '${elapsed.inHours}'});
}
