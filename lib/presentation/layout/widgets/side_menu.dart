import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

class SideMenu extends StatefulWidget {
  final int alertCount;

  const SideMenu({
    super.key,
    this.alertCount = 0,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isExpanded
          ? AppSizes.sidebarExpandedWidth
          : AppSizes.sidebarCollapsedWidth,
      color: Colors.white,
      child: Column(
        children: [
          _LogoHeader(
              isExpanded: _isExpanded,
              onToggle: () {
                setState(() => _isExpanded = !_isExpanded);
              }),
          const SizedBox(height: AppSizes.md),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.dashboard_outlined,
                    title: AppStrings.dashboard,
                    isExpanded: _isExpanded,
                    isActive: currentPath == '/',
                    onTap: () => context.go('/'),
                  ),
                  _MenuItem(
                    icon: Icons.point_of_sale_outlined,
                    title: 'نقطة البيع',
                    isExpanded: _isExpanded,
                    isActive: currentPath.startsWith('/pos'),
                    onTap: () => context.go('/pos'),
                  ),
                  _MenuItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'إدارة المنتجات',
                    isExpanded: _isExpanded,
                    isActive: currentPath.startsWith('/products'),
                    onTap: () => context.go('/products'),
                  ),
                  _MenuItem(
                    icon: Icons.people_outline,
                    title: 'العملاء',
                    isExpanded: _isExpanded,
                    isActive: currentPath.startsWith('/customers'),
                    onTap: () => context.go('/customers'),
                  ),
                  _MenuItem(
                    icon: Icons.warning_amber_outlined,
                    title: 'التنبيهات',
                    isExpanded: _isExpanded,
                    isActive: currentPath.startsWith('/alerts'),
                    onTap: () => context.go('/alerts'),
                    badgeCount:
                        widget.alertCount > 0 ? widget.alertCount : null,
                  ),
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'التقارير',
                    isExpanded: _isExpanded,
                    isActive: currentPath.startsWith('/reports'),
                    onTap: () => context.go('/reports'),
                  ),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    title: 'الفواتير',
                    isExpanded: _isExpanded,
                    isActive: currentPath.startsWith('/invoices'),
                    onTap: () => context.go('/invoices'),
                  ),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    title: 'الإعدادات',
                    isExpanded: _isExpanded,
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
}

class _LogoHeader extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const _LogoHeader({required this.isExpanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          Image.asset('assets/images/logo.png', width: 40, height: 40),
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
          const Spacer(),
          IconButton(
            icon: Icon(
              isExpanded ? Icons.chevron_left : Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: onToggle,
            tooltip: isExpanded ? 'طي الشريط الجانبي' : 'توسيع الشريط الجانبي',
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
