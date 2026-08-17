import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/auth_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/crud_api_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/ideia_api_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/provider/usuario_api_service.dart';

class BancoDeIdeiasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<CrudApiService>(() => CrudApiService());
    Get.lazyPut<IdeiaApiService>(() => IdeiaApiService());
    Get.lazyPut<UsuarioApiService>(() => UsuarioApiService());
    Get.lazyPut<BancoDeIdeiasController>(() => BancoDeIdeiasController());
  }
}
