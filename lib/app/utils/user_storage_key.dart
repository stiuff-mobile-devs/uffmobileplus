import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Chave curta e estável para separar dados guardados no aparelho (Hive) por
/// usuário, sem gravar o iduff ou o uid do Google em claro.
///
/// [seed] é o iduff ou, sem ele, o uid do Google.
String userStorageKey(String seed) => sha256
    .convert(utf8.encode('uffmobileplus-local:$seed'))
    .toString()
    .substring(0, 16);
