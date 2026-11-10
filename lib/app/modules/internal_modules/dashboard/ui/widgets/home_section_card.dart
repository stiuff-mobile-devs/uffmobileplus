import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/ui/widgets/responsive_uff_logo.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

/// Card padrão das seções da Home: cabeçalho (ícone + título + ações) dentro do
/// card e o conteúdo logo abaixo. Todas as seções usam este mesmo molde.
class HomeSectionCard extends StatelessWidget {
  const HomeSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onMenu,
    required this.child,
    this.onTap,
    this.headerAction,
  });

  final IconData icon;
  final String title;

  /// Abre o menu "⋮" da seção (mover / ocultar).
  final VoidCallback onMenu;
  final Widget child;

  /// Toque no card inteiro (ex.: abrir o módulo da seção).
  final VoidCallback? onTap;

  /// Ação extra no cabeçalho, antes do "⋮" (ex.: "Editar" nos atalhos).
  final Widget? headerAction;

  static const double radius = 16;

  static BoxDecoration decoration() => BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    gradient: LinearGradient(
      colors: [
        Colors.white.withValues(alpha: 0.12),
        Colors.white.withValues(alpha: 0.06),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
  );

  /// Texto secundário padrão do corpo das seções.
  static TextStyle get secondaryText =>
      TextStyle(color: Colors.white.withValues(alpha: 0.70), fontSize: 13);

  /// Carregamento padrão do corpo das seções (mesma altura em todas).
  static const Widget loading = SizedBox(
    height: 96,
    child: Center(child: ResponsiveUffLogo(height: 40)),
  );

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue().withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.lightBlue(), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ?headerAction,
              IconButton(
                onPressed: onMenu,
                tooltip: 'opcoes_secao'.tr,
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: child,
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration(),
        child: onTap == null
            ? content
            : InkWell(
                borderRadius: BorderRadius.circular(radius),
                onTap: onTap,
                child: content,
              ),
      ),
    );
  }
}
