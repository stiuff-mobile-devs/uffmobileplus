import '../provider/usuario_api_service.dart';

class RegistrationDraft {
  const RegistrationDraft({
    required this.nome,
    this.isAluno,
    this.cursoId,
    this.cursoNome,
  });

  final String nome;
  final bool? isAluno;
  final String? cursoId;
  final String? cursoNome;
  String get tipoUsuario => isAluno == true
      ? 'Aluno'
      : isAluno == false
      ? 'Professor'
      : 'Terceirizado';

  UsuarioCadastroData? get cadastroCompleto =>
      nome.isNotEmpty &&
          (isAluno != true ||
              cursoId != null ||
              cursoNome?.trim().isNotEmpty == true)
      ? UsuarioCadastroData(
          nome: nome,
          isAluno: isAluno == true,
          tipoUsuario: tipoUsuario,
          cursoId: cursoId,
          cursoNome: cursoNome,
        )
      : null;

  factory RegistrationDraft.fromExternalData({
    required String nome,
    required String vinculo,
    required String curso,
    required CadastroUsuarioOpcoes opcoes,
  }) {
    String normalize(String value) =>
        value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    final bond = normalize(vinculo);
    final bool? isAluno;
    if (bond.contains('professor') || bond.contains('docente')) {
      isAluno = false;
    } else if (bond.contains('aluno') || bond.contains('estudante')) {
      isAluno = true;
    } else {
      isAluno = null;
    }
    final matches = opcoes.cursos
        .where(
          (option) =>
              curso.trim().isNotEmpty &&
              normalize(option.nome) == normalize(curso) &&
              option.id.isNotEmpty,
        )
        .toList();
    return RegistrationDraft(
      nome: nome.trim(),
      isAluno: isAluno,
      cursoNome: isAluno == true && matches.isEmpty && curso.trim().isNotEmpty
          ? curso.trim()
          : null,
      cursoId: isAluno == true && matches.length == 1
          ? matches.single.id
          : null,
    );
  }
}
