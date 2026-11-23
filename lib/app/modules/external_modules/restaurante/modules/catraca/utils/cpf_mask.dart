/// Mascara um CPF para exibição: `12345678901` → `***.456.789-**`.
/// Valores que não têm 11 dígitos voltam sem mudança.
String maskCpf(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 11) return value;
  return '***.${digits.substring(3, 6)}.${digits.substring(6, 9)}-**';
}
