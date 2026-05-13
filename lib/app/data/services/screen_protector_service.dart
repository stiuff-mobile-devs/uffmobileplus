import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';

class ScreenProtectorService {
   void enableScreenProtection() async {
    // No Android, isso ativa a FLAG_SECURE imediatamente
    // No iOS, prepara o sistema para esconder conteúdo sensível
    await ScreenProtector.preventScreenshotOn();
    await ScreenProtector.protectDataLeakageWithBlur();
      debugPrint("Proteção de tela ATIVADA");
  }

  /// Desativa a proteção de tela
  void disableScreenProtection() async {
    await ScreenProtector.preventScreenshotOff();
    debugPrint("Proteção de tela DESATIVADA");
  }
}