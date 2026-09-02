import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/data/services/responsive_layout_service.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/cardapio/ui/pages/menu_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/models/discipline_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/home_page_controller.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/utils/custom_drawer.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

class HomePage extends GetView<HomePageController> {
  const HomePage({super.key});

  static const ResponsiveGridConfig _shortcutGridConfig = ResponsiveGridConfig(
    breakpoints: [
      ResponsiveGridBreakpoint(
        maxWidth: 360,
        spec: ResponsiveGridSpec(
          crossAxisCount: 2,
          childAspectRatio: 0.86,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          cardPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          iconBoxSize: 30,
          iconPadding: 5,
          iconBorderRadius: 10,
          labelFontSize: 10,
          labelHeight: 1.05,
          iconLabelSpacing: 6,
        ),
      ),
      ResponsiveGridBreakpoint(
        maxWidth: 600,
        spec: ResponsiveGridSpec(
          crossAxisCount: 3,
          childAspectRatio: 0.92,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          cardPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          iconBoxSize: 32,
          iconPadding: 6,
          iconBorderRadius: 10,
          labelFontSize: 10.5,
          labelHeight: 1.05,
          iconLabelSpacing: 8,
        ),
      ),
      ResponsiveGridBreakpoint(
        maxWidth: 900,
        spec: ResponsiveGridSpec(
          crossAxisCount: 4,
          childAspectRatio: 0.98,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          cardPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          iconBoxSize: 32,
          iconPadding: 6,
          iconBorderRadius: 10,
          labelFontSize: 10.5,
          labelHeight: 1.05,
          iconLabelSpacing: 8,
        ),
      ),
    ],
    defaultSpec: ResponsiveGridSpec(
      crossAxisCount: 5,
      childAspectRatio: 0.98,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      cardPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      iconBoxSize: 32,
      iconPadding: 6,
      iconBorderRadius: 10,
      labelFontSize: 10.5,
      labelHeight: 1.05,
      iconLabelSpacing: 8,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(), //_buildDrawer(context),
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: const Text('UFF+'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'ajuda'.tr,
            onPressed: () => Get.toNamed(Routes.CENTRAL_DE_ATENDIMENTO),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
      ),
      body: Obx(() {
        final layoutService = controller.layoutService;
        final safeBottom = MediaQuery.of(context).padding.bottom;
        final bottomPadding = layoutService.bottomPadding(
          safeBottom: safeBottom,
        );
        final isLoading = controller.isLoading.value;
        final isRemoving = controller.isRemovingShortcuts.value;
        final savedShortcuts = controller.savedShortcuts.toList(
          growable: false,
        );

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.darkBlueToBlackGradient(),
          ),
          child: isLoading
              ? const SizedBox.expand(child: CustomProgressDisplay())
              : SafeArea(
                  bottom: false,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final layoutSpec = layoutService.gridSpecForWidth(
                        width: constraints.maxWidth,
                        config: _shortcutGridConfig,
                      );

                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                            sliver: SliverToBoxAdapter(
                              child: _buildStudyPlanSection(),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                            sliver: SliverToBoxAdapter(
                              child: _buildRestauranteSection(),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'atalhos_rapidos'.tr,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _showAddShortcutSheet(context),
                                        tooltip: 'adicionar_atalho'.tr,
                                        icon: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        onPressed:
                                            controller.toggleRemoveShortcutMode,
                                        tooltip: 'remover_atalho'.tr,
                                        icon: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: isRemoving
                                                ? Colors.red.withOpacity(0.25)
                                                : Colors.white.withOpacity(
                                                    0.12,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'atalhos_rapidos_descricao'.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final item = savedShortcuts[index];
                                return _ShortcutCard(
                                  key: ValueKey(item.page),
                                  item: item,
                                  layoutSpec: layoutSpec,
                                  isRemoveMode: isRemoving,
                                  onTap: () {
                                    if (isRemoving) {
                                      controller.removeShortcut(item);
                                      return;
                                    }

                                    controller.openShortcut(item);
                                  },
                                );
                              }, childCount: savedShortcuts.length),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: layoutSpec.crossAxisCount,
                                    crossAxisSpacing:
                                        layoutSpec.crossAxisSpacing,
                                    mainAxisSpacing: layoutSpec.mainAxisSpacing,
                                    childAspectRatio:
                                        layoutSpec.childAspectRatio,
                                  ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                            sliver: SliverToBoxAdapter(
                              child: _buildHistoricoSection(),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              16,
                              24,
                              16,
                              bottomPadding,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: _buildNoticiasSection(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.12),
          Colors.white.withOpacity(0.06),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    );
  }

  Widget _buildRestauranteSection() {
    return Obx(() {
      final mealsList = controller.campusMeals;
      final meals = mealsList != null ? mealsList.toList(growable: false) : [];
      final isLoading = controller.isLoadingCampusMeals.value ?? false;
      final hasDefault = controller.hasDefaultRestaurant.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('restaurante'.tr),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  hasDefault
                      ? 'cardapio_de_hoje'.tr
                      : 'defina_restaurante_padrao_desc'.tr,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!hasDefault && !isLoading)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Get.toNamed(Routes.BANDEJAPP),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      const Icon(Icons.restaurant, color: Colors.white, size: 32),
                      const SizedBox(height: 12),
                      Text(
                        'defina_restaurante_padrao'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'clique_escolher_refeitorio'.tr,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (isLoading)
            const SizedBox(
              height: 150,
              child: Center(child: CustomProgressDisplay(height: 50)),
            )
          else if (meals.isNotEmpty)
            SizedBox(
              height: 150,
              child: _CampusMealCard(data: meals.first),
            )
          else
            SizedBox(
              height: 150,
              child: Center(
                child: Text(
                  'cardapio_indisponivel'.tr,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildStudyPlanSection() {
    return Obx(() {
      // Proteção contra nulos na lista e no boolean
      final classesList = controller.todayClasses;
      final classes = classesList != null
          ? classesList.toList(growable: false)
          : [];
      final isLoading = controller.isLoadingTodayClasses.value ?? false;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.toNamed(Routes.STUDY_PLAN),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('plano_estudos'.tr),
                const SizedBox(height: 12),
                if (isLoading)
                  // Substituído SizedBox.expand por tamanho fixo dentro da Column
                  const SizedBox(
                    height: 100,
                    child: Center(child: CustomProgressDisplay(height: 50)),
                  )
                else if (classes.isEmpty)
                  Text(
                    'nenhuma_aula_hoje'.tr,
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  )
                else
                  Column(
                    children: classes
                        .map((discipline) => _buildDisciplineRow(discipline))
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDisciplineRow(Discipline discipline) {
    // Esse já estava seguro, os nulos já estavam sendo tratados com ??
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              discipline.title ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${discipline.startTime ?? ''} - ${discipline.endTime ?? ''}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.68),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricoSection() {
    return Obx(() {
      final stats = controller.transcriptStats.value;
      // Proteção contra boolean nulo
      final isLoading = controller.isLoadingTranscript.value ?? false;

      final chCursada = stats?.chCursada ?? 0;
      final chTotal = stats?.chTotal ?? 0;
      final progress = chTotal > 0
          ? (chCursada / chTotal).clamp(0.0, 1.0)
          : 0.0;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.toNamed(Routes.HISTORICO),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('historico'.tr),
                const SizedBox(height: 12),
                if (isLoading)
                  // Substituído SizedBox.expand por altura fixa para não explodir a Column
                  const SizedBox(
                    height: 80,
                    child: Center(child: CustomProgressDisplay(height: 50)),
                  )
                else if (stats == null)
                  Text(
                    'dados_indisponiveis'.tr,
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  )
                else ...[
                  Text(
                    'horas_cursadas_status'.trParams({
                      'cursada': '$chCursada',
                      'total': '$chTotal',
                    }),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.12),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNoticiasSection() {
    // Essa seção é completamente estática, não há risco de erros nela!
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('noticias'.tr),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'noticias_em_breve'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'noticias_preparando_desc'.tr,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showAddShortcutSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkBlue(),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Obx(() {
          final remainingServices = controller.availableToAdd.toList(
            growable: false,
          );
          final layoutService = controller.layoutService;
          final safeBottom = MediaQuery.of(context).padding.bottom;
          final bottomPadding = layoutService.bottomPadding(
            safeBottom: safeBottom,
          );

          return SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'adicionar_atalho'.tr,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.96),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'servicos_nao_salvos_desc'.tr,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (remainingServices.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'todos_servicos_salvos'.tr,
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: remainingServices.length,
                        separatorBuilder: (_, __) => Divider(
                          color: Colors.white.withOpacity(0.12),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final service = remainingServices[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: _ServiceIcon(iconSrc: service.iconSrc),
                            title: Text(
                              service.subtitle,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                              ),
                              onPressed: () => controller.addShortcut(service),
                            ),
                            onTap: () => controller.addShortcut(service),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

class _CampusMealCard extends StatelessWidget {
  const _CampusMealCard({required this.data});

  final TodayCampusMeal data;

  @override
  Widget build(BuildContext context) {
    final meal = data.meal;
    final hasDish = meal?.main?.isNotEmpty ?? false;
    
    String subtitle = 'refeicoes_indisponiveis_refeitorio'.tr;
    if (hasDish) {
      final items = [meal!.main, meal.garnish, meal.side]
          .where((item) => item != null && item.trim().isNotEmpty)
          .map((item) => '• ${item!.trim()}')
          .toList();
      if (items.isNotEmpty) {
        subtitle = items.join('\n');
      }
    }
    
    final isOpen = data.shiftLabel != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(
          () => MenuPage(location: data.campus),
          transition: Transition.rightToLeft,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.campus.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isOpen ? data.shiftLabel! : 'fechado'.tr,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.68),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.isRemoveMode,
    required this.layoutSpec,
  });

  final DashboardShortcut item;
  final VoidCallback onTap;
  final bool isRemoveMode;
  final ResponsiveGridSpec layoutSpec;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              padding: layoutSpec.cardPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ServiceIcon(iconSrc: item.iconSrc, layoutSpec: layoutSpec),
                  SizedBox(height: layoutSpec.iconLabelSpacing),
                  Text(
                    item.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: layoutSpec.labelFontSize,
                      fontWeight: FontWeight.w600,
                      height: layoutSpec.labelHeight,
                    ),
                  ),
                ],
              ),
            ),
            if (isRemoveMode)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Icon(
                    Icons.remove,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon({required this.iconSrc, this.layoutSpec});

  final String iconSrc;
  final ResponsiveGridSpec? layoutSpec;

  @override
  Widget build(BuildContext context) {
    final iconSize = layoutSpec?.iconBoxSize ?? 32;
    final iconPadding = layoutSpec?.iconPadding ?? 6;
    final iconRadius = layoutSpec?.iconBorderRadius ?? 10;

    return Container(
      height: iconSize,
      width: iconSize,
      decoration: BoxDecoration(
        color: AppColors.lightBlue().withOpacity(0.14),
        borderRadius: BorderRadius.circular(iconRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(iconPadding),
        child: iconSrc.endsWith('.svg')
            ? SvgPicture.asset(
                iconSrc,
                color: Colors.white,
                fit: BoxFit.contain,
              )
            : Image.asset(iconSrc, color: Colors.white, fit: BoxFit.contain),
      ),
    );
  }
}
