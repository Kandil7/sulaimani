import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/dashboard_state.dart';

class RecentSalesTable extends StatelessWidget {
  final List<RecentSale> sales;
  final VoidCallback? onViewAllTap;
  final Function(int saleId)? onInvoiceTap;

  const RecentSalesTable({
    super.key,
    required this.sales,
    this.onViewAllTap,
    this.onInvoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('أحدث الفواتير', style: AppTextStyles.h2),
              if (onViewAllTap != null)
                TextButton(
                  onPressed: onViewAllTap,
                  child: Text(
                    'عرض الكل',
                    style: AppTextStyles.bodyM.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          if (sales.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.lg),
                  Icon(
                    Icons.receipt_long,
                    size: 48,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'لا توجد فواتير حتى الآن',
                    style: AppTextStyles.bodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                ],
              ),
            )
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  children: [
                    _buildHeader('#'),
                    _buildHeader('الفاتورة'),
                    _buildHeader('المبلغ'),
                    _buildHeader('الدفع'),
                    _buildHeader('الوقت'),
                  ],
                ),
                ...sales.map((sale) => _buildRow(sale)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  TableRow _buildRow(RecentSale sale) {
    return TableRow(
      children: [
        InkWell(
          onTap: onInvoiceTap != null ? () => onInvoiceTap!(sale.id) : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              '#${sale.invoiceNumber}',
              style: AppTextStyles.bodyM.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: onInvoiceTap != null ? () => onInvoiceTap!(sale.id) : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              sale.customerName ?? 'زائر',
              style: AppTextStyles.bodyM,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        InkWell(
          onTap: onInvoiceTap != null ? () => onInvoiceTap!(sale.id) : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              '${sale.amount.toStringAsFixed(0)} ج',
              style: AppTextStyles.bodyM.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: onInvoiceTap != null ? () => onInvoiceTap!(sale.id) : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: _PaymentBadge(paymentType: sale.paymentType),
          ),
        ),
        InkWell(
          onTap: onInvoiceTap != null ? () => onInvoiceTap!(sale.id) : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              _formatRelativeTime(sale.createdAt),
              style: AppTextStyles.caption,
            ),
          ),
        ),
      ],
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

class _PaymentBadge extends StatelessWidget {
  final String paymentType;

  const _PaymentBadge({required this.paymentType});

  @override
  Widget build(BuildContext context) {
    final isCash = paymentType == 'نقدي';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: isCash ? AppColors.successSurface : AppColors.warningSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        paymentType,
        style: AppTextStyles.caption.copyWith(
          color: isCash ? AppColors.success : AppColors.warning,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
