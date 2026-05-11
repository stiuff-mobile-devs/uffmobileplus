
import 'package:uffmobileplus/app/data/services/connections/saci_service.dart';
import 'package:uffmobileplus/app/data/services/connections/sctm_service.dart';
import 'package:uffmobileplus/app/data/services/connections/umm_service.dart';

class ConnectionsRepository {


ConnectionsRepository();

SctmService _sctmService = SctmService();
UmmService _ummService = UmmService();
SaciService _saciService = SaciService();

}