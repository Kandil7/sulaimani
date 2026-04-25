import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/reports_state.dart';

class InvoicesTable extends StatefulWidget {
  final List<InvoiceReportItem> invoices;
  final Function(String)? onExport;

  const InvoicesTable({
    super.key,
    required this.invoices,
    this.onExport,
  });

  @override
  State<InvoicesTable> createState() => _InvoicesTableState();
}

class _InvoicesTableState extends State<InvoicesTable> {
  int _currentPage = 0;
  final int _itemsPerPage = 50;

  void _exportToCsv() {
    final buffer = StringBuffer();
    // Header
    buffer.writeln('#,رقم الفاتورة,العميل,المبلغ,طريقة الدفع,التاريخ');
    // Data rows
    for (var i = 0; i < widget.invoices.length; i++) {
      final invoice = widget.invoices[i];
      buffer.writeln(
        '${i + 1},${invoice.invoiceNumber},"${invoice.customerName ?? ''}",${invoice.amount},${invoice.paymentType},${_formatDate(invoice.date)}',
      );
    }
    // Total row
    final total = widget.invoices.fold<double>(
      0,
      (sum, inv) => sum + inv.amount,
    );
    buffer.writeln(',,"الإجمالي",$total,,');

    // Save to file
    _saveCsvFile(buffer.toString());
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveCsvFile(String csvContent) async {
    try {
      // Get documents directory for saving
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'تقرير_المبيعات_$timestamp.csv';
      final filePath = '${dir.path}/$fileName';

      // Write file
      final file = File(filePath);
      await file.writeAsString(csvContent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تصدير الملف: $filePath'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'نسخ المسار',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: filePath));
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Fallback: show dialog with CSV content and copy to clipboard
      if (mounted) {
        _showCsvDialog(csvContent);
      }
    }
  }

  void _showCsvDialog(String csvContent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصدير CSV'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              const Text('يمكن نسخ المحتوى أدناه:'),
              const SizedBox(height: AppSizes.md),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      csvContent,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvContent));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم النسخ إلى الحافظة'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('نسخ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (widget.invoices.length / _itemsPerPage).ceil();
    final displayInvoices = widget.invoices
        .skip(_currentPage * _itemsPerPage)
        .take(_itemsPerPage)
        .toList();
    final totalAmount =
        widget.invoices.fold<double>(0, (sum, inv) => sum + inv.amount);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('جدول الفواتير', style: AppTextStyles.h3),
                if (widget.invoices.isNotEmpty)
                  TextButton.icon(
                    onPressed: _exportToCsv,
                    icon: const Icon(Icons.download, size: 20),
                    label: const Text('تصدير CSV'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table
          if (widget.invoices.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long,
                        size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      'لا توجد فواتير في هذه الفترة',
                      style: AppTextStyles.bodyM,
                    ),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.background),
                dataRowColor: WidgetStateProperty.all(Colors.white),
                columnSpacing: AppSizes.lg,
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('رقم الفاتورة')),
                  DataColumn(label: Text('العميل')),
                  DataColumn(label: Text('المبلغ')),
                  DataColumn(label: Text('طريقة الدفع')),
                  DataColumn(label: Text('التاريخ')),
                ],
                rows: [
                  ...displayInvoices.asMap().entries.map((entry) {
                    final index = entry.key;
                    final invoice = entry.value;
                    return DataRow(
                      color: WidgetStateProperty.all(
                        index.isOdd ? AppColors.background : Colors.white,
                      ),
                      cells: [
                        DataCell(Text(
                            '${_currentPage * _itemsPerPage + index + 1}')),
                        DataCell(Text(invoice.invoiceNumber)),
                        DataCell(Text(invoice.customerName ?? '-')),
                        DataCell(Text(invoice.amount.toStringAsFixed(0))),
                        DataCell(_PaymentTypeBadge(type: invoice.paymentType)),
                        DataCell(Text(_formatDate(invoice.date))),
                      ],
                    );
                  }),
                  // Total row
                  DataRow(
                    color: WidgetStateProperty.all(AppColors.primarySurface),
                    cells: [
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      DataCell(
                        Text(
                          'الإجمالي',
                          style: AppTextStyles.bodyL.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          totalAmount.toStringAsFixed(0),
                          style: AppTextStyles.bodyL.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                    ],
                  ),
                ],
              ),
            ),
          // Pagination
          if (widget.invoices.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'صفحة ${_currentPage + 1} من $totalPages',
                    style: AppTextStyles.caption,
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _currentPage > 0
                            ? () => setState(() => _currentPage--)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                        disabledColor: Colors.grey.shade300,
                      ),
                      IconButton(
                        onPressed: _currentPage < totalPages - 1
                            ? () => setState(() => _currentPage++)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                        disabledColor: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentTypeBadge extends StatelessWidget {
  final String type;

  const _PaymentTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isCash = type == 'نقدي';
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
        type,
        style: AppTextStyles.caption.copyWith(
          color: isCash ? AppColors.success : AppColors.warning,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
