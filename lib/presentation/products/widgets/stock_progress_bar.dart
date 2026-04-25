import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';

class StockProgressBar extends StatelessWidget {
  final int quantity;
  final int minimumStock;

  const StockProgressBar({
    super.key,
    required this.quantity,
    required this.minimumStock,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = minimumStock > 0 ? (quantity / (minimumStock * 3)) : 0.0;
    final clampedPercentage = percentage.clamp(0.0, 1.0);

    Color getBarColor() {
      if (quantity == 0) {
        return AppColors.textSecondary;
      } else if (quantity <= minimumStock) {
        return AppColors.danger;
      } else if (quantity <= minimumStock * 2) {
        return AppColors.warning;
      } else {
        return AppColors.success;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الكمية: $quantity من ${minimumStock * 3}',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSizes.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          child: LinearProgressIndicator(
            value: clampedPercentage,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(getBarColor()),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
