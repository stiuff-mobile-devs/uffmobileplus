import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/pay_restaurant/data/provider/pay_restaurant_provider.dart';

class PayRestaurantRepository {
  PayRestaurantRepository();
  PayRestaurantProvider payRestaurantProvider = PayRestaurantProvider();

  Future<Map<String, dynamic>> getPaymentCode(
    String idUff,
    String accessToken,
  ) {
    return payRestaurantProvider.getPaymentCode(idUff, accessToken);
  }
}
