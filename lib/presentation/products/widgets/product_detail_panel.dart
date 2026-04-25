import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/product_model.dart';
import '../../../domain/entities/product.dart' show ProductType;
import 'stock_progress_bar.dart';
import 'type_badge.dart';

class ProductDetailPanel extends StatelessWidget {
  final ProductModel? product;
  final VoidCallback? onClose;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductDetailPanel({
    super.key,
    this.product,
    this.onClose,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return Container(
        width: 320,
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'اختر منتج لعرض التفاصيل',
                style: AppTextStyles.bodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final isMedicine = product!.productType == 'medicine';
    final profit = product!.sellingPrice - product!.purchasePrice;
    final profitPercentage = product!.purchasePrice > 0
        ? (profit / product!.purchasePrice) * 100
        : 0.0;

    int? daysRemaining;
    if (product!.expiryDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final expiry = DateTime(
        product!.expiryDate!.year,
        product!.expiryDate!.month,
        product!.expiryDate!.day,
      );
      daysRemaining = expiry.difference(today).inDays;
    }

    return Container(
      width: 320,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تفاصيل المنتج',
                style: AppTextStyles.h3,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
                iconSize: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: AppSizes.md),

          // Product Icon & Name
          Center(
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isMedicine
                        ? AppColors.secondarySurface
                        : AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMedicine ? Icons.medication : Icons.science,
                    size: 32,
                    color: isMedicine ? AppColors.secondary : AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  product!.name,
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.xs),
                TypeBadge(
                    type: isMedicine
                        ? ProductType.medicine
                        : ProductType.pesticide),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          const Divider(),

          // General Info
          _buildSectionTitle('معلومات عامة'),
          _buildInfoRow('الكود', product!.barcode),
          _buildInfoRow('النوع', isMedicine ? 'دواء' : 'مبيد'),
          _buildInfoRow('المادة الفعالة', product!.scientificName),
          const SizedBox(height: AppSizes.md),
          const Divider(),

          // Prices
          _buildSectionTitle('الأسعار'),
          _buildInfoRow(
              'سعر الشراء', '${product!.purchasePrice.toStringAsFixed(2)} ج'),
          _buildInfoRow(
              'سعر البيع', '${product!.sellingPrice.toStringAsFixed(2)} ج'),
          _buildInfoRow(
            'الربح',
            '${profit.toStringAsFixed(2)} ج',
            valueColor: AppColors.success,
            isHighlighted: true,
          ),
          _buildInfoRow(
            'الهامش %',
            '${profitPercentage.toStringAsFixed(1)}%',
            valueColor: AppColors.success,
            isHighlighted: true,
          ),
          const SizedBox(height: AppSizes.md),
          const Divider(),

          // Stock
          _buildSectionTitle('المخزون'),
          StockProgressBar(
            quantity: product!.stockQuantity,
            minimumStock: product!.minimumStock,
          ),
          const SizedBox(height: AppSizes.sm),
          _buildInfoRow('الكمية', '${product!.stockQuantity}'),
          _buildInfoRow('الحد الأدنى', '${product!.minimumStock}'),
          const SizedBox(height: AppSizes.md),
          const Divider(),

          // Expiry
          _buildSectionTitle('الصلاحية'),
          if (product!.expiryDate != null) ...[
            _buildInfoRow(
              'التاريخ',
              DateFormat('dd/MM/yyyy').format(product!.expiryDate!),
              valueColor: (daysRemaining ?? 0) < 0
                  ? AppColors.danger
                  : daysRemaining! <= 30
                      ? AppColors.warning
                      : AppColors.textPrimary,
            ),
            _buildInfoRow(
              'الأيام المتبقية',
              (daysRemaining ?? 0) < 0 ? 'منتهي' : '$daysRemaining يوم',
              valueColor: daysRemaining! < 0
                  ? AppColors.danger
                  : daysRemaining <= 30
                      ? AppColors.warning
                      : AppColors.textPrimary,
            ),
          ] else
            _buildInfoRow('التاريخ', '-'),
          const SizedBox(height: AppSizes.md),

          // Notes
          if (product!.description != null &&
              product!.description!.isNotEmpty) ...[
            const Divider(),
            _buildSectionTitle('ملاحظات'),
            Text(
              product!.description!,
              style: AppTextStyles.bodyM,
            ),
          ],

          const Spacer(),

          // Footer Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  child: const Text('حذف'),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('تعديل'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Text(
        title,
        style: AppTextStyles.label.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyM,
          ),
          Text(
            value,
            style: isHighlighted
                ? AppTextStyles.bodyL.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  )
                : AppTextStyles.bodyL.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                  ),
          ),
        ],
      ),
    );
  }
}
