import 'package:uffmobileplus/app/data/services/sctm_service.dart';

class RechargeCardRepository {
  RechargeCardRepository();

  SctmService sctmService = SctmService();

  Future<String> getPaymentUrl(
    String amount,
    String idUff,
    String acessToken,
  ) async {
    return await sctmService.getPaymentUrl(amount, idUff, acessToken);
  }
}
