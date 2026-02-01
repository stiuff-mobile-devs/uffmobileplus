import 'package:uffmobileplus/app/modules/external_modules/sos/data/provider/sos_provider.dart';
import 'package:get/get.dart';

class SosRepository {
  final SosProvider _provider = Get.find<SosProvider>();

  Future<bool> sendSos({
    String? nome,
    required String matricula,
    required double lat,
    required double lng,
  }) async {
    return await _provider.postSosAlert(nome,matricula, lat, lng);
  }
}
  