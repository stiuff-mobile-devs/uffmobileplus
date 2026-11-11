/// URLs dos guias de ajuda das telas do módulo Restaurante, passadas a
/// `AppBars.helpAction(url)`.
///
/// Ficam aqui (e não em `lib/app/utils/help_guides.dart`) para o kit de UI
/// compartilhado não conhecer módulos externos. Enquanto a URL for `null`, o
/// botão avisa que o manual está em construção.
class RestauranteHelp {
  RestauranteHelp._();

  /// Tela inicial do Restaurante (lista de submódulos).
  static const String? modulos = null;
}
