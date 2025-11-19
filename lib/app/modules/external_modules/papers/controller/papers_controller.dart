import 'package:get/get.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

class PapersController extends GetxController {
  void goDocPap(){
    Get.toNamed(
      Routes.WEB_VIEW,
      arguments: {
        'url': 'https://citsmart.uff.br/citsmart/pages/knowledgeBasePortal/knowledgeBasePortal.load#/knowledge/3264',
        'title': 'periodicos'.tr
      }
    );
  }

  static const String url_papers = "https://www-periodicos-capes-gov-br.ez24.periodicos.capes.gov.br/index.php?option=com_plogin&ym=3&pds_handle=&calling_system=primo&institute=CAPES&targetUrl=http://www.periodicos.capes.gov.br&Itemid=155&pagina=CAFe";

  @override
  void onInit() {
    super.onInit();
  }

  void goPapers(){
    Get.toNamed(
      Routes.WEB_VIEW,
      arguments: {
        'url': url_papers,
        'title': 'periodicos'.tr
      }
    );
  }
}