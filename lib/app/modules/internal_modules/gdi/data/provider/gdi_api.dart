import 'gdi_provider.dart';

class GdiApi {
  static String host = "app.uff.br";
  static int? port = null;
  static String path = "/umm/v2/gdi";
  static String scheme = "https";

  late GdiProvider people;

  GdiApi() {
    people = GdiProvider();
  }
}