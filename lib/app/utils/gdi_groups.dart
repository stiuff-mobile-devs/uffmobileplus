enum GdiGroupsEnum {
  testeDeMobile("50015"),
  adminCardapioRestauranteUniversitario("50014"),
  operacaoDeAppMoveis("50002"),
  usuariosMoveUF("50017"),
  controladoresDeAcesso("50022");

  const GdiGroupsEnum(this.id);
  final String id;
}

/// E-mail do grupo Google dos operadores da catraca.
const String catracaOperatorsGroupEmail =
    'controladores-de-acesso-ru.proaes@id.uff.br';

/// Regra única de quem pode operar a catraca, usada no login, no escolher
/// perfil e na grade do restaurante. Vale o vínculo que o operador usou:
/// gid de controladores de acesso nos grupos do IdUFF **ou** do Google, ou o
/// grupo Google dos controladores.
///
/// Recebe só gids e e-mails (de `gdiGroups` e `gdiGroupsGoogle.gdiGroups`)
/// para esta camada não conhecer os modelos dos módulos. Lê dados em cache
/// (Hive), então funciona sem internet.
bool isCatracaOperator({
  Iterable<String?> iduffGids = const [],
  Iterable<String?> googleGids = const [],
  Iterable<String?> googleEmails = const [],
}) {
  final gid = GdiGroupsEnum.controladoresDeAcesso.id;
  return iduffGids.contains(gid) ||
      googleGids.contains(gid) ||
      googleEmails.any((e) => e?.toLowerCase() == catracaOperatorsGroupEmail);
}
