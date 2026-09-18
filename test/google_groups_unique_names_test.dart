import 'package:flutter_test/flutter_test.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/google_groups_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/cardapio/controller/google_groups_controller.dart';

void main() {
  group('Unicidade de Tipos de Controladores de Grupos', () {
    test('Happy Path: Os controladores de grupos de módulos distintos devem ter tipos distintos', () {
      // 1. Arrange
      const Type harpiaType = HarpiaGoogleGroupsController;
      const Type cardapioType = CardapioGoogleGroupsController;

      // 2. Act
      final isIdentical = identical(harpiaType, cardapioType);

      // 3. Assert
      expect(isIdentical, isFalse);
    });

    test('Edge Case: As representações textuais dos tipos dos controladores devem ser distintas', () {
      // 1. Arrange
      const Type harpiaType = HarpiaGoogleGroupsController;
      const Type cardapioType = CardapioGoogleGroupsController;

      // 2. Act
      final namesMatch = harpiaType.toString() == cardapioType.toString();

      // 3. Assert
      expect(namesMatch, isFalse);
    });

    test('Sad Path: A verificação de identidade no mesmo tipo deve retornar verdadeiro (sem falso positivo)', () {
      // 1. Arrange
      const Type harpiaTypeA = HarpiaGoogleGroupsController;
      const Type harpiaTypeB = HarpiaGoogleGroupsController;

      // 2. Act
      final isSelfIdentical = identical(harpiaTypeA, harpiaTypeB);

      // 3. Assert
      expect(isSelfIdentical, isTrue);
    });
  });
}
