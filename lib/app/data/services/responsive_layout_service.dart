import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResponsiveLayoutService extends GetxService {
  ResponsiveGridSpec gridSpecForWidth({
    required double width,
    required ResponsiveGridConfig config,
  }) {
    final sortedBreakpoints = List<ResponsiveGridBreakpoint>.from(
      config.breakpoints,
    )..sort((a, b) => a.maxWidth.compareTo(b.maxWidth));

    for (final breakpoint in sortedBreakpoints) {
      if (width <= breakpoint.maxWidth) {
        return breakpoint.spec;
      }
    }

    return config.defaultSpec;
  }

  double bottomPadding({
    required double safeBottom,
    double navBarHeight = kBottomNavigationBarHeight,
    double basePadding = 24,
  }) {
    return safeBottom + navBarHeight + basePadding;
  }
}

@immutable
class ResponsiveGridConfig {
  const ResponsiveGridConfig({
    required this.breakpoints,
    required this.defaultSpec,
  });

  final List<ResponsiveGridBreakpoint> breakpoints;
  final ResponsiveGridSpec defaultSpec;
}

@immutable
class ResponsiveGridBreakpoint {
  const ResponsiveGridBreakpoint({
    required this.maxWidth,
    required this.spec,
  });

  final double maxWidth;
  final ResponsiveGridSpec spec;
}

@immutable
class ResponsiveGridSpec {
  const ResponsiveGridSpec({
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.cardPadding,
    required this.iconBoxSize,
    required this.iconPadding,
    required this.iconBorderRadius,
    required this.labelFontSize,
    required this.labelHeight,
    required this.iconLabelSpacing,
  });

  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsets cardPadding;
  final double iconBoxSize;
  final double iconPadding;
  final double iconBorderRadius;
  final double labelFontSize;
  final double labelHeight;
  final double iconLabelSpacing;
}
