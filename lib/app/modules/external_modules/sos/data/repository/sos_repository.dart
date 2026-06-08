import 'package:uffmobileplus/app/modules/external_modules/sos/data/provider/sos_provider.dart';
import 'package:get/get.dart';

class SosRepository {
  final SosProvider _provider = Get.find<SosProvider>();

  Future<SosDispatchResult?> sendDispatch({
    String? incidentId,
    required String action,
    required String pointType,
    required String status,
    String? nome,
    required String matricula,
    String? email,
    required double lat,
    required double lng,
  }) async {
    return _provider.postDispatchAlert(
      incidentId: incidentId,
      action: action,
      pointType: pointType,
      status: status,
      nome: nome,
      matricula: matricula,
      email: email,
      lat: lat,
      lng: lng,
    );
  }
}
