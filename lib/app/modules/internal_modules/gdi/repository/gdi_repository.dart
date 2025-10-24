import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../user/data/models/user_data.dart';
import '../data/models/gdi_model.dart' as gdi;
import '../data/provider/gdi_api.dart';

class GdiRepository {
  GdiApi? gdiApi;
  final groupBox = Hive.box<gdi.GroupList>('gdi_group');
  final personBox = Hive.box<gdi.Person>('gdi_person');
  late Box box;

  List<gdi.Group>? groupsList;
  gdi.Person? self;

  GdiRepository() {
    gdiApi = GdiApi();
  }

  Future clear() async {
    return Future.wait([
      groupBox.clear(),
      personBox.clear(),
    ]);
  }

  Future<gdi.Person?> getSelf() async {
    self = personBox.get('self');
    if (self != null) {
      return self;
    }
    self = await _exec(() => gdiApi!.people.getSelf());
    personBox.put('self', self!);
    return self;
  }

  Future<List<gdi.Group>?> getGroups() async {
    groupsList = groupBox.get('groups')?.groups;
    if (groupsList != null && groupsList!.isNotEmpty) {
      return groupsList;
    }
    groupsList = await _exec(() => gdiApi!.people.getGroups());
    if (groupsList == null) {
      return null;
    }
    groupBox.put('groups', gdi.GroupList(groupsList!));
    return groupsList;
  }

  bool isInGroup(GdiGroups gdiGroup) {
    if (groupsList == null) return false;
    for (var group in groupsList!) {
      if (group.gid! == gdiGroup.gid) {
        return true;
      }
    }
    return false;
  }

  Future<T?> _exec<T>(Future<T?> Function() f) async {
    if (gdiApi == null) {
      debugPrint("GdiApi is null");
      return null;
    }
    try {
      return await f();
    } catch (e) {
      debugPrint("Algum problema ocorreu");
      debugPrint(e.toString());
      rethrow;
    }
  }
}
