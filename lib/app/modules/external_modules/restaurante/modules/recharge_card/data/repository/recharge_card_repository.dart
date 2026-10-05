import 'package:uffmobileplus/app/data/connections/sctm_service.dart';

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
}
