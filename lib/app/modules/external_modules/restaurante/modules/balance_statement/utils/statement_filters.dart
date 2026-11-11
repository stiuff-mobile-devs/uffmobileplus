import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/controller/balance_statement_controller.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';

/// Filtros do extrato: tipo (Todos / Recargas / Pagamentos) e o chip de
/// período, que abre um pop-up com as opções de dias.
class StatementFilters extends StatelessWidget {
  const StatementFilters({
    super.key,
    required this.type,
    required this.period,
    required this.onTypeChanged,
    required this.onPeriodChanged,
  });

  final StatementFilter type;
  final double period;
  final ValueChanged<StatementFilter> onTypeChanged;
  final ValueChanged<double> onPeriodChanged;

  static final Map<StatementFilter, String> _labels = {
    StatementFilter.all: 'todos',
    StatementFilter.credit: 'recargas',
    StatementFilter.debit: 'pagamentos',
  };

  Future<void> _pickPeriod() async {
    final picked = await AppPopups.choose<double>(
      title: 'ru_periodo_titulo'.tr,
      icon: Icons.date_range,
      selected: period,
      options: [
        for (final days in BalanceStatementController.periodOptions)
          PopupOption<double>(
            value: days,
            label: 'ultimos_dias'.trParams({
              'days': days.toStringAsFixed(0),
            }),
          ),
      ],
    );
    if (picked != null) onPeriodChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final entry in _labels.entries) ...[
              if (entry.key != StatementFilter.all) const SizedBox(width: 8),
              Expanded(
                child: _FilterOption(
                  label: entry.value.tr,
                  isSelected: type == entry.key,
                  onTap: () => onTypeChanged(entry.key),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _pickPeriod,
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue[100],
              minimumSize: const Size(44, 40),
            ),
            icon: const Icon(Icons.date_range, size: 18),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ultimos_dias'.trParams({
                    'days': period.toStringAsFixed(0),
                  }),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xff104389) : Colors.transparent,
      animationDuration: const Duration(milliseconds: 200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? Colors.blue[100]! : Colors.grey[600]!,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : Colors.blue[100],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
