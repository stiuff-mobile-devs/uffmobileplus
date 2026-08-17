import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/crud_table.dart';
import 'admin_crud_table_page.dart';

class TiposIdeiaPage extends GetView<BancoDeIdeiasController> {
  const TiposIdeiaPage({super.key});

  static const routeName = '/tipos-ideia';

  @override
  Widget build(BuildContext context) {
    return AdminCrudTablePage(table: crudTables[4]);
  }
}
