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
