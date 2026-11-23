import 'package:flutter_test/flutter_test.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/cpf_input_formatter.dart';

String _format(String input) => CpfInputFormatter()
    .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: input))
    .text;

void main() {
  group('CpfInputFormatter', () {
    test('formata enquanto digita', () {
      expect(_format('123'), '123');
      expect(_format('1234'), '123.4');
      expect(_format('1234567'), '123.456.7');
      expect(_format('1234567890'), '123.456.789-0');
      expect(_format('12345678909'), '123.456.789-09');
    });

    test('limita a 11 dígitos', () {
      expect(_format('123456789091234'), '123.456.789-09');
    });

    test('ignora símbolos e letras ao colar', () {
      expect(_format('123.456.789-09'), '123.456.789-09');
      expect(_format('cpf: 123 456 789 09'), '123.456.789-09');
    });

    test('cursor vai para o fim', () {
      final value = CpfInputFormatter().formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '1234'),
      );
      expect(value.selection.baseOffset, value.text.length);
    });

    test('digitsOf devolve só os dígitos', () {
      expect(CpfInputFormatter.digitsOf('123.456.789-09'), '12345678909');
    });
  });
}
