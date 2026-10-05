import 'package:uffmobileplus/app/data/connections/sctm_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/user_balance.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/provider/pay_restaurant_provider.dart';

class PayRestaurantRepository {
  PayRestaurantRepository();
  PayRestaurantProvider payRestaurantProvider = PayRestaurantProvider();
  SctmService sctmService = SctmService();

  Future<Map<String, dynamic>> getPaymentCode(
    String idUff,
    String accessToken,
    String googleToken
  ) {
    return sctmService.getPaymentCode(idUff, accessToken, googleToken);
  }

  Future<UserBalance> getUserBalance(
    String idUff,
    String accessToken, {
    double? period,
    DateTime? startDate,
    DateTime? endDate,
    String? googleToken,
  }) {
    return sctmService.getUserBalance(
      idUff,
      accessToken,
      googleToken ?? "",
      period: period,
      startDate: startDate,
      endDate: endDate,
      
    );
  }
}
