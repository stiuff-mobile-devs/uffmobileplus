
import 'package:uffmobileplus/app/data/services/sctm_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/user_balance.dart';

class BalanceStatementRepository {


BalanceStatementRepository();

SctmService sctmService = SctmService();

  Future<bool> fetchUserBalance(String iduff, String acessToken) async {
    final response = await sctmService.refreshPayments(iduff, acessToken);
    return response;
  }

  Future<UserBalance> getUserBalance(String iduff, String acessToken, {required double period}) async {
    final response = await sctmService.getUserBalance(iduff, acessToken, period: period);
    return response;
  }


}