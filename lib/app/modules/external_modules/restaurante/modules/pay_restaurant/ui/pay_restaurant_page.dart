import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/controller/pay_restaurant_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/card_details.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/meal_prices.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

/// Tela "Pagar RU": cartão no topo, painel com saldo/refeições/valor e as
/// ações (gerar código, ajuda) no rodapé.
class PayRestaurantPage extends GetView<PayRestaurantController> {
  const PayRestaurantPage({super.key});

  static const double _maxContentWidth = 420;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      appBar: AppBars.build(
        title: 'pagar_restaurante'.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'atualizar'.tr,
            onPressed: controller.reloadData,
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CustomProgressDisplay())
            : Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.darkBlueToBlackGradient(),
                ),
                child: SafeArea(
                  top: false,
                  child: LayoutBuilder(
                    // Rola em telas baixas; em telas altas o rodapé desce
                    // até o fim (Spacer dentro de IntrinsicHeight).
                    builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: _maxContentWidth,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  8,
                                ),
                                child: _content(constraints.maxWidth),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _content(double screenWidth) {
    final available =
        (screenWidth < _maxContentWidth ? screenWidth : _maxContentWidth) - 32;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: IdCard(
            userImageUrl: controller.userImageUrl,
            username: controller.userName,
            iduff: controller.userIdUFF,
            width: available < IdCard.baseWidth ? available : null,
          ),
        ),
        // Spacers iguais acima e abaixo: o painel fica no centro do espaço
        // entre o cartão e o rodapé.
        const Spacer(),
        const SizedBox(height: 16),
        _BalancePanel(controller: controller),
        const SizedBox(height: 16),
        Text(
          'valor_nao_debitado_se_nao_utilizado'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.0,
            color: Colors.blue[200],
            fontStyle: FontStyle.italic,
          ),
        ),
        const Spacer(),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mediumBlue(),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: controller.goToPaymentTicket,
            icon: const Icon(Icons.qr_code_2, size: 26),
            label: Text(
              'gerar_codigo'.tr,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: controller.goToPaymentHelpScreen,
          icon: Icon(Icons.help_outline, color: Colors.blue[100], size: 20),
          label: Text(
            'como_utilizar_codigo'.tr,
            style: TextStyle(color: Colors.blue[100]),
          ),
        ),
      ],
    );
  }
}

/// Painel único: saldo e refeições lado a lado, valor da refeição (tocável,
/// abre a tabela) e o atalho para recarga.
class _BalancePanel extends StatelessWidget {
  final PayRestaurantController controller;

  const _BalancePanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final balance = controller.balanceValue;
    final price = controller.mealPrice;
    final meals = controller.mealsAvailable;
    final insufficient = controller.isBalanceInsufficient;
    final profileKey = MealPrices.profileLabelKey(controller.profileType.value);

    String? status;
    Color statusColor = Colors.red[300]!;
    if (balance == null) {
      status = 'erro_saldo'.tr;
    } else if (price == null) {
      status = 'perfil_sem_refeicao'.tr;
      statusColor = Colors.blue[100]!;
    } else if (insufficient) {
      status = 'recarregue_para_usar_bandejao'.tr;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Metric(
                        label: 'saldo_atual'.tr,
                        value: balance == null
                            ? '—'
                            : 'R\$ ${MealPrices.format(balance)}',
                        valueColor: insufficient
                            ? Colors.red[300]!
                            : Colors.white,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    Expanded(
                      child: _Metric(
                        label: 'ru_refeicoes'.tr,
                        value: meals == null ? '—' : '$meals',
                        valueColor: (meals ?? 0) > 0
                            ? Colors.green[300]!
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
                if (status != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: statusColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 14,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showPriceTable(price),
              borderRadius: controller.showRechargeButton
                  ? BorderRadius.zero
                  : const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Icon(Icons.restaurant, color: Colors.blue[100], size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'valor_refeicao'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[100],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              price == null
                                  ? '—'
                                  : 'R\$ ${MealPrices.format(price)}',
                              if (profileKey != null) profileKey.tr,
                            ].join('  ·  '),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.blue[100],
                      size: 26,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (controller.showRechargeButton)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: OutlinedButton.icon(
                onPressed: controller.goToRecharge,
                icon: const Icon(Icons.add_card),
                label: Text('ru_recarregar'.tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  textStyle: const TextStyle(fontSize: 16),
                  side: BorderSide(color: Colors.green[300]!, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _Metric({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.blue[100])),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Folha com a tabela de valores, o grupo do usuário destacado e o aviso de
/// que os valores são apenas informativos.
void _showPriceTable(double? userPrice) {
  AppPopups.sheet(
    title: 'valor_refeicao_titulo'.tr,
    message: 'valor_refeicao_desc'.tr,
    icon: Icons.restaurant,
    child: Builder(
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _PriceGroup(
              price: MealPrices.student,
              categories: MealPrices.studentCategories,
              highlighted: userPrice == MealPrices.student,
            ),
            const SizedBox(height: 12),
            _PriceGroup(
              price: MealPrices.staff,
              categories: MealPrices.staffCategories,
              highlighted: userPrice == MealPrices.staff,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'valor_refeicao_aviso'.tr,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
    actions: (ctx) => [
      AppSheetButton.primary(
        label: 'ok'.tr,
        onPressed: () => Navigator.of(ctx).pop(),
      ),
    ],
  );
}

class _PriceGroup extends StatelessWidget {
  final double price;
  final List<String> categories;
  final bool highlighted;

  const _PriceGroup({
    required this.price,
    required this.categories,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted
            ? scheme.primary.withValues(alpha: 0.18)
            : scheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? scheme.primary
              : scheme.onSurface.withValues(alpha: 0.12),
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'R\$ ${MealPrices.format(price)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const Spacer(),
              if (highlighted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'seu_valor'.tr,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (final key in categories)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '•  ${key.tr}',
                style: TextStyle(
                  fontSize: 14,
                  color: scheme.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
