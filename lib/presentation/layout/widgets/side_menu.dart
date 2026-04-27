import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../settings/widgets/global_search_dialog.dart';

class SideMenu extends StatelessWidget {
  final int alertCount;
  final bool isCollapsed;
  final VoidCallback? onCollapseToggle;
  final bool isMobile;

  const SideMenu({
    super.key,
    this.alertCount = 0,
    this.isCollapsed = false,
    this.onCollapseToggle,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();
    final isExpanded = !isCollapsed;

    // For mobile drawer, always show expanded
    if (isMobile) {
      return _buildMobileMenu(context, currentPath);
    }

    // Desktop/Tablet sidebar
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _LogoHeader(
            isExpanded: isExpanded,
            onToggle: onCollapseToggle,
          ),
          const SizedBox(height: AppSizes.md),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.dashboard_outlined,
                    title: AppStrings.dashboard,
                    isExpanded: isExpanded,
                    isActive: currentPath == '/',
                    onTap: () => context.go('/'),
                  ),
                  _MenuItem(
                    icon: Icons.point_of_sale_outlined,
                    title: 'نقطة البيع',
                    isExpanded: isExpanded,
                    isActive: currentPath.startsWith('/pos'),
                    onTap: () => context.go('/pos'),
                  ),
                  _MenuItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'إدارة المنتجات',
                    isExpanded: isExpanded,
                    isActive: currentPath.startsWith('/products'),
                    onTap: () => context.go('/products'),
                  ),
                  _MenuItem(
                    icon: Icons.people_outline,
                    title: 'العملاء',
                    isExpanded: isExpanded,
                    isActive: currentPath.startsWith('/customers'),
                    onTap: () => context.go('/customers'),
                  ),
                  _MenuItem(
                    icon: Icons.warning_amber_outlined,
                    title: 'التنبيهات',
                    isExpanded: isExpanded,
                    isActive: currentPath.startsWith('/alerts'),
                    onTap: () => context.go('/alerts'),
                    badgeCount: alertCount > 0 ? alertCount : null,
                  ),
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'التقارير',
                    isExpanded: isExpanded,
                    isActive: currentPath.startsWith('/reports'),
                    onTap: () => context.go('/reports'),
                  ),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    title: 'الفواتير',
                    isExpanded: isExpanded,
                    isActive: currentPath.startsWith('/invoices'),
                    onTap: () => context.go('/invoices'),
                  ),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    title: 'الإعدادات',
                    isExpanded: isExpanded,
                    isActive: currentPath.startsWith('/settings'),
                    onTap: () => context.go('/settings'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build mobile drawer menu
  Widget _buildMobileMenu(BuildContext context, String currentPath) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          _LogoHeader(
            isExpanded: true,
            onToggle: () => Navigator.pop(context),
          ),
          const SizedBox(height: AppSizes.md),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.dashboard_outlined,
                    title: AppStrings.dashboard,
                    isExpanded: true,
                    isActive: currentPath == '/',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.point_of_sale_outlined,
                    title: 'نقطة البيع',
                    isExpanded: true,
                    isActive: currentPath.startsWith('/pos'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/pos');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'إدارة المنتجات',
                    isExpanded: true,
                    isActive: currentPath.startsWith('/products'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/products');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.people_outline,
                    title: 'العملاء',
                    isExpanded: true,
                    isActive: currentPath.startsWith('/customers'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/customers');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.warning_amber_outlined,
                    title: 'التنبيهات',
                    isExpanded: true,
                    isActive: currentPath.startsWith('/alerts'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/alerts');
                    },
                    badgeCount: alertCount > 0 ? alertCount : null,
                  ),
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'التقارير',
                    isExpanded: true,
                    isActive: currentPath.startsWith('/reports'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/reports');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    title: 'الفواتير',
                    isExpanded: true,
                    isActive: currentPath.startsWith('/invoices'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/invoices');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    title: 'الإعدادات',
                    isExpanded: true,
                    isActive: currentPath.startsWith('/settings'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/settings');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoHeader extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback? onToggle;

  const _LogoHeader({required this.isExpanded, this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.sm),
      child: Row(
        children: [
          Flexible(
            child: Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.home, color: AppColors.primary),
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                AppStrings.appName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          // Global search button
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primary),
            tooltip: 'بحث شامل (Ctrl+K)',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const GlobalSearchDialog(),
              );
            },
          ),
          if (onToggle != null)
            IconButton(
              icon: Icon(
                isExpanded ? Icons.menu_open : Icons.menu,
                color: AppColors.primary,
              ),
              tooltip:
                  isExpanded ? 'طي الشريط الجانبي' : 'توسيع الشريط الجانبي',
              onPressed: onToggle,
            ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isExpanded;
  final bool isActive;
  final VoidCallback onTap;
  final int? badgeCount;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.isExpanded,
    required this.isActive,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin:
            const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
        padding: EdgeInsets.symmetric(
          horizontal: isExpanded ? AppSizes.md : AppSizes.xs,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    if (badgeCount != null)
                      Positioned(
                        right: -8,
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            badgeCount! > 99 ? '99+' : badgeCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: isActive ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
