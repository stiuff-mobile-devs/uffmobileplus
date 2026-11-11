import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';

/// Valores da refeição no RU, **só para exibição** (selo, tabela e contagem de
/// refeições). O valor cobrado de verdade é definido pelo servidor no
/// pagamento; mantenha estes números em sincronia com a tabela oficial.
///
/// Dica: no futuro, buscar estes valores do Remote Config.
class MealPrices {
  MealPrices._();

  /// Estudantes (graduação, pós, EAD, sequencial, sanduíche).
  static const double student = 0.70;

  /// Demais vínculos (docentes, técnicos, terceirizados, pós-doc...).
  static const double staff = 14.50;

  /// Valor da refeição do perfil; `null` quando o perfil não come no RU
  /// (anônimo ou sem perfil).
  static double? priceFor(ProfileTypes? profile) {
    switch (profile) {
      case ProfileTypes.grad:
      case ProfileTypes.pos:
        return student;
      case ProfileTypes.teacher:
      case ProfileTypes.employee:
      case ProfileTypes.outsourced:
      case ProfileTypes.post_doc_researcher_student:
        return staff;
      case ProfileTypes.anonymous:
      case null:
        return null;
    }
  }

  /// Chave de tradução do nome do perfil.
  static String? profileLabelKey(ProfileTypes? profile) {
    switch (profile) {
      case ProfileTypes.grad:
        return 'ru_aluno_graduacao';
      case ProfileTypes.pos:
        return 'ru_aluno_pos';
      case ProfileTypes.teacher:
        return 'ru_professor';
      case ProfileTypes.employee:
        return 'ru_tecnico';
      case ProfileTypes.outsourced:
        return 'ru_terceirizado';
      case ProfileTypes.post_doc_researcher_student:
        return 'ru_pos_doc';
      case ProfileTypes.anonymous:
      case null:
        return null;
    }
  }

  /// Categorias (chaves de tradução) que pagam [student].
  static const List<String> studentCategories = [
    'ru_aluno_graduacao',
    'ru_aluno_pos',
    'ru_aluno_ead',
    'ru_aluno_sequencial',
    'ru_doutorado_sanduiche',
    'ru_mestrado_sanduiche',
  ];

  /// Categorias (chaves de tradução) que pagam [staff].
  static const List<String> staffCategories = [
    'ru_professor',
    'ru_professor_substituto',
    'ru_tecnico',
    'ru_terceirizado',
    'ru_medico_residente',
    'ru_pos_doc',
  ];

  /// Saldo vindo do servidor ("12,30" ou "12.30") como número; `null` se não
  /// for um número (ex.: falha ao carregar).
  static double? parseBalance(String raw) =>
      double.tryParse(raw.trim().replaceAll(',', '.'));

  /// Quantas refeições [balance] paga a [price] cada. A conta é em centavos,
  /// para 2,10 / 0,70 dar 3 (e não 2,999...).
  static int? mealsFor(double? balance, double? price) {
    if (balance == null || price == null || price <= 0) return null;
    if (balance <= 0) return 0;
    return (balance * 100).round() ~/ (price * 100).round();
  }

  /// "0,70" → formato brasileiro com vírgula.
  static String format(double value) =>
      value.toStringAsFixed(2).replaceAll('.', ',');
}
