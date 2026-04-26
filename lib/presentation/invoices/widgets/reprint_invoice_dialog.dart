import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/models/sale_item_model.dart';
import '../../../core/utils/date_utils.dart' as app_date;

class ReprintInvoiceDialog extends StatelessWidget {
  final SaleModel sale;
  final List<SaleItemModel> items;
  final List<int> pdfBytes;

  const ReprintInvoiceDialog({
    super.key,
    required this.sale,
    required this.items,
    required this.pdfBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.receipt_long,
                    color: AppColors.primary, size: 28),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'فاتورة رقم: ${sale.receiptNumber}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: 'إغلاق',
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            // Date info
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppSizes.xs),
                  Text(
                    app_date.AppDateUtils.formatToDate(sale.date),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: sale.paymentMethod == 'cash'
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text(
                      sale.paymentMethod == 'cash' ? 'نقدي' : 'آجل',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: sale.paymentMethod == 'cash'
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ),
                  if (sale.customerName != null) ...[
                    const SizedBox(width: AppSizes.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Text(
                        sale.customerName!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Items table
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Table header
                    Container(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'الصنف',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              'الكمية',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              'السعر',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              'الإجمالي',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Items
                    ...items.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.sm,
                          vertical: AppSizes.xs,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: AppColors.border.withOpacity(0.3)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.product.value?.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(fontSize: 11),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                CurrencyUtils.format(item.unitPrice),
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                CurrencyUtils.format(item.total),
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            const Divider(),

            // Totals
            Column(
              children: [
                _buildTotalRow(
                    'المجموع:', sale.totalAmount, AppColors.textSecondary),
                if (sale.discount > 0)
                  _buildTotalRow('الخصم:', -sale.discount, AppColors.success),
                _buildTotalRow('الصافي:', sale.finalAmount, AppColors.primary,
                    isBold: true, fontSize: 16),
                const SizedBox(height: AppSizes.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المدفوع:',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                    Text(
                      CurrencyUtils.format(sale.paidAmount),
                      style: TextStyle(
                        color: sale.remainingAmount > 0
                            ? AppColors.warning
                            : AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (sale.remainingAmount > 0) ...[
                  const SizedBox(height: AppSizes.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الباقي:',
                        style:
                            TextStyle(color: AppColors.warning, fontSize: 12),
                      ),
                      Text(
                        CurrencyUtils.format(sale.remainingAmount),
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSizes.lg),

// Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _printInvoice(context),
                    icon: const Icon(Icons.print),
                    label: const Text('طباعة'),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSizes.md),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareViaWhatsApp(context),
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('واتساب'),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSizes.md),
                      foregroundColor: const Color(0xFF25D366),
                      side: const BorderSide(color: Color(0xFF25D366)),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareInvoice(),
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة PDF'),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSizes.md),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _previewPdf(context),
                    icon: const Icon(Icons.preview),
                    label: const Text('معاينة'),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSizes.md),
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

  Widget _buildTotalRow(String label, double amount, Color color,
      {bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            CurrencyUtils.format(amount.abs()),
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _printInvoice(BuildContext context) async {
    await Printing.layoutPdf(
      onLayout: (format) async => Uint8List.fromList(pdfBytes),
    );
  }

  void _shareInvoice() async {
    try {
      final bytes = Uint8List.fromList(pdfBytes);
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${sale.receiptNumber}.pdf',
      );
    } catch (e) {
      debugPrint('Error sharing invoice: $e');
    }
  }

  void _shareViaWhatsApp(BuildContext context) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final pdfFile = File('${tempDir.path}/${sale.receiptNumber}.pdf');
      await pdfFile.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text:
            'فاتورة صيدلية السليماني - ${sale.receiptNumber}\nإجمالي: ${CurrencyUtils.format(sale.finalAmount)}',
      );
    } catch (e) {
      debugPrint('Error sharing via WhatsApp: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في المشاركة: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _previewPdf(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Container(
          width: 600,
          height: 700,
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'معاينة الفاتورة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: PdfPreview(
                  build: (format) async => Uint8List.fromList(pdfBytes),
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  allowPrinting: true,
                  allowSharing: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
