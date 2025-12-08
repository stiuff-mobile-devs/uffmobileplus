import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

class PayRestaurantController extends GetxController {
  PayRestaurantController();

  RxBool isLoading = false.obs;
  RxBool isPaymentProcessing = false.obs;

  late ExternalModulesServices externalModulesServices;

  String userName = "";
  String userIdUFF = "";
  String userImageUrl = "";
  String currentBalance = "";

  @override
  onInit() {
    externalModulesServices = Get.find<ExternalModulesServices>();
    externalModulesServices.initialize();

    userName = externalModulesServices.getUserName() ?? "";
    userIdUFF = externalModulesServices.getUserIdUFF();
    userImageUrl = externalModulesServices.getUserPhotoUrl();

    super.onInit();
  }

  void goToPaymentHelpScreen() {
    Get.toNamed(Routes.PAY_RESTAURANT_HELP);
  }

  void goToPaymentTicket() {
     
    isPaymentProcessing.value = true;
      try {
        Map<String, dynamic> paymentCode = await sctmService.getPaymentCode(
            sharedUser.idUff!, sharedUser.accessToken!);
        await Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => PaymentTicketScreen(paymentCode)),
        );
      } catch (e) {
        // if (e.message != null && e.message is String)
        //   await MessageDialogs.showErrorDialog(context, message: e.message);
        // else
        //   await MessageDialogs.showErrorDialog(context);
        print(e);
        if (e is Exception && e.toString().isNotEmpty) {
          await MessageDialogs.showErrorDialog(context, message: e.toString());
        } else {
          await MessageDialogs.showErrorDialog(context);
        }
        Navigator.pop(context);
      }
   
  
    isPaymentProcessing.value = false;
   
  }
  
}
