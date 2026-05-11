
import 'package:uffmobileplus/app/data/services/connections/saci_service.dart';
import 'package:uffmobileplus/app/data/services/connections/sctm_service.dart';
import 'package:uffmobileplus/app/data/services/connections/umm_service.dart';

class ConnectionsRepository {


ConnectionsRepository();

final SctmService _sctmService = SctmService();
final UmmService _ummService = UmmService();
final SaciService _saciService = SaciService();

  Future<bool> getSctmStatus() async {
    return await _sctmService.getStatus();
  }

  Future<bool> getUmmStatus() async {
    return await _ummService.getStatus();
  }

  Future<bool> getSaciStatus() async {
    return await _saciService.getStatus();
  }

}