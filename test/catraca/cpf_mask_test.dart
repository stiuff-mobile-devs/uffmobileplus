import 'package:flutter_test/flutter_test.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/cpf_mask.dart';

void main() {
  group('maskCpf', () {
    test('mascara um CPF só com dígitos', () {
      expect(maskCpf('12345678909'), '***.456.789-**');
    });

    test('mascara um CPF já formatado', () {
      expect(maskCpf('123.456.789-09'), '***.456.789-**');
    });

    test('devolve sem mudança quando não tem 11 dígitos', () {
      expect(maskCpf('1234'), '1234');
      expect(maskCpf(''), '');
      expect(maskCpf('a1b2c3'), 'a1b2c3');
    });
  });
}
