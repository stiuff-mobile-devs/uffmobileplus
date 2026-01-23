import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/sos/controller/sos_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/sos/data/provider/sos_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/sos/data/repository/sos_repository.dart';

class SosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SosProvider>(() => SosProvider());
    Get.lazyPut<SosRepository>(() => SosRepository()); 
    Get.lazyPut<SosController>(() => SosController());
  }
}