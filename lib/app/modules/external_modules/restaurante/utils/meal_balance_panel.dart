import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_prices.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';

/// Painel do RU com saldo e refeições lado a lado, o valor da refeição do
/// perfil (tocável: abre a tabela de valores) e, se [onRecharge] for
/// informado, o atalho para recarga. Usado em Pagar e Recarga.
class MealBalancePanel extends StatelessWidget {
  /// Saldo atual; `null` quando não foi possível carregar.
  final double? balance;

  /// Valor da refeição do perfil; `null` quando o perfil não come no RU.
  final double? price;

  /// Chave de tradução do perfil (ver [MealPrices.profileLabelKey]).
  final String? profileKey;

  /// Saldo ainda carregando: mostra "…" no lugar dos números.
  final bool isLoading;

  /// Mostra o botão "Recarregar cartão" quando informado.
  final VoidCallback? onRecharge;

  const MealBalancePanel({
    super.key,
    required this.balance,
    required this.price,
    required this.profileKey,
    this.isLoading = false,
    this.onRecharge,
  });

  @override
  Widget build(BuildContext context) {
    final meals = MealPrices.mealsFor(balance, price);
    final insufficient = MealPrices.isInsufficient(balance, price);

    String? status;
    Color statusColor = Colors.red[300]!;
    if (isLoading) {
      status = null;
    } else if (balance == null) {
      status = 'erro_saldo'.tr;
    } else if (price == null) {
      status = 'perfil_sem_refeicao'.tr;
      statusColor = Colors.blue[100]!;
    } else if (insufficient) {
      status = 'recarregue_para_usar_bandejao'.tr;
    }

    final balanceText = isLoading
        ? '…'
        : balance == null
            ? '—'
            : 'R\$ ${MealPrices.format(balance!)}';
    final mealsText = isLoading ? '…' : (meals == null ? '—' : '$meals');

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
                        value: balanceText,
                        valueColor: !isLoading && insufficient
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
                        value: mealsText,
                        valueColor: !isLoading && (meals ?? 0) > 0
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
              onTap: () => showMealPriceTable(price),
              borderRadius: onRecharge != null
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
                                  : 'R\$ ${MealPrices.format(price!)}',
                              if (profileKey != null) profileKey!.tr,
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
          if (onRecharge != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: OutlinedButton.icon(
                onPressed: onRecharge,
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

/// Folha com a tabela de valores do RU, o grupo de [userPrice] destacado e o
/// aviso de que os valores são apenas informativos.
void showMealPriceTable(double? userPrice) {
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
