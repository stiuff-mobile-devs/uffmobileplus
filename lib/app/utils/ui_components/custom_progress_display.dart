import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class CustomProgressDisplay extends StatelessWidget {
  const CustomProgressDisplay({
    super.key,
    this.height = 50.0,
    this.brightMode = false,
  });

  final double height;
  final bool brightMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.darkBlueToBlackGradient()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SizedBox(
            height: height,
            child: RiveAnimation.asset(
              brightMode
                  ? "assets/animations/logo_uff_animado_white.riv"
                  : "assets/animations/logo_uff_animado.riv",
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }
}
