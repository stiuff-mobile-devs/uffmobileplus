import 'package:uffmobileplus/app/data/connections/sctm_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/user_balance.dart';

class RechargeCardRepository {
  RechargeCardRepository();

  SctmService sctmService = SctmService();

  Future<String> getPaymentUrl(
    String amount,
    String idUff,
    String acessToken,
    String tokenGoogle,
  ) async {
    return await sctmService.getPaymentUrl(amount, idUff, acessToken, tokenGoogle);
  }

  /// Saldo atual, só para exibir no painel do topo (mesma chamada do Pagar).
  Future<UserBalance> getUserBalance(String idUff, String accessToken) {
    return sctmService.getUserBalance(idUff, accessToken, "");
  }
}
