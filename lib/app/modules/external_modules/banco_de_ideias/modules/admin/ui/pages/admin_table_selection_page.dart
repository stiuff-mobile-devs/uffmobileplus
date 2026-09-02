import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/controller/banco_de_ideias_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/admin/ui/widgets/admin_panel_header.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/admin/ui/widgets/admin_table_grid.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/data/models/crud_table.dart';
import 'package:uffmobileplus/app/modules/external_modules/banco_de_ideias/modules/admin/ui/pages/admin_crud_table_page.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

class AdminTableSelectionPage extends GetView<BancoDeIdeiasController> {
  const AdminTableSelectionPage({super.key});

  static const routeName = '/tabelas';

  Future<void> _signOut(BuildContext context) async {
    await controller.signOut();
  }

  void _openTable(BuildContext context, CrudTable table) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminCrudTablePage(
          table: table,
          crudApiService: controller.crudApiService,
        ),
      ),
    );
  }

  void _openUserArea(BuildContext context) {
    controller.voltarParaAreaUsuario();
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    Get.offNamed(Routes.BANCO_DE_IDEIAS);
  }

  @override
  Widget build(BuildContext context) {
    final user = controller.authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('bdi_painel_controle'.tr),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _openUserArea(context),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.lightbulb_outline_rounded),
            label: Text('bdi_area_usuario'.tr),
          ),
          IconButton(
            tooltip: 'sair'.tr,
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdminPanelHeader(email: user?.email),
                    const SizedBox(height: 20),
                    Expanded(
                      child: AdminTableGrid(
                        tables: crudTables,
                        onOpenTable: (table) => _openTable(context, table),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
