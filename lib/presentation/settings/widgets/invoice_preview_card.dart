import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';

class InvoicePreviewCard extends StatelessWidget {
  final String header;
  final String footer;
  final String? logoPath;
  final String pharmacyName;

  const InvoicePreviewCard({
    super.key,
    required this.header,
    required this.footer,
    this.logoPath,
    required this.pharmacyName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.preview, color: AppColors.primary),
                const SizedBox(width: AppSizes.sm),
                Text('معاينة الفاتورة', style: AppTextStyles.h2),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: AppSizes.lg),

            // Invoice Preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  if (logoPath != null)
                    Center(
                      child: Image.file(
                        File(logoPath!),
                        height: 60,
                        width: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                  // Pharmacy Name
                  Center(
                    child: Text(
                      pharmacyName.isNotEmpty
                          ? pharmacyName
                          : 'صيدلية السليماني',
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: AppSizes.md),
                  const Divider(),
                  const SizedBox(height: AppSizes.md),

                  // Header
                  if (header.isNotEmpty)
                    Text(
                      header,
                      style: AppTextStyles.bodyM,
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: AppSizes.lg),

                  // Items table placeholder
                  _buildItemRow('باراسيتامول', '2', '20.00'),
                  _buildItemRow('ابيكس', '1', '45.00'),
                  _buildItemRow('فيتا سي', '3', '15.00'),

                  const Divider(),
                  const SizedBox(height: AppSizes.sm),

                  // Totals
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('المجموع:', style: AppTextStyles.bodyL),
                      const Text('115.00', style: AppTextStyles.bodyL),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الضريبة:', style: AppTextStyles.bodyM),
                      const Text('9.00', style: AppTextStyles.bodyM),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الإجمالي:', style: AppTextStyles.h3),
                      Text('124.00', style: AppTextStyles.h3),
                    ],
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Footer
                  if (footer.isNotEmpty)
                    Text(
                      footer,
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: AppSizes.md),

                  // Thank you message
                  Center(
                    child: Text(
                      'شكراً لتعاملكم',
                      style: AppTextStyles.bodyM.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(String name, String qty, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(name, style: AppTextStyles.bodyM),
          ),
          Text('$qty × ', style: AppTextStyles.caption),
          Text('$price', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
