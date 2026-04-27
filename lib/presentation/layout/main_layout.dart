import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/responsive/responsive_layout.dart';
import '../alerts/bloc/alerts_bloc.dart';
import '../alerts/bloc/alerts_state.dart';
import 'widgets/side_menu.dart';
import 'widgets/top_bar.dart';

/// Main application layout with responsive sidebar
class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isSidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenUtils.isDesktop(context);
    final isTablet = ScreenUtils.isTablet(context);

    return BlocBuilder<AlertsBloc, AlertsState>(
      builder: (context, alertsState) {
        final alertCount =
            alertsState is AlertsLoaded ? alertsState.totalCount : 0;

        // Mobile: Use drawer instead of sidebar
        if (!isDesktop && !isTablet) {
          return Scaffold(
            key: _scaffoldKey,
            body: Column(
              children: [
                TopBar(
                  onMenuToggle: _toggleSidebar,
                  isSidebarCollapsed: _isSidebarCollapsed,
                  showMobileMenu: true,
                  onMobileMenuTap: _openDrawer,
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: widget.child,
                  ),
                ),
              ],
            ),
            drawer: Drawer(
              child: SideMenu(
                alertCount: alertCount,
                isCollapsed: false,
                onCollapseToggle: _toggleSidebar,
                isMobile: true,
              ),
            ),
          );
        }

        // Tablet/Desktop: Use sidebar
        return Scaffold(
          body: Row(
            children: [
              // Sidebar (animated width)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: _isSidebarCollapsed
                    ? AppSizes.sidebarCollapsedWidth
                    : AppSizes.sidebarExpandedWidth,
                child: SideMenu(
                  alertCount: alertCount,
                  isCollapsed: _isSidebarCollapsed,
                  onCollapseToggle: isTablet ? _toggleSidebar : null,
                ),
              ),
              // Main content
              Expanded(
                child: Column(
                  children: [
                    TopBar(
                      onMenuToggle: _toggleSidebar,
                      isSidebarCollapsed: _isSidebarCollapsed,
                      showMobileMenu: false,
                      onMobileMenuTap: _openDrawer,
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
      },
    );
  }
}
