import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/catraca_transaction_item.dart';

/// Desfecho da última validação (QR code ou manual), mostrado na tela de
/// resultado.
enum CatracaResultKind {
  /// O SCTM validou e debitou.
  approvedSctm,

  /// Registrada no aparelho (Hive), para envio ao Firebase.
  savedOffline,

  /// O usuário já passou neste turno.
  duplicate,

  /// Recusada e nada foi registrado.
  rejected,

  /// O QR code não é uma carteirinha válida.
  invalidCode,

  /// Falha ao ler ou salvar.
  error,
}

/// Só para exibição: não é salvo em lugar nenhum.
class CatracaValidationResult {
  const CatracaValidationResult({
    required this.kind,
    this.message,
    this.name,
    this.item,
    this.sctmMessage,
  });

  final CatracaResultKind kind;

  /// Mensagem já traduzida (motivo da recusa ou do erro).
  final String? message;

  /// Nome ou identificador do usuário, quando conhecido.
  final String? name;

  /// A refeição registrada (SCTM ou offline), para abrir o detalhe.
  final CatracaTransactionItem? item;

  /// Resposta do SCTM quando ele recusou antes de a refeição ser salva offline.
  final String? sctmMessage;

  bool get isSuccess =>
      kind == CatracaResultKind.approvedSctm ||
      kind == CatracaResultKind.savedOffline;
}
