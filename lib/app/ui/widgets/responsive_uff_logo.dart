import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ResponsiveUffLogo extends StatefulWidget {
  const ResponsiveUffLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.padding,
    this.showBackgroundCard = false,
    this.cardColor,
    this.animate = true,
  });

  final double? width;
  final double? height;
  final BoxFit fit;
  final EdgeInsetsGeometry? padding;
  final bool showBackgroundCard;
  final Color? cardColor;
  final bool animate;

  @override
  State<ResponsiveUffLogo> createState() => _ResponsiveUffLogoState();
}

class _ResponsiveUffLogoState extends State<ResponsiveUffLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _translateYAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _translateYAnimation = Tween<double>(
      begin: -6.0,
      end: 6.0,
    ).animate(curved);
    _scaleAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(curved);
    _opacityAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(curved);

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ResponsiveUffLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double svgAspectRatio = 1000.0 / 739.74; // ~1.3518

    final double defaultWidth;
    final double defaultHeight;

    if (widget.width != null && widget.height != null) {
      defaultWidth = widget.width!;
      defaultHeight = widget.height!;
    } else if (widget.width != null) {
      defaultWidth = widget.width!;
      defaultHeight = widget.width! / svgAspectRatio;
    } else if (widget.height != null) {
      defaultHeight = widget.height!;
      defaultWidth = widget.height! * svgAspectRatio;
    } else {
      defaultWidth = (screenWidth * 0.55).clamp(120.0, 360.0);
      defaultHeight = defaultWidth / svgAspectRatio;
    }

    Widget svgCore = Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: SvgPicture.asset(
        'assets/logos/uff_logo.svg',
        width: defaultWidth,
        height: defaultHeight,
        fit: widget.fit,
        alignment: Alignment.center,
      ),
    );

    Widget animatedLogo = widget.animate
        ? AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _translateYAnimation.value),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: child,
                  ),
                ),
              );
            },
            child: svgCore,
          )
        : svgCore;

    if (widget.showBackgroundCard) {
      return Card(
        color: widget.cardColor ?? Colors.white.withOpacity(0.12),
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: animatedLogo,
        ),
      );
    }

    return SizedBox(
      width: defaultWidth,
      height: defaultHeight,
      child: Center(child: animatedLogo),
    );
  }
}
