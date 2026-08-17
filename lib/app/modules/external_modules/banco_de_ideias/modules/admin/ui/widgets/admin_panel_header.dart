import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

class AdminPanelHeader extends GetView<BancoDeIdeiasController> {
  const AdminPanelHeader({super.key, required this.email});

  final String? email;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Painel administrativo',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      if (email != null) ...[
        const SizedBox(height: 6),
        Text(
          email!,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
      ],
    ],
  );
}
