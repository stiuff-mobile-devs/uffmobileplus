import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/dashboard_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/pages/external_modules_page.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/pages/home_page.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/widgets/dashboard_nav_bar.dart';

class Dashboard extends GetView<DashboardController> {
  const Dashboard({super.key});

  static const Color _background = Color(0xFF060D19);

  @override
  Widget build(BuildContext context) {
    // Barra do sistema (botões/gestos) com o mesmo fundo escuro da dashboard.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _background,
        // O conteúdo passa por trás da pílula; o Scaffold soma a altura da
        // barra ao padding inferior que as páginas usam no fim das listas.
        extendBody: true,
        body: PageView(
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          children: const [
            _KeepAlivePage(child: HomePage()),
            _KeepAlivePage(child: ExternalModulesPage()),
          ],
        ),
        bottomNavigationBar: const DashboardNavBar(),
      ),
    );
  }
}

/// Mantém a aba viva fora da tela para preservar a rolagem ao trocar de aba.
class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({required this.child});

  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
