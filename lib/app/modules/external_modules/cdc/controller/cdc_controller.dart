import 'package:get/get.dart';

class CdcController extends GetxController {

CdcController();

  final _obj = ''.obs;
  set obj(value) => this._obj.value = value;
  get obj => this._obj.value;
}