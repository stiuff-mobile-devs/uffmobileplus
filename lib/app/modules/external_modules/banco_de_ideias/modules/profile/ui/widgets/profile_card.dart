import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/usuario_atual.dart';
import 'profile_field.dart';

class ProfileCard extends GetView<BancoDeIdeiasController> {
  const ProfileCard({super.key, required this.usuario});

  final UsuarioAtual usuario;

  @override
  Widget build(BuildContext context) {
    final raw = usuario.raw;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileTitle(nome: raw['nome']?.toString() ?? '(sem nome)'),
            const SizedBox(height: 18),
            ProfileField(label: 'Email', value: raw['email']?.toString() ?? ''),
            ProfileField(label: 'Perfil', value: _nomeDe(raw['perfil'])),
            ProfileField(label: 'Curso', value: _nomeDe(raw['curso'])),
            ProfileField(
              label: 'Departamento',
              value: _nomeDe(raw['departamento']),
            ),
          ],
        ),
      ),
    );
  }

  String _nomeDe(dynamic value) =>
      value is Map ? value['nome']?.toString() ?? '' : '';
}

class _ProfileTitle extends GetView<BancoDeIdeiasController> {
  const _ProfileTitle({required this.nome});
  final String nome;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const CircleAvatar(radius: 28, child: Icon(Icons.person_rounded)),
      const SizedBox(width: 16),
      Expanded(
        child: Text(
          nome,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
    ],
  );
}
