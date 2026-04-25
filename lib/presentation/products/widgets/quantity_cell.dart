import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class QuantityCell extends StatelessWidget {
  final int quantity;
  final int minimumStock;

  const QuantityCell({
    super.key,
    required this.quantity,
    required this.minimumStock,
  });

  @override
  Widget build(BuildContext context) {
    if (quantity <= minimumStock) {
      // Out of stock or very low - red
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.arrow_downward,
            size: 16,
            color: AppColors.danger,
          ),
          const SizedBox(width: 4),
          Text(
            '$quantity / $minimumStock',
            style: AppTextStyles.bodyM.copyWith(
              color: AppColors.danger,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else if (quantity <= minimumStock * 2) {
      // Warning level - yellow
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_outlined,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            '$quantity / $minimumStock',
            style: AppTextStyles.bodyM.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else {
      // Normal - gray
      return Text(
        '$quantity / $minimumStock',
        style: AppTextStyles.bodyM.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }
  }
}
