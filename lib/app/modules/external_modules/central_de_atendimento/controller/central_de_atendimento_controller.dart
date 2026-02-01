import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CentralDeAtendimentoController extends GetxController {
  late final WebViewController webController;
  @override
  void onInit(){
    super.onInit();
    webController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse("https://citsmart.uff.br/citsmart/webmvc/login"));
  }
}