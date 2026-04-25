import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/product_model.dart';

class ExpiryWarningDialog extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ExpiryWarningDialog({
    super.key,
    required this.product,
    required this.onConfirm,
    required this.onCancel,
  });

  bool get _isExpired =>
      product.expiryDate != null &&
      product.expiryDate!.isBefore(DateTime.now());

  bool get _isExpiringSoon =>
      product.expiryDate != null &&
      !_isExpired &&
      product.expiryDate!
          .isBefore(DateTime.now().add(const Duration(days: 30)));

  String _formatExpiryDate() {
    if (product.expiryDate == null) return 'غير محدد';
    return '${product.expiryDate!.day}/${product.expiryDate!.month}/${product.expiryDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: _isExpired
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: _isExpired ? AppColors.error : AppColors.warning,
                    size: 40,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            // Warning title
            Text(
              _isExpired ? 'تنبيه: منتج منتهي!' : 'تنبيه: انتهاء الصلاحية',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isExpired ? AppColors.error : AppColors.warning,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Product info
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Column(
                children: [
                  // Product name
                  Text(
                    product.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // Expiry info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event,
                        size: 18,
                        color: _isExpired
                            ? AppColors.error
                            : (_isExpiringSoon
                                ? AppColors.warning
                                : AppColors.textSecondary),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        'تاريخ الانتهاء: $_formatExpiryDate',
                        style: TextStyle(
                          color: _isExpired
                              ? AppColors.error
                              : (_isExpiringSoon
                                  ? AppColors.warning
                                  : AppColors.textSecondary),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  if (_isExpired) ...[
                    const SizedBox(height: AppSizes.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dangerSurface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 16,
                          ),
                          SizedBox(width: AppSizes.xs),
                          Text(
                            'هذا المنتج منتهي الصلاحية',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_isExpiringSoon) ...[
                    const SizedBox(height: AppSizes.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningSurface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.warning,
                            size: 16,
                          ),
                          SizedBox(width: AppSizes.xs),
                          Text(
                            'ينتهي خلال 30 يوم',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Question
            const Text(
              'هل تريد المتابعة؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Action buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.md,
                      ),
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                // Confirm button
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.md,
                      ),
                      backgroundColor:
                          _isExpired ? AppColors.error : AppColors.warning,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _isExpired ? 'نعم، أريد البيع' : 'نعم، أريد البيع',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
