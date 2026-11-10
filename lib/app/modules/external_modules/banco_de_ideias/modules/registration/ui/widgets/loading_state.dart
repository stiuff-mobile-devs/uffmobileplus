import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';
import 'package:uffmobileplus/app/ui/widgets/responsive_uff_logo.dart';

class LoadingState extends GetView<BancoDeIdeiasController> {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: const ResponsiveUffLogo(height: 50),
    );
  }
}
