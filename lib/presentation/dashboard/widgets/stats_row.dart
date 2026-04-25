import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
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
    return Row(
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

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: _isHovered ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.primary.withOpacity(0.15)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isHovered ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: AppTextStyles.bodyM,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      widget.value,
                      style: AppTextStyles.h2.copyWith(
                        color: widget.iconColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subValue,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              if (widget.isClickable)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
