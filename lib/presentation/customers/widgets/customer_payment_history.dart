import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class CustomerPaymentHistory extends StatelessWidget {
  final int customerId;

  const CustomerPaymentHistory({
    super.key,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder - would be replaced with actual data from invoices repository
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: const Center(
        child: Text(
          'لا توجد مشتريات سابقة',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
