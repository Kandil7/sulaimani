import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

class SideMenu extends StatelessWidget {
  final int alertCount;

  const SideMenu({
    super.key,
    this.alertCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();

    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          const _LogoHeader(),
          const SizedBox(height: AppSizes.md),
          _MenuItem(
            icon: Icons.dashboard_outlined,
            title: AppStrings.dashboard,
            isActive: currentPath == '/',
            onTap: () => context.go('/'),
          ),
          _MenuItem(
            icon: Icons.point_of_sale_outlined,
            title: 'نقطة البيع',
            isActive: currentPath.startsWith('/pos'),
            onTap: () => context.go('/pos'),
          ),
          _MenuItem(
            icon: Icons.inventory_2_outlined,
            title: 'إدارة المنتجات',
            isActive: currentPath.startsWith('/products'),
            onTap: () => context.go('/products'),
          ),
          _MenuItem(
            icon: Icons.people_outline,
            title: 'العملاء',
            isActive: currentPath.startsWith('/customers'),
            onTap: () => context.go('/customers'),
          ),
          _MenuItem(
            icon: Icons.warning_amber_outlined,
            title: 'التنبيهات',
            isActive: currentPath.startsWith('/alerts'),
            onTap: () => context.go('/alerts'),
            badgeCount: alertCount > 0 ? alertCount : null,
          ),
          _MenuItem(
            icon: Icons.receipt_long_outlined,
            title: 'التقارير',
            isActive: currentPath.startsWith('/reports'),
            onTap: () => context.go('/reports'),
          ),
          _MenuItem(
            icon: Icons.settings_outlined,
            title: 'الإعدادات',
            isActive: currentPath.startsWith('/settings'),
            onTap: () => context.go('/settings'),
          ),
        ],
      ),
    );
  }
}

class _LogoHeader extends StatelessWidget {
  const _LogoHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Row(
        children: [
          Image.asset('assets/images/logo.png', width: 40, height: 40),
          const SizedBox(width: AppSizes.sm),
          const Expanded(
            child: Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final int? badgeCount;

  const _MenuItem({
    required this.icon,
    required this.title,
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
            const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 4),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.sm),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
                if (badgeCount != null)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        badgeCount! > 99 ? '99+' : badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isActive ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
