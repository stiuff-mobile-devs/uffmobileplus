import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/translations/language_service.dart';

/// Item padrão do menu lateral e das Configurações (mesmo visual nos dois).
class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    this.icon,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.destructive = false,
  }) : assert(icon != null || leading != null);

  final IconData? icon;

  /// Conteúdo da caixa 40×40 à esquerda, no lugar de [icon] (ex.: bandeira).
  final Widget? leading;
  final String title;
  final String? subtitle;

  /// Padrão: seta para a direita.
  final Widget? trailing;
  final VoidCallback onTap;

  /// Ação perigosa (ex.: sair): ícone e título em vermelho.
  final bool destructive;

  static const Color _destructiveColor = Color(0xFFF87171);

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? _destructiveColor : AppColors.lightBlue();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: destructive
            ? _destructiveColor.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
          leading: Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: leading ?? Icon(icon, color: accent, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: destructive
                  ? _destructiveColor
                  : Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          subtitle: subtitle == null
              ? null
              : Text(
                  subtitle!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 12,
                  ),
                ),
          trailing:
              trailing ??
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.45),
              ),
        ),
      ),
    );
  }
}

/// Título pequeno de seção (ex.: CONTA, PREFERÊNCIAS).
class MenuSectionHeader extends StatelessWidget {
  const MenuSectionHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 8),
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

/// Idioma atual (bandeira + nome) no mesmo padrão dos outros itens.
class LanguageMenuTile extends StatelessWidget {
  const LanguageMenuTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currentLanguage = LanguageService.getCurrentLanguage();

    return MenuTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 24,
          height: 16,
          child: SvgPicture.asset(currentLanguage.flagAsset, fit: BoxFit.cover),
        ),
      ),
      title: currentLanguage.nativeName,
      subtitle: 'ling_descricao'.tr,
      onTap: onTap,
    );
  }
}
