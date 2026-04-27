import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/responsive/responsive_layout.dart';
import '../bloc/dashboard_state.dart';

class StatsRow extends StatelessWidget {
  final DashboardLoaded data;
  final VoidCallback? onAlertsTap;

  const StatsRow({
    super.key,
    required this.data,
    this.onAlertsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ScreenUtils.isMobile(context);
    final isTablet = ScreenUtils.isTablet(context);

    if (isMobile || isTablet) {
      // Stack layout for mobile/tablet
      return _buildStackLayout();
    }

    // Row layout for desktop
    return _buildRowLayout();
  }

  Widget _buildRowLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.monetization_on,
            iconColor: AppColors.primary,
            label: 'مبيعات اليوم',
            value: _formatCurrency(data.todaySales),
            subValue: '${data.todayInvoicesCount} فاتورة',
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _StatCard(
            icon: Icons.inventory_2,
            iconColor: AppColors.secondary,
            label: 'المخزون',
            value: '${data.totalProductsCount}',
            subValue: 'منتج',
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _StatCard(
            icon: Icons.warning_rounded,
            iconColor: AppColors.warning,
            label: 'التنبيهات',
            value: '${data.alertsCount}',
            subValue: 'تنبيه',
            onTap: onAlertsTap,
            isClickable: true,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _StatCard(
            icon: Icons.people,
            iconColor: AppColors.danger,
            label: 'الديون',
            value: _formatCurrency(data.totalDebt),
            subValue: 'إجمالي',
          ),
        ),
      ],
    );
  }

  Widget _buildStackLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.monetization_on,
                iconColor: AppColors.primary,
                label: 'مبيعات اليوم',
                value: _formatCurrency(data.todaySales),
                subValue: '${data.todayInvoicesCount} فاتورة',
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _StatCard(
                icon: Icons.inventory_2,
                iconColor: AppColors.secondary,
                label: 'المخزون',
                value: '${data.totalProductsCount}',
                subValue: 'منتج',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.warning_rounded,
                iconColor: AppColors.warning,
                label: 'التنبيهات',
                value: '${data.alertsCount}',
                subValue: 'تنبيه',
                onTap: onAlertsTap,
                isClickable: true,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _StatCard(
                icon: Icons.people,
                iconColor: AppColors.danger,
                label: 'الديون',
                value: _formatCurrency(data.totalDebt),
                subValue: 'إجمالي',
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}م';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}ك';
    }
    return amount.toStringAsFixed(0);
  }
}

class _StatCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subValue;
  final VoidCallback? onTap;
  final bool isClickable;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subValue,
    this.onTap,
    this.isClickable = false,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(
                    color: _isHovered ? widget.iconColor : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? widget.iconColor.withOpacity(0.15)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: _isHovered ? 12 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.iconColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.label,
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.value,
                            style: AppTextStyles.h3.copyWith(
                              color: widget.iconColor,
                            ),
                          ),
                          Text(
                            widget.subValue,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isClickable)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
