import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/card_transaction.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/utils/constants.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_prices.dart';

/// Lista do extrato agrupada por dia (Hoje, Ontem, dd/MM/yyyy). Puxar para
/// baixo atualiza.
class StatementList extends StatelessWidget {
  const StatementList({
    super.key,
    required this.statement,
    required this.period,
    required this.hasError,
    required this.onRefresh,
  });

  final List<CardTransaction> statement;
  final double period;
  final bool hasError;
  final Future<void> Function() onRefresh;

  /// Itens com data, do mais recente ao mais antigo, agrupados por dia.
  List<_Entry> _entries() {
    final sorted = statement.where((t) => t.date != null).toList()
      ..sort((a, b) => b.date!.compareTo(a.date!));
    final undated = statement.where((t) => t.date == null);

    final entries = <_Entry>[];
    DateTime? currentDay;
    for (final t in sorted) {
      final local = t.date!.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      if (day != currentDay) {
        currentDay = day;
        entries.add(_Entry.header(_dayLabel(day)));
      }
      entries.add(_Entry.item(t));
    }
    for (final t in undated) {
      entries.add(_Entry.item(t));
    }
    return entries;
  }

  static String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return 'hoje'.tr;
    if (day == today.subtract(const Duration(days: 1))) return 'ontem'.tr;
    return DateFormat('dd/MM/yyyy').format(day);
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries();

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: entries.isEmpty
          ? _EmptyState(
              // ListView para o "puxar para atualizar" funcionar vazio também
              message: hasError
                  ? 'erro_obter_dados_tente_novamente'.tr
                  : 'sem_info_ultimos_dias'.trParams({
                      'period': period.toStringAsFixed(0),
                    }),
              icon: hasError ? Icons.cloud_off : Icons.receipt_long,
              onRetry: hasError ? onRefresh : null,
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return entry.header != null
                    ? _DayHeader(entry.header!)
                    : _TransactionTile(entry.transaction!);
              },
            ),
    );
  }
}

class _Entry {
  final String? header;
  final CardTransaction? transaction;

  _Entry.header(this.header) : transaction = null;
  _Entry.item(this.transaction) : header = null;
}

class _DayHeader extends StatelessWidget {
  const _DayHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.blue[100],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile(this.transaction);

  final CardTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isDebit = transaction.category?.contains(Constants.DEBIT) ?? false;
    final color = isDebit ? Colors.red[300]! : Colors.green[300]!;

    final raw = transaction.value ?? '';
    final parsed = MealPrices.parseBalance(raw);
    final amount = parsed == null ? raw : MealPrices.format(parsed.abs());
    final sign = isDebit ? '−' : '+';

    final date = transaction.date?.toLocal();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDebit ? Icons.restaurant : Icons.add_card,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('HH:mm').format(date),
                    style: TextStyle(fontSize: 13, color: Colors.blue[100]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$sign R\$ $amount',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.icon, this.onRetry});

  final String message;
  final IconData icon;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 48, color: Colors.blue[100]),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.blue[100]),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: Text('atualizar'.tr),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size(44, 44),
                        side: BorderSide(color: Colors.blue[100]!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
