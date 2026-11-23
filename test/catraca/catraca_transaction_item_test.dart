import 'package:flutter_test/flutter_test.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/catraca_transaction_item.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/operator_transaction.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/operator_transaction_offline.dart';

void main() {
  group('CatracaTransactionItem.fromOffline', () {
    test('QR code (isIduff falso), pendente', () {
      final tx = OperatorTransactionOffline(
        idUser: 'a8f3k2',
        idOperator: 'op@id.uff.br',
        campus: 'Gragoatá',
      );
      final item = CatracaTransactionItem.fromOffline(tx);
      expect(item.source, CatracaTxSource.offline);
      expect(item.method, CatracaTxMethod.qrCode);
      expect(item.isSynced, isFalse);
      expect(item.id, tx.id);
      expect(item.operator, 'op@id.uff.br');
      expect(item.displayName, 'a8f3k2');
    });

    test('manual por CPF (isIduff verdadeiro) mostra o CPF mascarado', () {
      final tx = OperatorTransactionOffline(
        idUser: '12345678909',
        isIduff: true,
        isSynced: true,
      );
      final item = CatracaTransactionItem.fromOffline(tx);
      expect(item.method, CatracaTxMethod.manual);
      expect(item.isSynced, isTrue);
      expect(item.displayName, '***.456.789-**');
    });
  });

  group('CatracaTransactionItem.fromOnline', () {
    test('usa o nome do SCTM e o valor debitado', () {
      final date = DateTime(2026, 11, 23, 12, 41);
      final item = CatracaTransactionItem.fromOnline(
        OperatorTransactionModel(
          name: '  Maria Silva ',
          value: '2,50',
          area: 'R.U. Gragoatá',
          date: date,
        ),
        campus: 'Outro campus',
        operator: 'op@id.uff.br',
      );
      expect(item.source, CatracaTxSource.sctm);
      expect(item.method, CatracaTxMethod.qrCode);
      expect(item.displayName, 'Maria Silva');
      expect(item.value, '2,50');
      expect(item.campus, 'R.U. Gragoatá');
      expect(item.date, date);
    });

    test('sem área usa o campus informado', () {
      final item = CatracaTransactionItem.fromOnline(
        OperatorTransactionModel(name: 'Ana'),
        campus: 'Praia Vermelha',
      );
      expect(item.campus, 'Praia Vermelha');
    });

    test('sem nome nem identificador mostra "-"', () {
      final item = CatracaTransactionItem.fromOnline(OperatorTransactionModel());
      expect(item.displayName, '-');
    });
  });
}
