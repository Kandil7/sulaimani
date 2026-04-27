import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/responsive/responsive_layout.dart';
import '../alerts/bloc/alerts_bloc.dart';
import '../alerts/bloc/alerts_state.dart';
import '../alerts/bloc/alerts_event.dart';
import 'widgets/side_menu.dart';
import 'widgets/top_bar.dart';

/// Main application layout with responsive sidebar
class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  bool _isSidebarCollapsed = false;
  bool _isMobileSidebarOpen = false;
  late AnimationController _animationController;
  late Animation<double> _sidebarAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _sidebarAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
      if (_isSidebarCollapsed) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  void _toggleMobileSidebar() {
    setState(() {
      _isMobileSidebarOpen = !_isMobileSidebarOpen;
    });
  }

  void _closeMobileSidebar() {
    setState(() {
      _isMobileSidebarOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenUtils.isDesktop(context);

    return BlocBuilder<AlertsBloc, AlertsState>(
      builder: (context, alertsState) {
        final alertCount =
            alertsState is AlertsLoaded ? alertsState.totalCount : 0;

        if (isDesktop) {
          // Desktop layout with animated sidebar
          return Scaffold(
            body: AnimatedBuilder(
              animation: _sidebarAnimation,
              builder: (context, child) {
                return Row(
                  children: [
                    // Animated sidebar
                    SizeTransition(
                      sizeFactor: _sidebarAnimation,
                      axisAlignment: -1.0,
                      child: SideMenu(
                        alertCount: alertCount,
                        isCollapsed: _isSidebarCollapsed,
                        onCollapseToggle: _toggleSidebar,
                      ),
                    ),
                    // Main content
                    Expanded(
                      child: Column(
                        children: [
                          TopBar(
                            onMenuToggle: _toggleSidebar,
                            isSidebarCollapsed: _isSidebarCollapsed,
                          ),
                          Expanded(
                            child: Container(
                              color: Theme.of(context).colorScheme.surface,
                              child: widget.child,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        } else {
          // Mobile/Tablet layout with drawer
          return Scaffold(
            body: Row(
              children: [
                // Mobile sidebar (always visible but narrower)
                SizedBox(
                  width: _isSidebarCollapsed ? 72 : 220,
                  child: SideMenu(
                    alertCount: alertCount,
                    isCollapsed: _isSidebarCollapsed,
                    onCollapseToggle: _toggleSidebar,
                    isMobile: true,
                  ),
                ),
                // Main content
                Expanded(
                  child: Column(
                    children: [
                      TopBar(
                        onMenuToggle: _toggleSidebar,
                        isSidebarCollapsed: _isSidebarCollapsed,
                        showMobileMenu: true,
                        onMobileMenuTap: _toggleMobileSidebar,
                      ),
                      Expanded(
                        child: Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: widget.child,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

/// Custom page transitions for smoother navigation
class FadePageTransition extends CustomTransitionPage {
  FadePageTransition({
    required super.child,
    super.key,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 200),
        );
}

/// Slide page transition
class SlidePageTransition extends CustomTransitionPage {
  SlidePageTransition({
    required super.child,
    super.key,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        );
}
