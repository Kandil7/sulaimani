import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

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
            title: AppStrings.pos,
            isActive: currentPath.startsWith('/pos'),
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.inventory_2_outlined,
            title: AppStrings.products,
            isActive: currentPath.startsWith('/products'),
            onTap: () => context.go('/products'),
          ),
          _MenuItem(
            icon: Icons.receipt_long_outlined,
            title: 'التقارير',
            isActive: currentPath.startsWith('/reports'),
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.settings_outlined,
            title: 'الإعدادات',
            isActive: currentPath.startsWith('/settings'),
            onTap: () {},
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

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.md),
            Text(
              title,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
