import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/constants.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';

/// Diálogos do pagamento/recarga do RU. Mantém a assinatura antiga (os
/// controllers continuam chamando estes métodos), mas o visual agora é o
/// padrão do app (`AppPopups`).
class MessageDialogs {
  /// [title] diz o que aconteceu; [message] diz o que fazer (padrão: tentar
  /// de novo). O `context` é ignorado e mantido só por compatibilidade.
  static Future<void> showErrorDialog<T>(
    Object? context, {
    String? message,
    String? title,
  }) async {
    await AppPopups.alert(
      title: title ?? 'nao_foi_possivel_concluir'.tr,
      message: message ?? Constants.DEFAULT_API_ERROR,
      type: PopupType.error,
      confirmText: 'ok'.tr,
    );
  }

  static Future<void> showMessageDialog<T>(
    Object? context, {
    required String message,
  }) async {
    await AppPopups.alert(
      title: message,
      type: PopupType.info,
      confirmText: 'ok'.tr,
    );
  }
}
