import 'package:uffmobileplus/app/data/connections/saci_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/iduff/services/auth_iduff_service.dart';

class CarteirinhaValidadorRepository {
  CarteirinhaValidadorRepository();

  SaciService saciService = SaciService();

  Future<List<dynamic>> validateCard(
    String qrCodeText,
    AuthIduffService auth,
  ) async {
    return await saciService.validateCard(qrCodeText, auth);
  }
}
