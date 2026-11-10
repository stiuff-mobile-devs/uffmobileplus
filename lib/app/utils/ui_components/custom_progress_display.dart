import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/ui/widgets/responsive_uff_logo.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

/// Carregamento padrão do app: o mesmo logo UFF branco "flutuando" do splash,
/// sobre o degradê escuro (garante contraste do logo).
class CustomProgressDisplay extends StatelessWidget {
  const CustomProgressDisplay({
    super.key,
    this.height = 50.0,
    this.brightMode = false,
  });

  final double height;

  /// Mantido só por compatibilidade com quem já passa o parâmetro: o logo é
  /// sempre branco.
  final bool brightMode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.darkBlueToBlackGradient()),
      child: Center(
        child: ResponsiveUffLogo(height: height > 0 ? height : 60),
      ),
    );
  }
}
