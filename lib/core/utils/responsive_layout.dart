import 'package:flutter/material.dart';

/// Screen size breakpoints
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1200;
  static const double desktop = 1800;
}

/// Screen size enum
enum ScreenSize { mobile, tablet, desktop, ultraWide }

/// Get current screen size based on width
ScreenSize getScreenSize(double width) {
  if (width < Breakpoints.mobile) {
    return ScreenSize.mobile;
  } else if (width < Breakpoints.tablet) {
    return ScreenSize.tablet;
  } else if (width < Breakpoints.desktop) {
    return ScreenSize.desktop;
  } else {
    return ScreenSize.ultraWide;
  }
}

/// Responsive value based on screen size
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? ultraWide;

  ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.ultraWide,
  });

  T getValue(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.ultraWide:
        return ultraWide ?? desktop ?? tablet ?? mobile;
    }
  }
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = getScreenSize(constraints.maxWidth);
        return builder(context, screenSize);
      },
    );
  }
}

/// Responsive layout widget with different layouts per screen size
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? ultraWide;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.ultraWide,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        switch (screenSize) {
          case ScreenSize.mobile:
            return mobile;
          case ScreenSize.tablet:
            return tablet ?? mobile;
          case ScreenSize.desktop:
            return desktop ?? tablet ?? mobile;
          case ScreenSize.ultraWide:
            return ultraWide ?? desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}

/// Responsive padding
class ResponsivePadding {
  static EdgeInsets all(
    BuildContext context, {
    double mobile = 16.0,
    double? tablet,
    double? desktop,
  }) {
    return EdgeInsets.all(_getValue(context, mobile, tablet, desktop));
  }

  static EdgeInsets symmetric(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
    double? horizontalTablet,
    double? horizontalDesktop,
    double? verticalTablet,
    double? verticalDesktop,
  }) {
    final size = MediaQuery.of(context).size.width;
    final screenSize = getScreenSize(size);

    double h = horizontal;
    double v = vertical;

    if (screenSize == ScreenSize.tablet || screenSize == ScreenSize.desktop) {
      h = horizontalTablet ?? horizontal;
      v = verticalTablet ?? vertical;
    }

    if (screenSize == ScreenSize.desktop ||
        screenSize == ScreenSize.ultraWide) {
      h = horizontalDesktop ?? horizontalTablet ?? horizontal;
      v = verticalDesktop ?? verticalTablet ?? vertical;
    }

    return EdgeInsets.symmetric(horizontal: h, vertical: v);
  }

  static double _getValue(
    BuildContext context,
    double mobile,
    double? tablet,
    double? desktop,
  ) {
    final size = MediaQuery.of(context).size.width;
    final screenSize = getScreenSize(size);

    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.desktop:
      case ScreenSize.ultraWide:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// Responsive spacing
class ResponsiveSpacing {
  static double value(
    BuildContext context, {
    double mobile = 8.0,
    double? tablet,
    double? desktop,
  }) {
    final size = MediaQuery.of(context).size.width;
    final screenSize = getScreenSize(size);

    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.desktop:
      case ScreenSize.ultraWide:
        return desktop ?? tablet ?? mobile;
    }
  }

  static SizedBox vertical(
    BuildContext context, {
    double mobile = 8.0,
    double? tablet,
    double? desktop,
  }) {
    return SizedBox(
      height: value(context, mobile: mobile, tablet: tablet, desktop: desktop),
    );
  }

  static SizedBox horizontal(
    BuildContext context, {
    double mobile = 8.0,
    double? tablet,
    double? desktop,
  }) {
    return SizedBox(
      width: value(context, mobile: mobile, tablet: tablet, desktop: desktop),
    );
  }
}

/// Extension for responsive values
extension ResponsiveExtension on BuildContext {
  ScreenSize get screenSize => getScreenSize(MediaQuery.of(this).size.width);

  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isDesktop =>
      screenSize == ScreenSize.desktop || screenSize == ScreenSize.ultraWide;

  double responsiveValue({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.desktop:
      case ScreenSize.ultraWide:
        return desktop ?? tablet ?? mobile;
    }
  }
}
