class UsuarioAtual {
  const UsuarioAtual({required this.raw, required this.isAdministrador});

  final Map<String, dynamic> raw;
  final bool isAdministrador;

  factory UsuarioAtual.fromJson(Map<String, dynamic> json) {
    final usuario = json['usuario'];
    final usuarioMap = usuario is Map
        ? Map<String, dynamic>.from(usuario.cast<String, dynamic>())
        : json;
    final perfil = usuarioMap['perfil'];
    final perfilMap = perfil is Map
        ? Map<String, dynamic>.from(perfil.cast<String, dynamic>())
        : const <String, dynamic>{};
    final nomePerfil = perfilMap['nome']?.toString().trim().toLowerCase();

    return UsuarioAtual(
      raw: usuarioMap,
      isAdministrador: nomePerfil == 'administrador',
    );
  }
}
