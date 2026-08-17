import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/crud_table.dart';
import 'admin_crud_table_page.dart';

class DepartamentosPage extends GetView<BancoDeIdeiasController> {
  const DepartamentosPage({super.key});

  static const routeName = '/departamentos';

  @override
  Widget build(BuildContext context) {
    return AdminCrudTablePage(table: crudTables[1]);
  }
}
