import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_bars.dart';
import 'package:radio_player/radio_player.dart';
import 'package:uffmobileplus/app/modules/external_modules/radio/controller/radio_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/cardapio/ui/pages/menu_page.dart';
import 'package:uffmobileplus/app/modules/external_modules/study_plan/data/models/discipline_model.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/home_page_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/ui/widgets/home_section_card.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/utils/custom_drawer.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_progress_display.dart';

enum _SectionAction { moveUp, moveDown, hide }

class HomePage extends GetView<HomePageController> {
  const HomePage({super.key});

  /// Espaço padrão entre as seções e nas bordas da tela.
  static const double _gap = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue(),
      drawer: CustomDrawer(),
      appBar: AppBars.build(
        title: 'UFF+',
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'ajuda'.tr,
            onPressed: () => Get.toNamed(Routes.CENTRAL_DE_ATENDIMENTO),
          ),
        ],
      ),
      body: Obx(() {
        // A dashboard usa extendBody: o padding inferior já inclui a barra
        // Home/Serviços e a área do sistema.
        final bottomPadding = controller.layoutService.bottomPadding(
          safeBottom: MediaQuery.paddingOf(context).bottom,
          navBarHeight: 0,
        );
        final isLoading = controller.isLoading.value;
        final sections = controller.visibleSections;
        final hiddenCount = controller.hiddenSections.length;

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
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      _gap,
                      _gap,
                      _gap,
                      bottomPadding,
                    ),
                    children: [
                      for (int i = 0; i < sections.length; i++) ...[
                        if (i > 0) const SizedBox(height: _gap),
                        _buildSection(
                          context,
                          sections[i],
                          isFirst: i == 0,
                          isLast: i == sections.length - 1,
                        ),
                      ],
                      if (hiddenCount > 0) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton.icon(
                            onPressed: _showHiddenSections,
                            icon: Icon(
                              Icons.visibility_outlined,
                              size: 18,
                              color: AppColors.lightBlue(),
                            ),
                            label: Text(
                              'mostrar_secoes_ocultas'.trParams({
                                'n': '$hiddenCount',
                              }),
                              style: TextStyle(color: AppColors.lightBlue()),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        );
      }),
    );
  }

  // ---------------- SEÇÕES ----------------

  Widget _buildSection(
    BuildContext context,
    HomeSection section, {
    required bool isFirst,
    required bool isLast,
  }) {
    void openMenu() => _showSectionMenu(
      section,
      canMoveUp: !isFirst,
      canMoveDown: !isLast,
    );

    switch (section) {
      case HomeSection.studyPlan:
        return _buildStudyPlanSection(openMenu);
      case HomeSection.restaurant:
        return _buildRestauranteSection(openMenu);
      case HomeSection.shortcuts:
        return _buildShortcutsSection(context, openMenu);
      case HomeSection.radio:
        return _buildRadioSection(openMenu);
      case HomeSection.transcript:
        return _buildHistoricoSection(openMenu);
      case HomeSection.news:
        return _buildNoticiasSection(openMenu);
    }
  }

  static String _sectionTitle(HomeSection section) {
    switch (section) {
      case HomeSection.studyPlan:
        return 'plano_estudos'.tr;
      case HomeSection.restaurant:
        return 'restaurante'.tr;
      case HomeSection.shortcuts:
        return 'atalhos_rapidos'.tr;
      case HomeSection.radio:
        return 'radio_name'.tr;
      case HomeSection.transcript:
        return 'historico'.tr;
      case HomeSection.news:
        return 'uniteve'.tr;
    }
  }

  static IconData _sectionIcon(HomeSection section) {
    switch (section) {
      case HomeSection.studyPlan:
        return Icons.calendar_today_rounded;
      case HomeSection.restaurant:
        return Icons.restaurant_rounded;
      case HomeSection.shortcuts:
        return Icons.bolt_rounded;
      case HomeSection.radio:
        return Icons.radio_rounded;
      case HomeSection.transcript:
        return Icons.insights_rounded;
      case HomeSection.news:
        return Icons.newspaper_rounded;
    }
  }

  Widget _buildStudyPlanSection(VoidCallback onMenu) {
    return Obx(() {
      final classes = controller.todayClasses.toList(growable: false);
      final isLoading = controller.isLoadingTodayClasses.value;

      return HomeSectionCard(
        icon: _sectionIcon(HomeSection.studyPlan),
        title: _sectionTitle(HomeSection.studyPlan),
        onMenu: onMenu,
        onTap: () => Get.toNamed(Routes.STUDY_PLAN),
        child: isLoading
            ? HomeSectionCard.loading
            : classes.isEmpty
            ? Text('nenhuma_aula_hoje'.tr, style: HomeSectionCard.secondaryText)
            : Column(
                children: classes.map(_buildDisciplineRow).toList(),
              ),
      );
    });
  }

  Widget _buildDisciplineRow(Discipline discipline) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              discipline.title ?? '-',
              maxLines: 2,
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
            style: HomeSectionCard.secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildRestauranteSection(VoidCallback onMenu) {
    return Obx(() {
      final meals = controller.campusMeals.toList(growable: false);
      final isLoading = controller.isLoadingCampusMeals.value;
      final hasDefault = controller.hasDefaultRestaurant.value;
      final meal = meals.isNotEmpty ? meals.first : null;

      VoidCallback? onTap;
      Widget body;
      if (isLoading) {
        body = HomeSectionCard.loading;
      } else if (!hasDefault) {
        onTap = () => Get.toNamed(Routes.BANDEJAPP);
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'defina_restaurante_padrao'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'clique_escolher_refeitorio'.tr,
              style: HomeSectionCard.secondaryText,
            ),
          ],
        );
      } else if (meal != null) {
        onTap = () => Get.to(
          () => MenuPage(location: meal.campus),
          transition: Transition.rightToLeft,
        );
        body = _CampusMealContent(data: meal);
      } else {
        body = Text(
          'cardapio_indisponivel'.tr,
          style: HomeSectionCard.secondaryText,
        );
      }

      return HomeSectionCard(
        icon: _sectionIcon(HomeSection.restaurant),
        title: _sectionTitle(HomeSection.restaurant),
        onMenu: onMenu,
        onTap: onTap,
        child: body,
      );
    });
  }

  Widget _buildShortcutsSection(BuildContext context, VoidCallback onMenu) {
    return Obx(() {
      final shortcuts = controller.savedShortcuts.toList(growable: false);

      return HomeSectionCard(
        icon: _sectionIcon(HomeSection.shortcuts),
        title: _sectionTitle(HomeSection.shortcuts),
        onMenu: onMenu,
        headerAction: TextButton(
          onPressed: _showShortcutEditor,
          child: Text(
            'editar'.tr,
            style: TextStyle(
              color: AppColors.lightBlue(),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        child: shortcuts.isEmpty
            ? Text('atalhos_vazio'.tr, style: HomeSectionCard.secondaryText)
            : _ShortcutGrid(
                shortcuts: shortcuts,
                onOpen: controller.openShortcut,
              ),
      );
    });
  }

  Widget _buildRadioSection(VoidCallback onMenu) {
    return HomeSectionCard(
      icon: _sectionIcon(HomeSection.radio),
      title: _sectionTitle(HomeSection.radio),
      onMenu: onMenu,
      onTap: () => Get.toNamed(Routes.RADIO),
      child: const _RadioPlayerContent(),
    );
  }

  Widget _buildHistoricoSection(VoidCallback onMenu) {
    return Obx(() {
      final stats = controller.transcriptStats.value;
      final isLoading = controller.isLoadingTranscript.value;

      final chCursada = stats?.chCursada ?? 0;
      final chTotal = stats?.chTotal ?? 0;
      final progress = chTotal > 0
          ? (chCursada / chTotal).clamp(0.0, 1.0)
          : 0.0;

      return HomeSectionCard(
        icon: _sectionIcon(HomeSection.transcript),
        title: _sectionTitle(HomeSection.transcript),
        onMenu: onMenu,
        onTap: () => Get.toNamed(Routes.HISTORICO),
        child: isLoading
            ? HomeSectionCard.loading
            : stats == null
            ? Text('dados_indisponiveis'.tr, style: HomeSectionCard.secondaryText)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ],
              ),
      );
    });
  }

  Widget _buildNoticiasSection(VoidCallback onMenu) {
    return Obx(() {
      final items = controller.news.toList(growable: false);
      final isLoading = controller.isLoadingNews.value;

      return HomeSectionCard(
        icon: _sectionIcon(HomeSection.news),
        title: _sectionTitle(HomeSection.news),
        onMenu: onMenu,
        headerAction: IconButton(
          tooltip: 'ver_tudo'.tr,
          onPressed: () => Get.toNamed(Routes.UNITEVE),
          icon: Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        child: isLoading
            ? HomeSectionCard.loading
            : items.isEmpty
            ? Text(
                'noticias_indisponiveis'.tr,
                style: HomeSectionCard.secondaryText,
              )
            : _NewsCarousel(items: items, onOpen: controller.openNews),
      );
    });
  }

  // ---------------- MENUS ----------------

  Future<void> _showSectionMenu(
    HomeSection section, {
    required bool canMoveUp,
    required bool canMoveDown,
  }) async {
    final action = await AppPopups.choose<_SectionAction>(
      title: _sectionTitle(section),
      icon: _sectionIcon(section),
      options: [
        if (canMoveUp)
          PopupOption(
            value: _SectionAction.moveUp,
            label: 'mover_para_cima'.tr,
            icon: Icons.arrow_upward_rounded,
          ),
        if (canMoveDown)
          PopupOption(
            value: _SectionAction.moveDown,
            label: 'mover_para_baixo'.tr,
            icon: Icons.arrow_downward_rounded,
          ),
        PopupOption(
          value: _SectionAction.hide,
          label: 'ocultar_secao'.tr,
          icon: Icons.visibility_off_outlined,
        ),
      ],
    );

    switch (action) {
      case _SectionAction.moveUp:
        controller.moveSection(section, -1);
      case _SectionAction.moveDown:
        controller.moveSection(section, 1);
      case _SectionAction.hide:
        controller.hideSection(section);
        AppPopups.info('secao_ocultada_msg'.tr);
      case null:
        break;
    }
  }

  /// Escolhe uma seção oculta para mostrar de novo, ou restaura o padrão.
  Future<void> _showHiddenSections() async {
    final hidden = controller.sectionOrder
        .where(controller.hiddenSections.contains)
        .toList();

    // `choose` devolve null ao fechar a folha, então "Restaurar padrão" usa
    // um valor próprio (-1) e as seções usam o índice no enum.
    const restoreDefault = -1;
    final choice = await AppPopups.choose<int>(
      title: 'mostrar_secoes_ocultas'.trParams({'n': '${hidden.length}'}),
      icon: Icons.visibility_outlined,
      options: [
        for (final section in hidden)
          PopupOption(
            value: section.index,
            label: _sectionTitle(section),
            icon: _sectionIcon(section),
          ),
        PopupOption(
          value: restoreDefault,
          label: 'restaurar_padrao'.tr,
          icon: Icons.restart_alt_rounded,
        ),
      ],
    );

    if (choice == null) return;
    if (choice == restoreDefault) {
      controller.resetSections();
    } else {
      controller.showSection(HomeSection.values[choice]);
    }
  }

  /// Editor de atalhos: ordenar/remover os salvos e adicionar novos.
  Future<void> _showShortcutEditor() async {
    await AppPopups.sheet<void>(
      title: 'editar_atalhos'.tr,
      icon: Icons.bolt_rounded,
      maxHeightFactor: 0.85,
      child: Obx(() {
        final saved = controller.savedShortcuts.toList(growable: false);
        final available = controller.availableToAdd.toList(growable: false);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _EditorHeader('seus_atalhos'.tr),
            if (saved.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'atalhos_vazio'.tr,
                  style: HomeSectionCard.secondaryText,
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: saved.length,
                onReorderItem: controller.reorderShortcut,
                proxyDecorator: (child, _, _) =>
                    Material(color: Colors.transparent, child: child),
                itemBuilder: (context, index) {
                  final item = saved[index];
                  return _EditorRow(
                    key: ValueKey(item.page),
                    item: item,
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    action: IconButton(
                      tooltip: 'remover'.tr,
                      onPressed: () => controller.removeShortcut(item),
                      icon: const Icon(
                        Icons.remove_circle_rounded,
                        color: Color(0xFFF87171),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            _EditorHeader('adicionar'.tr),
            if (available.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'todos_servicos_salvos'.tr,
                  style: HomeSectionCard.secondaryText,
                ),
              )
            else
              for (final item in available)
                _EditorRow(
                  key: ValueKey('add-${item.page}'),
                  item: item,
                  action: IconButton(
                    tooltip: 'adicionar'.tr,
                    onPressed: () => controller.addShortcut(item),
                    icon: Icon(
                      Icons.add_circle_rounded,
                      color: AppColors.lightBlue(),
                    ),
                  ),
                ),
          ],
        );
      }),
    );
  }
}

// ---------------- WIDGETS ----------------

/// Carrossel de notícias da UniTV: uma por vez, troca sozinho a cada 6 s e
/// pode ser arrastado; as bolinhas mostram a posição.
class _NewsCarousel extends StatefulWidget {
  const _NewsCarousel({required this.items, required this.onOpen});

  final List<HomeNewsItem> items;
  final ValueChanged<HomeNewsItem> onOpen;

  @override
  State<_NewsCarousel> createState() => _NewsCarouselState();
}

class _NewsCarouselState extends State<_NewsCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final current = _current.clamp(0, items.length - 1);

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            viewportFraction: 1,
            aspectRatio: 16 / 9,
            autoPlay: items.length > 1,
            autoPlayInterval: const Duration(seconds: 6),
            enableInfiniteScroll: items.length > 1,
            onPageChanged: (index, _) => setState(() => _current = index),
          ),
          items: [
            for (final item in items)
              _NewsSlide(item: item, onTap: () => widget.onOpen(item)),
          ],
        ),
        if (items.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < items.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == current ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: i == current
                        ? AppColors.lightBlue()
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _NewsSlide extends StatelessWidget {
  const _NewsSlide({required this.item, required this.onTap});

  final HomeNewsItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = item.publishedAt.toLocal();
    final dateLabel =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

    return Semantics(
      button: true,
      label: item.title,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.black,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item.thumbnailUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : ColoredBox(color: AppColors.darkBlue()),
                  errorBuilder: (_, _, _) =>
                      ColoredBox(color: AppColors.darkBlue()),
                ),
                // Degradê para o título ficar legível sobre qualquer capa.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xD9000000)],
                      stops: [0.35, 1],
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(dateLabel, style: HomeSectionCard.secondaryText),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Player da Rádio Pop Goiaba no card: logo, faixa atual e play/pause. Usa o
/// mesmo RadioController (permanente) da tela da rádio.
class _RadioPlayerContent extends StatelessWidget {
  const _RadioPlayerContent();

  static const Color _liveColor = Color(0xFFF87171);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RadioController>()) return const SizedBox.shrink();
    final radio = Get.find<RadioController>();

    return Obx(() {
      final isPlaying = radio.playbackState.value == PlaybackState.playing;
      // Lê o Rx de metadata aqui para o Obx atualizar ao trocar de faixa.
      radio.metadata.value;
      final track = radio.showMetadata();

      return Row(
        children: [
          // Goiaba de fone, a mesma da tela da rádio (fundo transparente).
          Image.asset(
            'assets/radio/images/pop-goiaba_3_sf.png',
            width: 56,
            height: 56,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPlaying
                            ? _liveColor
                            : Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ao_vivo'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  track,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: HomeSectionCard.secondaryText,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.lightBlue(),
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: isPlaying ? 'pausar'.tr : 'tocar'.tr,
              onPressed: radio.toggleState,
              icon: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppColors.darkBlue(),
                size: 28,
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// Conteúdo do restaurante padrão: campus · turno e os itens do cardápio.
class _CampusMealContent extends StatelessWidget {
  const _CampusMealContent({required this.data});

  final TodayCampusMeal data;

  @override
  Widget build(BuildContext context) {
    final meal = data.meal;
    final items = [meal?.main, meal?.garnish, meal?.side]
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final isOpen = data.shiftLabel != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${data.campus.name} · ${isOpen ? data.shiftLabel! : 'fechado'.tr}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        if (items.isEmpty)
          Text(
            'refeicoes_indisponiveis_refeitorio'.tr,
            style: HomeSectionCard.secondaryText,
          )
        else
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '• $item',
                style: HomeSectionCard.secondaryText.copyWith(height: 1.3),
              ),
            ),
      ],
    );
  }
}

/// Grade de atalhos: colunas pela largura e altura pela fonte do sistema, para
/// o rótulo nunca cortar em telas estreitas ou com fonte grande.
class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid({required this.shortcuts, required this.onOpen});

  final List<DashboardShortcut> shortcuts;
  final ValueChanged<DashboardShortcut> onOpen;

  static const double _iconSize = 44;
  static const double _labelSize = 11;
  static const double _labelLineHeight = 1.2;

  @override
  Widget build(BuildContext context) {
    final labelLine = MediaQuery.textScalerOf(context).scale(_labelSize) *
        _labelLineHeight;
    final itemHeight = _iconSize + 6 + labelLine * 2 + 12;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 80).floor().clamp(3, 6);

        return GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: shortcuts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: itemHeight,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            final item = shortcuts[index];
            return InkWell(
              key: ValueKey(item.page),
              borderRadius: BorderRadius.circular(12),
              onTap: () => onOpen(item),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    _ServiceIcon(iconSrc: item.iconSrc, size: _iconSize),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle.tr,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: _labelSize,
                        fontWeight: FontWeight.w600,
                        height: _labelLineHeight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.55),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _EditorRow extends StatelessWidget {
  const _EditorRow({
    super.key,
    required this.item,
    required this.action,
    this.leading,
  });

  final DashboardShortcut item;
  final Widget action;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          _ServiceIcon(iconSrc: item.iconSrc, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.subtitle.tr,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          action,
        ],
      ),
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon({required this.iconSrc, this.size = 32});

  final String iconSrc;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: AppColors.lightBlue().withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      padding: EdgeInsets.all(size * 0.2),
      child: iconSrc.endsWith('.svg')
          ? SvgPicture.asset(
              iconSrc,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              fit: BoxFit.contain,
            )
          : Image.asset(iconSrc, color: Colors.white, fit: BoxFit.contain),
    );
  }
}
