import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/models/sale_item_model.dart';

class InvoicePreviewDialog extends StatelessWidget {
  final SaleModel sale;
  final List<SaleItemModel> items;
  final Uint8List pdfBytes;
  final VoidCallback onNewSale;

  const InvoicePreviewDialog({
    super.key,
    required this.sale,
    required this.items,
    required this.pdfBytes,
    required this.onNewSale,
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
            // Success header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: const BoxDecoration(
                    color: AppColors.successSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.success,
                    size: 40,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            const Text(
              'تمت عملية البيع بنجاح!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            // Receipt number
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    'رقم الفاتورة: ${sale.receiptNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Invoice summary
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Items table header
                    Container(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSm,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'الصنف',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              'الكمية',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              'السعر',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              'الإجمالي',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.end,
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
                              color: AppColors.border.withOpacity(0.5),
                            ),
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
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(fontSize: 11),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              child: Text(
                                CurrencyUtils.format(item.unitPrice),
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.end,
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              child: Text(
                                CurrencyUtils.format(item.total),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.end,
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
            const Divider(),

            // Totals
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'المجموع:',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      CurrencyUtils.format(sale.totalAmount),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (sale.discount > 0) ...[
                  const SizedBox(height: AppSizes.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الخصم:',
                        style: TextStyle(color: AppColors.success),
                      ),
                      Text(
                        '- ${CurrencyUtils.format(sale.discount)}',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSizes.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'الصافي:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      CurrencyUtils.format(sale.finalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),

            // Action buttons
            Row(
              children: [
                // Print button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _printInvoice(context),
                    icon: const Icon(Icons.print),
                    label: const Text('طباعة'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.md,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                // WhatsApp share button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareViaWhatsApp(context),
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('واتساب'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.md,
                      ),
                      foregroundColor: const Color(0xFF25D366),
                      side: const BorderSide(color: Color(0xFF25D366)),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                // Share button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareInvoice(),
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.md,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                // New sale button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: onNewSale,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('بيع جديد'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.md,
                      ),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
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

  void _printInvoice(BuildContext context) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
    );
  }

  void _shareInvoice() async {
    try {
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '${sale.receiptNumber}.pdf',
      );
    } catch (e) {
      debugPrint('Error sharing invoice: $e');
    }
  }

  void _shareViaWhatsApp(BuildContext context) async {
    try {
      // Save PDF to temp file
      final tempDir = await getTemporaryDirectory();
      final pdfFile = File('${tempDir.path}/${sale.receiptNumber}.pdf');
      await pdfFile.writeAsBytes(pdfBytes);

      // Check if WhatsApp is installed
      final whatsappUri = Uri.parse('whatsapp://send');
      final canLaunchWhatsApp = await canLaunchUrl(whatsappUri);

      if (canLaunchWhatsApp) {
        // Use share_plus with WhatsApp share intent
        await Share.shareXFiles(
          [XFile(pdfFile.path)],
          text:
              'فاتورة صيدلية السليماني - ${sale.receiptNumber}\nإجمالي: ${CurrencyUtils.format(sale.finalAmount)}',
        );
      } else {
        // Fallback: just share the file
        await Share.shareXFiles(
          [XFile(pdfFile.path)],
          text: 'فاتورة صيدلية السليماني - ${sale.receiptNumber}',
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم مشاركة الفاتورة عبر التطبيق المتاح'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
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
}
