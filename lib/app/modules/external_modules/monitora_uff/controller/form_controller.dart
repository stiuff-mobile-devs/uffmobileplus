import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/data/provider/firebase_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_model.dart';

class FormController extends GetxController {
  final _selectedUser = Rxn<UserModel>();
  UserModel? get selectedUser => _selectedUser.value;

  TextEditingController textEditingController = TextEditingController();

  final _role = 'monitor'.obs;
  String get role => _role.value;
  set role(String value) => _role.value = value;

  @override
  void onInit() {
    super.onInit();
    _selectedUser.value = Get.arguments;
    textEditingController.text = selectedUser?.email ?? '';

    if (selectedUser != null) _role.value = selectedUser!.funcao;
  }

  @override
  void onClose() {
    textEditingController.dispose();
    super.onClose();
  }

  
  void setUser(UserModel user) => FirebaseProvider().setUser(user);
}
