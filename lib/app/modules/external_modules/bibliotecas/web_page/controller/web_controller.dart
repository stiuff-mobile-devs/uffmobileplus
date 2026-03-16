import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BibliotecasWebController extends GetxController {
  late final WebViewController webController;
  late final String pageTitle;

  @override
  void onInit() {
    super.onInit();

    // 1. Pega os argumentos passados pelo Get.toNamed
    final arguments = Get.arguments as Map<String, dynamic>?;

    // 2. Extrai a URL e o Título diretos do mapa (sem links de exemplo)
    final String url = arguments?['url'] ?? ''; 
    pageTitle = arguments?['title'] ?? '';

    // 3. Inicializa o WebView com a URL recebida
    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));
  }
}