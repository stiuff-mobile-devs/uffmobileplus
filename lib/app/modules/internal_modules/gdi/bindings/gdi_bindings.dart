import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/external_gdi_service.dart';
import 'package:uffmobileplus/app/modules/internal_modules/gdi/repository/gdi_repository.dart';

class GDIBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<ExternalGDIService>(ExternalGDIService(), permanent: true);
    Get.put<GdiRepository>(GdiRepository());
  }
}