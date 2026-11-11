import 'dart:async';

import 'package:flutter/material.dart';

/// Cor do "modo simulação" do RU: o usuário está vendo um valor de refeição
/// diferente do valor do próprio perfil. Âmbar para não confundir com erro
/// (vermelho) nem com o estado normal (azul).
const Color kMealSimulationColor = Color(0xFFF5B942);

/// Moldura do painel/grade do RU: borda âmbar enquanto [isSimulating] e um
/// brilho rápido sempre que [flashKey] (o valor selecionado) muda.
class MealSimulationFrame extends StatefulWidget {
  final Widget child;
  final bool isSimulating;
  final Object? flashKey;
  final double radius;
  final Color background;

  /// Mostra a borda clara fora da simulação (no painel sim; na grade da
  /// recarga não, para manter o visual de antes).
  final bool showIdleBorder;

  const MealSimulationFrame({
    super.key,
    required this.child,
    required this.isSimulating,
    required this.flashKey,
    this.radius = 16,
    this.background = Colors.transparent,
    this.showIdleBorder = true,
  });

  @override
  State<MealSimulationFrame> createState() => _MealSimulationFrameState();
}

class _MealSimulationFrameState extends State<MealSimulationFrame> {
  static const Duration _flashDuration = Duration(milliseconds: 700);

  bool _flash = false;
  Timer? _timer;

  @override
  void didUpdateWidget(covariant MealSimulationFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flashKey != widget.flashKey) {
      _timer?.cancel();
      setState(() => _flash = true);
      _timer = Timer(_flashDuration, () {
        if (mounted) setState(() => _flash = false);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final simulating = widget.isSimulating;
    final glowColor = simulating
        ? kMealSimulationColor.withValues(alpha: 0.35)
        : Colors.blue[100]!.withValues(alpha: 0.30);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: widget.background,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(
          color: simulating
              ? kMealSimulationColor.withValues(alpha: 0.7)
              : Colors.white.withValues(
                  alpha: widget.showIdleBorder ? 0.15 : 0,
                ),
          width: simulating ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _flash ? glowColor : glowColor.withValues(alpha: 0),
            spreadRadius: _flash ? 4 : 0,
          ),
        ],
      ),
      child: widget.child,
    );
  }
}
