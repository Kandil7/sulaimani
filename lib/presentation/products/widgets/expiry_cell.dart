import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ExpiryCell extends StatelessWidget {
  final DateTime? expiryDate;

  const ExpiryCell({
    super.key,
    required this.expiryDate,
  });

  @override
  Widget build(BuildContext context) {
    if (expiryDate == null) {
      return Text(
        '-',
        style: AppTextStyles.bodyM,
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry =
        DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    final daysRemaining = expiry.difference(today).inDays;

    if (daysRemaining < 0) {
      // Expired
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cancel_outlined,
            size: 16,
            color: AppColors.danger,
          ),
          const SizedBox(width: 4),
          Text(
            'منتهي',
            style: AppTextStyles.bodyM.copyWith(
              color: AppColors.danger,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else if (daysRemaining <= 30) {
      // Expiring soon
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
            'متبقي $daysRemaining يوم',
            style: AppTextStyles.bodyM.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else {
      // Normal
      return Text(
        DateFormat('dd/MM/yyyy').format(expiryDate!),
        style: AppTextStyles.bodyM.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }
  }
}
