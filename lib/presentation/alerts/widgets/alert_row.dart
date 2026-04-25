import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/alerts_state.dart';

class AlertRow extends StatelessWidget {
  final ProductAlert alert;
  final Color color;
  final VoidCallback? onEdit;

  const AlertRow({
    super.key,
    required this.alert,
    required this.color,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (_) {},
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Type indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSizes.md),

            // Product name
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.productName,
                    style: AppTextStyles.bodyL.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    alert.type,
                    style: AppTextStyles.caption.copyWith(
                      color: color,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity/Stock
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الكمية', style: AppTextStyles.caption),
                  Text(
                    '${alert.quantity}',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Date or countdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تاريخ الانتهاء', style: AppTextStyles.caption),
                  if (alert.expiryDate != null)
                    _buildExpiryInfo()
                  else
                    Text('-', style: AppTextStyles.bodyM),
                ],
              ),
            ),

            // Actions
            if (onEdit != null)
              ElevatedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('تعديل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryInfo() {
    if (alert.expiryDate == null) return const SizedBox();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDay = DateTime(
      alert.expiryDate!.year,
      alert.expiryDate!.month,
      alert.expiryDate!.day,
    );
    final daysLeft = expiryDay.difference(today).inDays;

    String text;
    Color textColor;

    if (daysLeft < 0) {
      text = 'منتهي';
      textColor = AppColors.danger;
    } else if (daysLeft == 0) {
      text = 'اليوم';
      textColor = AppColors.danger;
    } else if (daysLeft <= 7) {
      text = 'متبقي $daysLeft يوم';
      textColor = AppColors.warning;
    } else {
      text = '$daysLeft يوم';
      textColor = AppColors.textSecondary;
    }

    return Row(
      children: [
        Text(
          text,
          style: AppTextStyles.bodyM.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
