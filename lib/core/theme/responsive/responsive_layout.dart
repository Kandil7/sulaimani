import 'package:flutter/material.dart';
import 'breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < Breakpoints.mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.mobile &&
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
