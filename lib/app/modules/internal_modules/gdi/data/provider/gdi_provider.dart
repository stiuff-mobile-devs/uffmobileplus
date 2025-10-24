import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/data/services/external_gdi_service.dart';
import '../models/gdi_model.dart' as gdi;
import 'gdi_api.dart';

class GdiProvider {
  ExternalGDIService gdiService = Get.find<ExternalGDIService>();

  GdiProvider();

  Future<gdi.Person?> getSelf() async {
    String id = gdiService.getUserIdUFF();
    String accessToken = await gdiService.getAccessToken() ?? "";
    Uri url = Uri(
      host: GdiApi.host,
      path: "${GdiApi.path}/people/$id",
      port: GdiApi.port,
      scheme: GdiApi.scheme,
    );
    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      }
    );
    if (res.statusCode == 200) {
      var json = jsonDecode(res.body);
      return gdi.Person.fromJson(json);
    }
    return null;
  }

  Future<List<gdi.Group>?> getGroups() async {
    String id = gdiService.getUserIdUFF();
    String accessToken = await gdiService.getAccessToken() ?? "";
    Uri url = Uri(
        host: GdiApi.host,
        path: "${GdiApi.path}/people/$id/groups",
        port: GdiApi.port,
        scheme: GdiApi.scheme,
      );

    final res = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        }
    );

    if (res.statusCode == 200) {
      if (res.body == "null") {return null;}
      var json = jsonDecode(res.body);
      List<gdi.Group> l = [];
      for (var g in json) {
        l.add(gdi.Group.fromJson(g));
      }
      return l;
    }
    return null;
  }
}