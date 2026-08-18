import 'package:flutter_test/flutter_test.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/google_groups_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/cardapio/controller/google_groups_controller.dart';

void main() {
  test('Os controladores de grupos de módulos diferentes devem ter tipos distintos', () {
    expect(identical(HarpiaGoogleGroupsController, CardapioGoogleGroupsController), isFalse);
  });
}
