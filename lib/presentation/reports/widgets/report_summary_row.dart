import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/responsive/responsive_layout.dart';
import '../bloc/reports_state.dart';

class ReportSummaryRow extends StatelessWidget {
  final ReportData data;

  const ReportSummaryRow({super.key, required this.data});

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}م';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}ك';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ScreenUtils.isMobile(context);
    final isTablet = ScreenUtils.isTablet(context);

    if (isMobile) {
      return Column(
        children: [
          _SummaryCard(
            icon: Icons.attach_money,
            iconColor: AppColors.primary,
            value: _formatCurrency(data.totalSales),
            label: 'إجمالي المبيعات',
            backgroundColor: AppColors.primarySurface,
          ),
          const SizedBox(height: AppSizes.sm),
          _SummaryCard(
            icon: Icons.receipt_long,
            iconColor: AppColors.secondary,
            value: '${data.invoicesCount}',
            label: 'عدد الفواتير',
            backgroundColor: AppColors.secondarySurface,
          ),
          const SizedBox(height: AppSizes.sm),
          _SummaryCard(
            icon: Icons.trending_up,
            iconColor: AppColors.warning,
            value: _formatCurrency(data.averageInvoice),
            label: 'متوسط الفاتورة',
            backgroundColor: AppColors.warningSurface,
          ),
          const SizedBox(height: AppSizes.sm),
          _SummaryCard(
            icon: Icons.savings,
            iconColor: AppColors.success,
            value: _formatCurrency(data.totalProfit),
            label: 'إجمالي الربح',
            backgroundColor: AppColors.successSurface,
          ),
          const SizedBox(height: AppSizes.sm),
          _SummaryCard(
            icon: Icons.account_balance_wallet,
            iconColor:
                data.totalDebt > 0 ? AppColors.danger : AppColors.success,
            value: _formatCurrency(data.totalDebt),
            label: 'إجمالي الديون',
            backgroundColor: data.totalDebt > 0
                ? AppColors.dangerSurface
                : AppColors.successSurface,
          ),
        ],
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.attach_money,
                  iconColor: AppColors.primary,
                  value: _formatCurrency(data.totalSales),
                  label: 'إجمالي المبيعات',
                  backgroundColor: AppColors.primarySurface,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.receipt_long,
                  iconColor: AppColors.secondary,
                  value: '${data.invoicesCount}',
                  label: 'عدد الفواتير',
                  backgroundColor: AppColors.secondarySurface,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.trending_up,
                  iconColor: AppColors.warning,
                  value: _formatCurrency(data.averageInvoice),
                  label: 'متوسط الفاتورة',
                  backgroundColor: AppColors.warningSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.savings,
                  iconColor: AppColors.success,
                  value: _formatCurrency(data.totalProfit),
                  label: 'إجمالي الربح',
                  backgroundColor: AppColors.successSurface,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.account_balance_wallet,
                  iconColor:
                      data.totalDebt > 0 ? AppColors.danger : AppColors.success,
                  value: _formatCurrency(data.totalDebt),
                  label: 'إجمالي الديون',
                  backgroundColor: data.totalDebt > 0
                      ? AppColors.dangerSurface
                      : AppColors.successSurface,
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      );
    }

    // Desktop - original row layout
    return Row(
      children: [
        // Total Sales card
        Expanded(
          child: _SummaryCard(
            icon: Icons.attach_money,
            iconColor: AppColors.primary,
            value: _formatCurrency(data.totalSales),
            label: 'إجمالي المبيعات',
            backgroundColor: AppColors.primarySurface,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        // Invoices count card
        Expanded(
          child: _SummaryCard(
            icon: Icons.receipt_long,
            iconColor: AppColors.secondary,
            value: '${data.invoicesCount}',
            label: 'عدد الفواتير',
            backgroundColor: AppColors.secondarySurface,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        // Average invoice card
        Expanded(
          child: _SummaryCard(
            icon: Icons.trending_up,
            iconColor: AppColors.warning,
            value: _formatCurrency(data.averageInvoice),
            label: 'متوسط الفاتورة',
            backgroundColor: AppColors.warningSurface,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        // Total profit card
        Expanded(
          child: _SummaryCard(
            icon: Icons.savings,
            iconColor: AppColors.success,
            value: _formatCurrency(data.totalProfit),
            label: 'إجمالي الربح',
            backgroundColor: AppColors.successSurface,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        // Total customer debt card
        Expanded(
          child: _SummaryCard(
            icon: Icons.account_balance_wallet,
            iconColor:
                data.totalDebt > 0 ? AppColors.danger : AppColors.success,
            value: _formatCurrency(data.totalDebt),
            label: 'إجمالي الديون',
            backgroundColor: data.totalDebt > 0
                ? AppColors.dangerSurface
                : AppColors.successSurface,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color backgroundColor;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.xxs),
                Text(
                  label,
                  style: AppTextStyles.captionSm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
