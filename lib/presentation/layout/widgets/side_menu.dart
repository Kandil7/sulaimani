import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
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
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 16,
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
                    selectedIcon: Icons.dashboard,
                    title: AppStrings.dashboard,
                    isExpanded: isExpanded,
                    isActive: currentPath == '/',
                    onTap: () => context.go('/'),
                  ),
                  _MenuItem(
                    icon: Icons.point_of_sale_outlined,
                    selectedIcon: Icons.point_of_sale,
                    title: 'نقطة البيع',
                    isExpanded: isExpanded,
                    isActive: currentPath.startsWith('/pos'),
                    onTap: () => context.go('/pos'),
                  ),
                  _MenuItem(
                    icon: Icons.inventory_2_outlined,
                    selectedIcon: Icons.inventory_2,
                    title: 'إدارة المنتجات',
                    isExpanded: isExpanded,
                    isActive: currentPath.startsWith('/products'),
                    onTap: () => context.go('/products'),
                  ),
                  _MenuItem(
                    icon: Icons.people_outline,
                    selectedIcon: Icons.people,
                    title: 'العملاء',
                    isExpanded: isExpanded,
                    isActive: currentPath.startsWith('/customers'),
                    onTap: () => context.go('/customers'),
                  ),
                  _MenuItem(
                    icon: Icons.warning_amber_outlined,
                    selectedIcon: Icons.warning_amber,
                    title: 'التنبيهات',
                    isExpanded: isExpanded,
                    isActive: currentPath.startsWith('/alerts'),
                    onTap: () => context.go('/alerts'),
                    badgeCount: alertCount > 0 ? alertCount : null,
                  ),
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    selectedIcon: Icons.receipt_long,
                    title: 'التقارير',
                    isExpanded: isExpanded,
                    isActive: currentPath.startsWith('/reports'),
                    onTap: () => context.go('/reports'),
                  ),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    selectedIcon: Icons.description,
                    title: 'الفواتير',
                    isExpanded: isExpanded,
                    isActive: currentPath.startsWith('/invoices'),
                    onTap: () => context.go('/invoices'),
                  ),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
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
      width: AppSizes.sidebarMobileWidth,
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                    selectedIcon: Icons.dashboard,
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
                    selectedIcon: Icons.point_of_sale,
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
                    selectedIcon: Icons.inventory_2,
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
                    selectedIcon: Icons.people,
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
                    selectedIcon: Icons.warning_amber,
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
                    selectedIcon: Icons.receipt_long,
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
                    selectedIcon: Icons.description,
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
                    selectedIcon: Icons.settings,
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
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          // Logo container with gradient
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/logo.png',
              width: 28,
              height: 28,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.store,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                AppStrings.appName,
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          // Global search button
          IconButton(
            icon: Icon(
              Icons.search,
              color: AppColors.primary,
            ),
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
  final IconData selectedIcon;
  final String title;
  final bool isExpanded;
  final bool isActive;
  final VoidCallback onTap;
  final int? badgeCount;

  const _MenuItem({
    required this.icon,
    required this.selectedIcon,
    required this.title,
    required this.isExpanded,
    required this.isActive,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xxs,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? AppSizes.md : AppSizes.sm,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primarySurface : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: isActive
                  ? Border.all(color: AppColors.primary.withOpacity(0.2))
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          isActive ? selectedIcon : icon,
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
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.danger.withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                badgeCount! > 99
                                    ? '99+'
                                    : badgeCount.toString(),
                                style: AppTextStyles.badge.copyWith(
                                  fontSize: 9,
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
                      style: isActive
                          ? AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            )
                          : AppTextStyles.label.copyWith(
                              color: AppColors.textPrimary,
                            ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
