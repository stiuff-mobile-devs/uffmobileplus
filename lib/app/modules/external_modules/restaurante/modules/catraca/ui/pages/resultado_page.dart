import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/controller/catraca_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/catraca_validation_result.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/catraca_app_bar.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/catraca_bottom_actions.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/catraca_status_badge.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

/// Resultado logo após validar (QR code ou manual): a tela inteira na cor do
/// resultado, para o operador enxergar de longe.
class ResultadoPage extends GetView<CatracaController> {
  const ResultadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final result = controller.lastResult.value;
      final look = _ResultLook.of(result);
      return Scaffold(
        backgroundColor: look.color,
        appBar: catracaAppBar(
          title: 'resultado'.tr,
          onRefresh: controller.checkConnection,
        ),
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [look.color, Color.lerp(look.color, Colors.black, 0.35)!],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      const CatracaStatusBadge(),
                      const SizedBox(height: 24),
                      Icon(look.icon, size: 140, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        look.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      if (_name(result) != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _name(result)!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (look.subtitle != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          look.subtitle!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                      if (result?.sctmMessage != null) ...[
                        const SizedBox(height: 16),
                        _SctmNote(message: result!.sctmMessage!),
                      ],
                      if (result?.item != null) ...[
                        const SizedBox(height: 24),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () =>
                              controller.goToDetalhado(result!.item!),
                          icon: const Icon(Icons.keyboard_arrow_up_rounded),
                          label: Text('catraca_ver_detalhes'.tr),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: Color.lerp(look.color, Colors.black, 0.35),
          child: CatracaBottomActions(
            accent: look.color,
            manualLabel: 'catraca_manual'.tr,
            scanLabel: 'catraca_ler_proximo'.tr,
          ),
        ),
      );
    });
  }

  String? _name(CatracaValidationResult? result) {
    final fromItem = result?.item?.displayName;
    if (fromItem != null && fromItem != '-') return fromItem;
    final name = result?.name;
    return (name == null || name.trim().isEmpty) ? null : name.trim();
  }
}

class _ResultLook {
  const _ResultLook(this.color, this.icon, this.title, this.subtitle);

  final Color color;
  final IconData icon;
  final String title;
  final String? subtitle;

  static const Color _green = Color(0xFF1E8E3E);
  static const Color _amber = Color(0xFFE08A00);
  static const Color _red = Color(0xFFC62828);

  static _ResultLook of(CatracaValidationResult? r) {
    if (r == null) {
      return _ResultLook(
        AppColors.darkBlue(),
        Icons.hourglass_empty_rounded,
        'catraca_sem_resultado'.tr,
        null,
      );
    }
    switch (r.kind) {
      case CatracaResultKind.approvedSctm:
        final value = r.item?.value;
        return _ResultLook(
          _green,
          Icons.check_circle_rounded,
          'catraca_liberado'.tr,
          (value != null && value.isNotEmpty)
              ? 'catraca_via_sctm_valor'.trParams({'valor': value})
              : 'catraca_via_sctm'.tr,
        );
      case CatracaResultKind.savedOffline:
        return _ResultLook(
          _amber,
          Icons.cloud_done_rounded,
          'catraca_liberado_offline'.tr,
          'catraca_salva_no_aparelho_firebase'.tr,
        );
      case CatracaResultKind.duplicate:
        return _ResultLook(
          _red,
          Icons.replay_circle_filled_rounded,
          'catraca_ja_registrado'.tr,
          'catraca_ja_passou_turno'.tr,
        );
      case CatracaResultKind.rejected:
        return _ResultLook(
          _red,
          Icons.cancel_rounded,
          'catraca_recusado'.tr,
          r.message,
        );
      case CatracaResultKind.invalidCode:
        return _ResultLook(
          _red,
          Icons.qr_code_2_rounded,
          'catraca_qr_invalido'.tr,
          'catraca_qr_invalido_dica'.tr,
        );
      case CatracaResultKind.error:
        return _ResultLook(
          _red,
          Icons.error_rounded,
          'catraca_erro'.tr,
          r.message,
        );
    }
  }
}

/// Avisa que o SCTM recusou antes de a refeição seguir para o offline.
class _SctmNote extends StatelessWidget {
  const _SctmNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'catraca_sctm_recusou'.trParams({'mensagem': message}),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
