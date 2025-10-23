import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/area.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/operator_transaction.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/operator_transaction_offline.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/provider/catraca_online_provider.dart';

class CatracaOnlineRepository {
  CatracaOnlineRepository();

  CatracaOnlineProvider catracaOnlineProvider = CatracaOnlineProvider();

  Future<List<AreaModel>> getAreas(iduff, token) async {
    return await catracaOnlineProvider.getAreas(iduff, token);
  }

  Future<List<OperatorTransactionModel>> getOperatorTransactions(
    String iduff,
    String token,
    String areaId,
  ) async {
    return await catracaOnlineProvider.getOperatorTransactions(
      iduff,
      token,
      areaId,
    );
  }

  Future<Map<String, dynamic>> validatePayment(
    String paymentCode,
    String iduff,
    String token,
    String areaId,
  ) async {
    return await catracaOnlineProvider.validatePayment(
      paymentCode,
      iduff,
      token,
      areaId,
    );
  }

  Future<String> saveOperatorTransactionsOffline(
    OperatorTransactionOffline operatorTransactionOffline,
  ) async {
    return await catracaOnlineProvider.saveOperatorTransactionsOffline(
      operatorTransactionOffline,
    );
  }

  Future<List<OperatorTransactionOffline>>
  getOperatorTransactionsOffline() async {
    return await catracaOnlineProvider.getOperatorTransactionsOffline();
  }
}
