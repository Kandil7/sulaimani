import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/responsive/responsive_layout.dart';
import '../../../data/models/customer_model.dart';

class DebtStatisticsCard extends StatelessWidget {
  final List<CustomerModel> customers;

  const DebtStatisticsCard({
    super.key,
    required this.customers,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ScreenUtils.isMobile(context);
    final totalDebt =
        customers.fold<double>(0, (sum, c) => sum + c.debtBalance);
    final debtors = customers.where((c) => c.debtBalance > 0).toList();
    final debtorCount = debtors.length;
    final largestDebt = debtors.isEmpty
        ? 0.0
        : debtors.map((c) => c.debtBalance).reduce((a, b) => a > b ? a : b);
    final averageDebt = debtorCount > 0 ? totalDebt / debtorCount : 0.0;

    return Container(
      padding: EdgeInsets.all(isMobile ? AppSizes.md : AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet,
                  color: AppColors.primary, size: isMobile ? 18 : 24),
              SizedBox(width: isMobile ? AppSizes.xs : AppSizes.sm),
              Text(
                'إحصائيات الدين',
                style: isMobile ? AppTextStyles.bodyL : AppTextStyles.h3,
              ),
            ],
          ),
          SizedBox(height: isMobile ? AppSizes.md : AppSizes.lg),
          // Stats - wrap for mobile, row for desktop
          isMobile
              ? Column(
                  children: [
                    _StatItem(
                      label: 'إجمالي الدين',
                      value: '${totalDebt.toStringAsFixed(0)} ج',
                      color: _getDebtColor(totalDebt),
                      icon: Icons.attach_money,
                    ),
                    SizedBox(height: AppSizes.sm),
                    _StatItem(
                      label: 'عدد المدينين',
                      value: '$debtorCount',
                      color: debtorCount > 0
                          ? AppColors.warning
                          : AppColors.success,
                      icon: Icons.people,
                    ),
                    SizedBox(height: AppSizes.sm),
                    _StatItem(
                      label: 'أكبر دين',
                      value: '${largestDebt.toStringAsFixed(0)} ج',
                      color: AppColors.danger,
                      icon: Icons.arrow_upward,
                    ),
                    SizedBox(height: AppSizes.sm),
                    _StatItem(
                      label: 'متوسط الدين',
                      value: '${averageDebt.toStringAsFixed(0)} ج',
                      color: AppColors.textSecondary,
                      icon: Icons.trending_flat,
                    ),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            label: 'إجمالي الدين',
                            value: '${totalDebt.toStringAsFixed(0)} ج',
                            color: _getDebtColor(totalDebt),
                            icon: Icons.attach_money,
                          ),
                        ),
                        SizedBox(width: AppSizes.md),
                        Expanded(
                          child: _StatItem(
                            label: 'عدد المدينين',
                            value: '$debtorCount',
                            color: debtorCount > 0
                                ? AppColors.warning
                                : AppColors.success,
                            icon: Icons.people,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.md),
                    Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            label: 'أكبر دين',
                            value: '${largestDebt.toStringAsFixed(0)} ج',
                            color: AppColors.danger,
                            icon: Icons.arrow_upward,
                          ),
                        ),
                        SizedBox(width: AppSizes.md),
                        Expanded(
                          child: _StatItem(
                            label: 'متوسط الدين',
                            value: '${averageDebt.toStringAsFixed(0)} ج',
                            color: AppColors.textSecondary,
                            icon: Icons.trending_flat,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Color _getDebtColor(double debt) {
    if (debt > 10000) return AppColors.danger;
    if (debt > 5000) return AppColors.warning;
    return AppColors.success;
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSizes.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
