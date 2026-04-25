import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/reports_state.dart';

class ProfitSummary extends StatelessWidget {
  final ReportData data;

  const ProfitSummary({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isGoodMargin = data.profitMargin >= 15;
    final isMediumMargin = data.profitMargin >= 5 && data.profitMargin < 15;

    Color marginColor;
    IconData marginIcon;
    String marginText;

    if (isGoodMargin) {
      marginColor = AppColors.success;
      marginIcon = Icons.trending_up;
      marginText = 'هوامش ممتازة';
    } else if (isMediumMargin) {
      marginColor = AppColors.warning;
      marginIcon = Icons.trending_flat;
      marginText = 'هوامش متوسطة';
    } else {
      marginColor = AppColors.danger;
      marginIcon = Icons.trending_down;
      marginText = 'هوامش منخفضة';
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: marginColor),
              const SizedBox(width: AppSizes.sm),
              Text('ملخص الأرباح', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              // Total profit
              Expanded(
                child: _ProfitItem(
                  label: 'إجمالي الربح',
                  value: data.totalProfit.toStringAsFixed(0),
                  color: marginColor,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              // Profit margin
              Expanded(
                child: _ProfitItem(
                  label: 'نسبة الربح',
                  value: '${data.profitMargin.toStringAsFixed(1)}%',
                  color: marginColor,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              // Margin indicator
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: marginColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    border:
                        Border.all(color: marginColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(marginIcon, color: marginColor, size: 20),
                      const SizedBox(width: AppSizes.xs),
                      Expanded(
                        child: Text(
                          marginText,
                          style: AppTextStyles.caption.copyWith(
                            color: marginColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            child: LinearProgressIndicator(
              value: (data.profitMargin / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(marginColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%', style: AppTextStyles.caption),
              Text('المثالي (>15%)', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfitItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ProfitItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: AppSizes.xs),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
