import 'package:flutter_test/flutter_test.dart';
import 'package:uffmobileplus/app/utils/gdi_groups.dart';

void main() {
  final gid = GdiGroupsEnum.controladoresDeAcesso.id;

  group('isCatracaOperator', () {
    test('operador pelo grupo do IdUFF', () {
      expect(isCatracaOperator(iduffGids: ['1', gid]), isTrue);
    });

    test('operador pelo grupo do Google', () {
      expect(isCatracaOperator(googleGids: [gid]), isTrue);
    });

    test('operador pelo e-mail do grupo Google, sem diferenciar maiúsculas',
        () {
      expect(
        isCatracaOperator(googleEmails: [catracaOperatorsGroupEmail]),
        isTrue,
      );
      expect(
        isCatracaOperator(
          googleEmails: [catracaOperatorsGroupEmail.toUpperCase()],
        ),
        isTrue,
      );
    });

    test('não é operador sem o grupo', () {
      expect(isCatracaOperator(), isFalse);
      expect(
        isCatracaOperator(
          iduffGids: ['50002', null],
          googleGids: ['50015'],
          googleEmails: ['outro@id.uff.br', null],
        ),
        isFalse,
      );
    });
  });
}
