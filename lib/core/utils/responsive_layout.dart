import 'package:flutter/material.dart';

enum ScreenType { mobile, tablet }

extension ScreenTypeX on ScreenType {
  bool get isMobile => this == ScreenType.mobile;
  bool get isTablet => this == ScreenType.tablet;
}

typedef ResponsiveBuilder =
    Widget Function(BuildContext context, ScreenType screenType);

class ResponsiveLayout extends StatelessWidget {
  final ResponsiveBuilder builder;

  const ResponsiveLayout({super.key, required this.builder});

  static const double mobileBreakpoint = 600;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint;

  static ScreenType getScreenType(BuildContext context) =>
      isMobile(context) ? ScreenType.mobile : ScreenType.tablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = constraints.maxWidth < mobileBreakpoint
            ? ScreenType.mobile
            : ScreenType.tablet;
        return builder(context, screenType);
      },
    );
  }
}
