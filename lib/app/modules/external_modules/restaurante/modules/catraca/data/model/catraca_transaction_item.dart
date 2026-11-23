import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/operator_transaction.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/operator_transaction_offline.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/cpf_mask.dart';

/// Onde a transação foi processada.
enum CatracaTxSource { sctm, offline }

/// Como o operador validou.
enum CatracaTxMethod { qrCode, manual }

/// Item da lista de transações recentes da catraca, juntando as online (SCTM)
/// e as offline (Hive). Só para exibição: não é salvo em lugar nenhum.
class CatracaTransactionItem {
  const CatracaTransactionItem({
    required this.id,
    required this.source,
    required this.method,
    this.name,
    this.identifier,
    this.campus,
    this.value,
    this.date,
    this.operator,
    this.isSynced,
  });

  final String id;
  final CatracaTxSource source;
  final CatracaTxMethod method;

  /// Nome do usuário (só vem do SCTM).
  final String? name;

  /// id IdUFF do QR code ou CPF da validação manual (offline).
  final String? identifier;
  final String? campus;

  /// Valor debitado (só SCTM).
  final String? value;
  final DateTime? date;

  /// E-mail do operador que validou.
  final String? operator;

  /// Só para offline: se já foi enviada ao Firebase.
  final bool? isSynced;

  /// Validações online são sempre por QR code: a manual por CPF é gravada
  /// offline (ver `saveCpfValidationTransaction`).
  factory CatracaTransactionItem.fromOnline(
    OperatorTransactionModel tx, {
    String? campus,
    String? operator,
  }) {
    return CatracaTransactionItem(
      id: 'sctm-${tx.date?.toIso8601String()}-${tx.name}',
      source: CatracaTxSource.sctm,
      method: CatracaTxMethod.qrCode,
      name: tx.name,
      campus: tx.area ?? campus,
      value: tx.value,
      date: tx.date,
      operator: operator,
    );
  }

  /// `isIduff == true` é gravado pela validação manual por CPF; o QR code
  /// offline grava `false`.
  factory CatracaTransactionItem.fromOffline(OperatorTransactionOffline tx) {
    return CatracaTransactionItem(
      id: tx.id,
      source: CatracaTxSource.offline,
      method: tx.isIduff == true
          ? CatracaTxMethod.manual
          : CatracaTxMethod.qrCode,
      identifier: tx.idUser,
      campus: tx.campus,
      date: tx.entryTime,
      operator: tx.idOperator,
      isSynced: tx.isSynced == true,
    );
  }

  /// Nome quando houver; senão o CPF mascarado ou o id IdUFF.
  String get displayName {
    if (name != null && name!.trim().isNotEmpty) return name!.trim();
    final id = identifier ?? '';
    if (id.isEmpty) return '-';
    return method == CatracaTxMethod.manual ? maskCpf(id) : id;
  }
}
