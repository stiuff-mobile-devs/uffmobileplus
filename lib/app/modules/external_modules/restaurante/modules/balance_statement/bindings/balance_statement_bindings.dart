import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/balance_statement/controller/balance_statement_controller.dart';

class BalanceStatementBindings implements Bindings {
@override
void dependencies() {
  Get.lazyPut<BalanceStatementController>(
      () => BalanceStatementController());
  }
}