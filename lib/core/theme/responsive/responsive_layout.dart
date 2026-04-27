import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// Responsive layout widget that switches between mobile, tablet, and desktop
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.tablet) {
          return desktop;
        } else if (constraints.maxWidth >= Breakpoints.mobile) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Screen size helpers
class ScreenUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < Breakpoints.mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.mobile &&
      MediaQuery.of(context).size.width < Breakpoints.tablet;

  static bool isTabletOrBelow(BuildContext context) =>
      MediaQuery.of(context).size.width < Breakpoints.tablet;

  static bool isDesktopS(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.tablet &&
      MediaQuery.of(context).size.width < Breakpoints.desktopS;

  static bool isDesktopM(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.desktopS &&
      MediaQuery.of(context).size.width < Breakpoints.desktopM;

  static bool isDesktopL(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.desktopM;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.tablet;

  /// Get current screen width
  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Get current screen height
  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Get safe area padding
  static EdgeInsets getPadding(BuildContext context) =>
      MediaQuery.of(context).padding;

  /// Get device pixel ratio
  static double getDevicePixelRatio(BuildContext context) =>
      MediaQuery.of(context).devicePixelRatio;

  /// Check if orientation is landscape
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Check if orientation is portrait
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// Get responsive value based on screen size
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.tablet) {
      return desktop;
    } else if (width >= Breakpoints.mobile) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  /// Get responsive value for grid columns
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.desktopM) {
      return 5;
    } else if (width >= Breakpoints.desktopS) {
      return 4;
    } else if (width >= Breakpoints.tablet) {
      return 3;
    } else if (width >= Breakpoints.mobile) {
      return 2;
    }
    return 1;
  }

  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.desktopM) {
      return 1.1;
    } else if (width >= Breakpoints.desktopS) {
      return 1.05;
    } else if (width >= Breakpoints.tablet) {
      return 1.0;
    } else if (width >= Breakpoints.mobile) {
      return 0.9;
    }
    return 0.85;
  }

  /// Get responsive spacing value
  static double getSpacing(BuildContext context, {double? base}) {
    final multiplier = getFontSizeMultiplier(context);
    return (base ?? 16.0) * multiplier;
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, {double? base}) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.desktopM) {
      return (base ?? 24.0) * 1.1;
    } else if (width >= Breakpoints.desktopS) {
      return base ?? 24.0;
    } else if (width >= Breakpoints.tablet) {
      return (base ?? 24.0) * 0.95;
    }
    return (base ?? 24.0) * 0.85;
  }

  /// Get responsive value with custom breakpoints
  static T responsiveByWidth<T>(
    BuildContext context, {
    required T small,
    required T medium,
    required T large,
    double? smallBreakpoint,
    double? largeBreakpoint,
  }) {
    final width = MediaQuery.of(context).size.width;
    final mediumBP = smallBreakpoint ?? Breakpoints.tablet;
    final largeBP = largeBreakpoint ?? Breakpoints.desktopS;

    if (width >= largeBP) {
      return large;
    } else if (width >= mediumBP) {
      return medium;
    }
    return small;
  }
}

/// Responsive flex ratio helper
class ResponsiveFlex {
  /// Get flex values for Row/Column layouts
  /// Returns (mainFlex, sideFlex) tuple
  static (int, int) getFlex(
    BuildContext context, {
    int desktopFlex = 3,
    int tabletFlex = 2,
    int mobileFlex = 1,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width >= Breakpoints.desktopS) {
      return (desktopFlex, desktopFlex > 1 ? 1 : 0);
    } else if (width >= Breakpoints.tablet) {
      return (tabletFlex, tabletFlex > 1 ? 1 : 0);
    }
    return (mobileFlex, 0);
  }

  /// Get flex for two-panel layout (like POS)
  static (int, int) getTwoPanelFlex(
    BuildContext context, {
    int desktopSmallFlex = 4,
    int desktopLargeFlex = 6,
    int tabletSmallFlex = 5,
    int tabletLargeFlex = 5,
    int mobileSmallFlex = 1,
    int mobileLargeFlex = 1,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width >= Breakpoints.desktopS) {
      return (desktopSmallFlex, desktopLargeFlex);
    } else if (width >= Breakpoints.tablet) {
      return (tabletSmallFlex, tabletLargeFlex);
    }
    return (mobileSmallFlex, mobileLargeFlex);
  }
}

/// Responsive card/panel grid
class ResponsiveGrid {
  /// Get number of columns for grid layout
  static int getColumns(
    BuildContext context, {
    int desktopColumns = 4,
    int tabletColumns = 3,
    int mobileColumns = 2,
    double minItemWidth = 200,
  }) {
    final width = MediaQuery.of(context).size.width;
    final padding = ScreenUtils.isDesktop(context) ? 48.0 : 16.0;
    final availableWidth = width - padding;

    final calculatedColumns = (availableWidth / minItemWidth).floor();
    return calculatedColumns.clamp(1, desktopColumns);
  }

  /// Get aspect ratio for cards
  static double getAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.desktopM) {
      return 1.4;
    } else if (width >= Breakpoints.desktopS) {
      return 1.3;
    } else if (width >= Breakpoints.tablet) {
      return 1.2;
    }
    return 1.0;
  }
}

/// Responsive padding helper
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? mobile;
  final double? tablet;
  final double? desktop;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        ScreenUtils.responsive(
          context,
          mobile: mobile ?? 8,
          tablet: tablet ?? 16,
          desktop: desktop ?? 24,
        ),
      ),
      child: child,
    );
  }
}

/// Responsive alignment helper
class ResponsiveAlign extends StatelessWidget {
  final Widget child;
  final Alignment? mobile;
  final Alignment? tablet;
  final Alignment? desktop;

  const ResponsiveAlign({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: ScreenUtils.responsive(
        context,
        mobile: mobile ?? Alignment.center,
        tablet: tablet ?? Alignment.center,
        desktop: desktop ?? Alignment.center,
      ),
      child: child,
    );
  }
}

/// Responsive visibility helper
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool? visibleOnMobile;
  final bool? visibleOnTablet;
  final bool? visibleOnDesktop;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleOnMobile,
    this.visibleOnTablet,
    this.visibleOnDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    bool isVisible = true;

    if (width < Breakpoints.mobile) {
      isVisible = visibleOnMobile ?? true;
    } else if (width < Breakpoints.tablet) {
      isVisible = visibleOnTablet ?? true;
    } else {
      isVisible = visibleOnDesktop ?? true;
    }

    return isVisible ? child : const SizedBox.shrink();
  }
}

/// Animated responsive container that changes based on screen size
class AnimatedResponsiveContainer extends StatefulWidget {
  final Widget Function(BuildContext context, double width) builder;
  final Duration duration;

  const AnimatedResponsiveContainer({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedResponsiveContainer> createState() =>
      _AnimatedResponsiveContainerState();
}

class _AnimatedResponsiveContainerState
    extends State<AnimatedResponsiveContainer> {
  double _previousWidth = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (_previousWidth != width && _previousWidth > 0) {
      return AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeInOut,
        child: widget.builder(context, width),
      );
    }

    _previousWidth = width;
    return widget.builder(context, width);
  }
}
