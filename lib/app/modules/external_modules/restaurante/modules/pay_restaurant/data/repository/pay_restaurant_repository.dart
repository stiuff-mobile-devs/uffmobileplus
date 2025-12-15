import 'package:uffmobileplus/app/data/services/sctm_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/model/user_balance.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/provider/pay_restaurant_provider.dart';

class PayRestaurantRepository {
  PayRestaurantRepository();
  PayRestaurantProvider payRestaurantProvider = PayRestaurantProvider();
  SctmService sctmService = SctmService();

  Future<Map<String, dynamic>> getPaymentCode(
    String idUff,
    String accessToken,
  ) {
    return sctmService.getPaymentCode(idUff, accessToken);
  }

  Future<UserBalance> getUserBalance(
    String idUff,
    String accessToken, {
    double? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return sctmService.getUserBalance(
      idUff,
      accessToken,
      period: period,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
