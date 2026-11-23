import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/controller/catraca_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/catraca_app_bar.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/catraca_status_badge.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/cpf_input_formatter.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

/// Liberação manual por CPF, para quando o QR code não pode ser lido.
class ValidarManualmentePage extends GetView<CatracaController> {
  const ValidarManualmentePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      appBar: catracaAppBar(
        title: 'liberar_manualmente'.tr,
        onRefresh: controller.checkConnection,
      ),
      body: const _ManualForm(),
    );
  }
}

class _ManualForm extends StatefulWidget {
  const _ManualForm();

  @override
  State<_ManualForm> createState() => _ManualFormState();
}

class _ManualFormState extends State<_ManualForm> {
  final CatracaController controller = Get.find<CatracaController>();
  final TextEditingController _cpf = TextEditingController();

  String get _digits => CpfInputFormatter.digitsOf(_cpf.text);
  bool get _complete => _digits.length == 11;
  bool _valid = false;

  @override
  void initState() {
    super.initState();
    _cpf.addListener(_onChanged);
  }

  @override
  void dispose() {
    _cpf.dispose();
    super.dispose();
  }

  Future<void> _onChanged() async {
    final valid = _complete && await controller.cpfIsValid(_digits);
    // Rebuilda sempre: o ícone e a borda dependem também de _complete.
    if (mounted) setState(() => _valid = valid);
  }

  Future<void> _submit() async {
    if (!_valid || controller.isManualValidationBusy.value) return;
    FocusScope.of(context).unfocus();
    controller.isManualValidationBusy.value = true;
    try {
      await controller.saveCpfValidationTransaction(_digits);
    } finally {
      controller.isManualValidationBusy.value = false;
    }
    await controller.getResultPage();
  }

  @override
  Widget build(BuildContext context) {
    final showError = _complete && !_valid;
    return Container(
      decoration: BoxDecoration(gradient: AppColors.darkBlueToBlackGradient()),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Row(
                  children: [
                    const CatracaStatusBadge(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        controller.selectedArea.value.nome ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.lightBlue(),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.mediumBlue().withValues(alpha: 0.25),
                    ),
                    child: Icon(
                      Icons.keyboard_rounded,
                      color: AppColors.lightBlue(),
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'catraca_liberacao_cpf'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'catraca_liberacao_cpf_dica'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 32),
                Text(
                  'catraca_cpf_usuario'.tr,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cpf,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [CpfInputFormatter()],
                  onSubmitted: (_) => _submit(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: '000.000.000-00',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: AppColors.alternativeDarkBlue(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    suffixIcon: !_complete
                        ? null
                        : Icon(
                            _valid
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: _valid
                                ? Colors.greenAccent
                                : Colors.redAccent,
                          ),
                    errorText: showError ? 'cpf_invalido_msg'.tr : null,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _valid ? Colors.greenAccent : Colors.white24,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _valid
                            ? Colors.greenAccent
                            : AppColors.lightBlue(),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white54,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'catraca_liberacao_cpf_nota'.tr,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: AppColors.darkBlue(),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Obx(() {
                  final busy = controller.isManualValidationBusy.value;
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1E8E3E),
                        disabledBackgroundColor: Colors.white12,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white38,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: (_valid && !busy) ? _submit : null,
                      icon: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text('catraca_liberar_refeicao'.tr),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
