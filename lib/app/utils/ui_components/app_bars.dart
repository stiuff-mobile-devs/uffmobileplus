import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';
import 'package:uffmobileplus/app/utils/ui_components/uri_launcher_helper.dart';

/// Ponto único para as AppBars do app. Nunca monte `AppBar(...)` direto nas
/// telas.
///
/// Visual: degradê vertical da marca (azul médio → azul-escuro), cantos
/// inferiores arredondados, título centralizado, texto/ícones brancos e
/// status bar clara. A seta de voltar e o ícone do menu (com drawer) são
/// automáticos; passe `leading` só para comportamentos especiais.
class AppBars {
  AppBars._();

  static const double radius = 16;

  static List<Color> get gradientColors => [
        AppColors.mediumBlue(),
        AppColors.darkBlue(),
      ];

  static PreferredSizeWidget build({
    String? title,
    Widget? titleWidget,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    PreferredSizeWidget? bottom,
  }) {
    assert(title != null || titleWidget != null);
    final bool isTablet = Get.width >= 600;

    return _GradientAppBar(
      title: title,
      titleWidget: titleWidget,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: bottom,
      isTablet: isTablet,
      toolbarHeight: isTablet ? 64.0 : 56.0,
    );
  }

  /// Botão de ajuda padrão. Com [url], abre o guia online; sem URL, avisa que
  /// o manual ainda está sendo preparado. As URLs ficam em `HelpGuides`.
  static Widget helpAction(String? url) {
    return IconButton(
      tooltip: 'ajuda'.tr,
      icon: const Icon(Icons.help_outline_rounded),
      onPressed: () {
        if (url == null || url.trim().isEmpty) {
          AppPopups.info('manual_guias_em_construcao'.tr);
        } else {
          openUrl(url);
        }
      },
    );
  }
}

class _GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _GradientAppBar({
    required this.title,
    required this.titleWidget,
    required this.actions,
    required this.leading,
    required this.automaticallyImplyLeading,
    required this.bottom,
    required this.isTablet,
    required this.toolbarHeight,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final bool isTablet;
  final double toolbarHeight;

  static const Color _foreground = Colors.white;

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final double titleSize = isTablet ? 20 : 18;
    const double iconSize = 24;

    return AppBar(
      title: titleWidget ??
          Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis),
      titleTextStyle: TextStyle(
        color: _foreground,
        fontSize: titleSize,
        fontWeight: FontWeight.w600,
      ),
      centerTitle: true,
      leading: leading ?? _defaultLeading(context, iconSize),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      bottom: bottom,
      toolbarHeight: toolbarHeight,
      foregroundColor: _foreground,
      iconTheme: const IconThemeData(color: _foreground, size: iconSize),
      actionsIconTheme: const IconThemeData(color: _foreground, size: iconSize),
      backgroundColor: Colors.transparent, // o fundo é o degradê
      surfaceTintColor: Colors.transparent, // evita a tinta do Material 3
      elevation: 3,
      scrolledUnderElevation: 3,
      shadowColor: Colors.black54,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      clipBehavior: Clip.antiAlias, // sem isso o degradê vaza dos cantos
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppBars.radius),
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppBars.gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  // Seta de voltar padronizada. Com drawer, deixa o AppBar mostrar o menu.
  Widget? _defaultLeading(BuildContext context, double iconSize) {
    if (!automaticallyImplyLeading) return null;
    if (Scaffold.maybeOf(context)?.hasDrawer ?? false) return null;
    if (!(ModalRoute.of(context)?.canPop ?? false)) return null;

    return IconButton(
      tooltip: 'voltar'.tr,
      icon: Icon(Icons.arrow_back_rounded, size: iconSize),
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }
}
