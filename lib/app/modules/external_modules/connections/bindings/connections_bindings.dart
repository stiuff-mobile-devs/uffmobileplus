import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/connections/controller/connections_controller.dart';

class ConnectionsBindings implements Bindings {
@override
void dependencies() {
  Get.lazyPut<ConnectionsController>(() => ConnectionsController());
  }
}