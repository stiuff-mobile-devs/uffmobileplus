import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

/// Tipo de um pop-up: define o ícone e a cor de destaque.
enum PopupType { success, error, warning, info }

/// Uma opção de [AppPopups.choose].
class PopupOption<T> {
  final T value;
  final String label;
  final String? description;
  final IconData? icon;
  final Color? color;

  const PopupOption({
    required this.value,
    required this.label,
    this.description,
    this.icon,
    this.color,
  });
}

/// Ponto único para todos os pop-ups do app (snackbars, diálogos, bottom
/// sheets e carregamento). Nunca monte AlertDialog/SnackBar/showModalBottomSheet
/// direto nas telas.
///
/// Visual: sempre o azul-escuro da marca, independente do ThemeData global.
/// Todos os métodos usam `Get.context`, então podem ser chamados de controllers.
/// Dentro das folhas, feche com `Navigator.of(ctx).pop(valor)` usando o `ctx`
/// da folha, nunca com `Get.back()`.
class AppPopups {
  AppPopups._();

  static BuildContext get _context => Get.context!;

  /// Tema escuro da marca aplicado dentro de diálogos e folhas.
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.mediumBlue(),
      onPrimary: Colors.white,
      primaryContainer: AppColors.alternativeMediumBlue(),
      onPrimaryContainer: Colors.white,
      error: Colors.redAccent,
      onError: Colors.white,
      surface: AppColors.darkBlue(),
      onSurface: Colors.white,
      onSurfaceVariant: Colors.white70,
      surfaceContainerHighest: Colors.white.withValues(alpha: 0.08),
      outlineVariant: Colors.white.withValues(alpha: 0.14),
    ),
  );

  static Widget _themed(Widget child) => Theme(data: theme, child: child);

  // ---------------- SNACKBARS ----------------

  static void success(String message, {String? title}) =>
      show(message, title: title, type: PopupType.success);
  static void error(String message, {String? title}) =>
      show(message, title: title, type: PopupType.error);
  static void warning(String message, {String? title}) =>
      show(message, title: title, type: PopupType.warning);
  static void info(String message, {String? title}) =>
      show(message, title: title, type: PopupType.info);

  /// Usa o ScaffoldMessenger (e não o GetSnackBar) para não interferir no
  /// `Get.back()` das telas.
  static void show(
    String message, {
    String? title,
    PopupType type = PopupType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    final context = Get.context;
    final messenger =
        context == null ? null : ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      debugPrint('AppPopups: sem ScaffoldMessenger para mostrar "$message"');
      return;
    }
    final accent = _snackAccent(type);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          backgroundColor: const Color(0xFF1F2128),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          dismissDirection: DismissDirection.horizontal,
          duration: duration ??
              (type == PopupType.error
                  ? const Duration(seconds: 4)
                  : const Duration(seconds: 3)),
          content: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon(type), color: accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    Text(
                      message,
                      style: TextStyle(
                        color: title == null ? Colors.white : Colors.white70,
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          action: actionLabel == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  textColor: accent,
                  onPressed: onAction ?? () {},
                ),
        ),
      );
  }

  static void clear() {
    final context = Get.context;
    if (context == null) return;
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
  }

  // ---------------- DIÁLOGO CENTRAL ----------------

  /// Aviso centralizado. Retorna true se o botão principal foi tocado.
  /// Com [cancelText] mostra também o botão secundário.
  static Future<bool> alert({
    required String title,
    String? message,
    Widget? content,
    IconData? icon,
    PopupType type = PopupType.info,
    String? confirmText,
    String? cancelText,
    bool dismissible = true,
  }) async {
    final result = await showDialog<bool>(
      context: _context,
      barrierDismissible: dismissible,
      builder: (_) => _themed(
        Builder(
          builder: (ctx) {
            final scheme = Theme.of(ctx).colorScheme;
            final accent = _accent(ctx, type);
            return PopScope(
              canPop: dismissible,
              child: AlertDialog(
                backgroundColor: scheme.surface,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                icon: _IconBadge(icon: icon ?? _sheetIcon(type), color: accent),
                title: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                ),
                content: content ??
                    (message == null
                        ? null
                        : Text(
                            message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          )),
                actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                actions: [
                  Row(
                    children: [
                      if (cancelText != null) ...[
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: scheme.onSurfaceVariant,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text(cancelText),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: _onColor(accent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(confirmText ?? 'ok'.tr),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    return result ?? false;
  }

  // ---------------- BOTTOM SHEETS ----------------

  /// Folha padrão. `actions` recebe o context da folha
  /// (use `Navigator.of(ctx).pop(valor)`).
  static Future<T?> sheet<T>({
    String? title,
    String? message,
    IconData? icon,
    PopupType type = PopupType.info,
    Widget? child,
    List<Widget> Function(BuildContext ctx)? actions,
    bool dismissible = true,
    double maxHeightFactor = 0.9,
  }) {
    return _showSheet<T>(
      dismissible: dismissible,
      builder: (ctx) => AppSheet(
        title: title,
        message: message,
        icon: icon,
        iconColor: _accent(ctx, type),
        maxHeightFactor: maxHeightFactor,
        actions: actions?.call(ctx),
        child: child,
      ),
    );
  }

  /// Folha "crua" com o widget informado (use [AppSheet] por dentro).
  static Future<T?> custom<T>(Widget child, {bool dismissible = true}) {
    return _showSheet<T>(dismissible: dismissible, builder: (_) => child);
  }

  static Future<T?> _showSheet<T>({
    required bool dismissible,
    required WidgetBuilder builder,
  }) {
    return showModalBottomSheet<T>(
      context: _context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      isDismissible: dismissible,
      enableDrag: dismissible,
      backgroundColor: AppColors.darkBlue(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _themed(
        PopScope(
          canPop: dismissible,
          child: Builder(
            builder: (ctx) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DragHandle(visible: dismissible),
                Flexible(child: builder(ctx)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Confirmação sim/não em folha. Retorna true se confirmou.
  static Future<bool> confirm({
    required String title,
    String? message,
    IconData icon = Icons.help_outline_rounded,
    String? confirmText,
    String? cancelText,
    bool destructive = false,
    PopupType? type,
    bool dismissible = true,
    Widget? child,
  }) async {
    final result = await sheet<bool>(
      title: title,
      message: message,
      icon: icon,
      type: type ?? (destructive ? PopupType.error : PopupType.info),
      dismissible: dismissible,
      child: child,
      actions: (ctx) => [
        AppSheetButton.primary(
          label: confirmText ?? 'confirmar'.tr,
          destructive: destructive,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
        AppSheetButton.secondary(
          label: cancelText ?? 'cancelar'.tr,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
      ],
    );
    return result ?? false;
  }

  /// Pede um texto. Retorna o texto (com trim) ou null se cancelar.
  static Future<String?> input({
    required String title,
    String? message,
    String? hint,
    String? initialValue,
    IconData icon = Icons.edit_note_rounded,
    PopupType type = PopupType.info,
    String? confirmText,
    int maxLines = 1,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await sheet<String>(
      title: title,
      message: message,
      icon: icon,
      type: type,
      child: Builder(
        builder: (ctx) => TextField(
          controller: controller,
          autofocus: true,
          maxLines: maxLines,
          textInputAction:
              maxLines == 1 ? TextInputAction.done : TextInputAction.newline,
          onSubmitted:
              maxLines == 1 ? (v) => Navigator.of(ctx).pop(v.trim()) : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      actions: (ctx) => [
        AppSheetButton.primary(
          label: confirmText ?? 'confirmar'.tr,
          onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
        ),
        AppSheetButton.secondary(
          label: 'cancelar'.tr,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ],
    );
    controller.dispose();
    return result;
  }

  /// Lista de opções. Retorna o valor escolhido ou null.
  static Future<T?> choose<T>({
    required String title,
    String? message,
    IconData? icon,
    required List<PopupOption<T>> options,
    T? selected,
    bool dismissible = true,
  }) {
    return sheet<T>(
      title: title,
      message: message,
      icon: icon,
      dismissible: dismissible,
      child: Builder(
        builder: (ctx) {
          final scheme = Theme.of(ctx).colorScheme;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((o) {
              final isSelected = o.value == selected;
              final color = o.color ?? scheme.onSurface;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isSelected
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    leading: o.icon == null ? null : Icon(o.icon, color: color),
                    title: Text(
                      o.label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle:
                        o.description == null ? null : Text(o.description!),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: scheme.primary)
                        : null,
                    onTap: () => Navigator.of(ctx).pop(o.value),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ---------------- CARREGAMENTO ----------------

  static bool _isLoadingOpen = false;

  /// Diálogo de carregamento que não fecha. Chamar duas vezes não empilha.
  static void showLoading([String? message]) {
    if (_isLoadingOpen) return;
    _isLoadingOpen = true;
    showDialog<void>(
      context: _context,
      barrierDismissible: false,
      builder: (_) => _themed(
        Builder(
          builder: (ctx) {
            final scheme = Theme.of(ctx).colorScheme;
            return PopScope(
              canPop: false,
              child: Dialog(
                backgroundColor: scheme.surface,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          color: scheme.onSurface,
                          strokeWidth: 3,
                        ),
                      ),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ).whenComplete(() => _isLoadingOpen = false);
  }

  /// Fecha o carregamento. Sem carregamento aberto, não faz nada.
  static void hideLoading() {
    if (!_isLoadingOpen) return;
    _isLoadingOpen = false;
    Navigator.of(_context).pop();
  }

  // ---------------- CORES E ÍCONES ----------------

  static IconData _icon(PopupType t) => switch (t) {
        PopupType.success => Icons.check_rounded,
        PopupType.error => Icons.close_rounded,
        PopupType.warning => Icons.priority_high_rounded,
        PopupType.info => Icons.info_outline_rounded,
      };

  static IconData _sheetIcon(PopupType t) => switch (t) {
        PopupType.success => Icons.check_circle_outline_rounded,
        PopupType.error => Icons.error_outline_rounded,
        PopupType.warning => Icons.warning_amber_rounded,
        PopupType.info => Icons.info_outline_rounded,
      };

  // Snackbar: fundo sempre escuro, então as cores são fixas e claras
  static Color _snackAccent(PopupType t) => switch (t) {
        PopupType.success => const Color(0xFF4ADE80),
        PopupType.error => const Color(0xFFF87171),
        PopupType.warning => const Color(0xFFFBBF24),
        PopupType.info => const Color(0xFF60A5FA),
      };

  // Diálogos e folhas: cores do tema escuro da marca
  static Color _accent(BuildContext context, PopupType t) {
    final scheme = Theme.of(context).colorScheme;
    return switch (t) {
      PopupType.success => Colors.green.shade400,
      PopupType.error => scheme.error,
      PopupType.warning => Colors.amber.shade600,
      PopupType.info => scheme.primary,
    };
  }

  static Color _onColor(Color bg) =>
      ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
          ? Colors.white
          : Colors.black;
}

/// Conteúdo padrão de uma folha: ícone, título, mensagem, conteúdo rolável e
/// botões empilhados. Sobe com o teclado e respeita [maxHeightFactor].
class AppSheet extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final Color? iconColor;
  final Widget? child;
  final List<Widget>? actions;
  final double maxHeightFactor;

  const AppSheet({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.iconColor,
    this.child,
    this.actions,
    this.maxHeightFactor = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: media.size.height * maxHeightFactor,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + media.padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (icon != null) ...[
                Center(
                  child: _IconBadge(
                    icon: icon!,
                    color: iconColor ?? scheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (title != null)
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
              if (child != null) ...[
                const SizedBox(height: 20),
                Flexible(child: SingleChildScrollView(child: child)),
              ],
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 20),
                for (int i = 0; i < actions!.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  actions![i],
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Botões de largura total usados nas folhas (só construtores nomeados).
class AppSheetButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool destructive;

  const AppSheetButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.destructive = false,
  }) : primary = true;

  const AppSheetButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
  })  : primary = false,
        destructive = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    const size = Size.fromHeight(52);
    const textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    if (primary) {
      return FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: size,
          shape: shape,
          textStyle: textStyle,
          backgroundColor: destructive ? scheme.error : scheme.primary,
          foregroundColor: destructive ? scheme.onError : scheme.onPrimary,
        ),
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: size,
        shape: shape,
        textStyle: textStyle,
        foregroundColor: scheme.onSurfaceVariant,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class _DragHandle extends StatelessWidget {
  final bool visible;
  const _DragHandle({required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox(height: 24);
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 14),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 28),
      );
}
