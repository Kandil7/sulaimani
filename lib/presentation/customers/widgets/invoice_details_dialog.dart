import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../data/models/sale_model.dart';
import '../../../data/models/sale_item_model.dart';

class InvoiceDetailsDialog extends StatelessWidget {
  final SaleModel sale;
  final List<SaleItemModel> items;

  const InvoiceDetailsDialog({
    super.key,
    required this.sale,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long,
                    size: 28, color: AppColors.primary),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    sale.receiptNumber,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow(
                'التاريخ:', app_date.AppDateUtils.formatToDate(sale.date)),
            _buildDetailRow(
                'طريقة الدفع:', sale.paymentMethod == 'cash' ? 'نقدي' : 'آجل'),
            if (sale.customerName != null)
              _buildDetailRow('العميل:', sale.customerName!),
            _buildDetailRow(
                'الإجمالي:', CurrencyUtils.format(sale.totalAmount)),
            if (sale.discount > 0)
              _buildDetailRow('الخصم:', CurrencyUtils.format(sale.discount)),
            _buildDetailRow('الصافي:', CurrencyUtils.format(sale.finalAmount)),
            _buildDetailRow('المدفوع:', CurrencyUtils.format(sale.paidAmount)),
            if (sale.remainingAmount > 0)
              _buildDetailRow(
                  'الباقي:', CurrencyUtils.format(sale.remainingAmount)),
            const SizedBox(height: AppSizes.md),
            if (items.isNotEmpty) ...[
              const Text(
                'المنتجات',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: AppSizes.sm),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildDetailRow(
                      '${item.product.value?.name ?? '—'} × ${item.quantity}',
                      CurrencyUtils.format(item.total),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: AppSizes.md),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
