import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'currency_utils.dart';

/// Exports report data to PDF and CSV formats
class ReportExporter {
  /// Export sales data to a PDF file
  static Future<File> exportToPdf({
    required List<ReportSaleData> sales,
    required String title,
    required DateTime fromDate,
    required DateTime toDate,
    required double totalSales,
    required double totalProfit,
    required String filePath,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        header: (context) => _buildPdfHeader(title, fromDate, toDate),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          _buildPdfSummary(totalSales, totalProfit, sales.length),
          pw.SizedBox(height: 20),
          _buildPdfTable(sales),
        ],
      ),
    );

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildPdfHeader(String title, DateTime from, DateTime to) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'صيدلية السليماني',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'تقرير المبيعات',
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'من: ${_formatDate(from)} - إلى: ${_formatDate(to)}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'تاريخ الطباعة: ${_formatDate(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'صفحة ${context.pageNumber} من ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  static pw.Widget _buildPdfSummary(
      double totalSales, double totalProfit, int count) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
              'إجمالي المبيعات', CurrencyUtils.format(totalSales)),
          _buildSummaryItem('إجمالي الربح', CurrencyUtils.format(totalProfit)),
          _buildSummaryItem('عدد الفواتير', count.toString()),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfTable(List<ReportSaleData> sales) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey200,
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.center,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
      },
      headers: [
        'رقم الفاتورة',
        'التاريخ',
        'طريقة الدفع',
        'الإجمالي',
        'الخصم',
        'الصافي',
      ],
      data: sales.map((sale) {
        return [
          sale.receiptNumber,
          _formatDate(sale.date),
          sale.paymentMethod == 'cash' ? 'نقدي' : 'آجل',
          CurrencyUtils.format(sale.totalAmount),
          CurrencyUtils.format(sale.discount),
          CurrencyUtils.format(sale.finalAmount),
        ];
      }).toList(),
    );
  }

  /// Export sales data to a CSV file
  static Future<File> exportToCsv({
    required List<ReportSaleData> sales,
    required String title,
    required DateTime fromDate,
    required DateTime toDate,
    required String filePath,
  }) async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('# تقرير المبيعات');
    buffer.writeln(
        '# من: ${_formatDate(fromDate)} - إلى: ${_formatDate(toDate)}');
    buffer.writeln('# تاريخ الطباعة: ${_formatDate(DateTime.now())}');
    buffer.writeln('');

    // CSV headers
    buffer.writeln('رقم الفاتورة,التاريخ,طريقة الدفع,الإجمالي,الخصم,الصافي');

    // Data rows
    for (final sale in sales) {
      buffer.writeln(
        '${_escapeCsv(sale.receiptNumber)},'
        '${_formatDate(sale.date)},'
        '${sale.paymentMethod == "cash" ? "نقدي" : "آجل"},'
        '${sale.totalAmount},'
        '${sale.discount},'
        '${sale.finalAmount}',
      );
    }

    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    return file;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Get a temporary file path for export
  static Future<String> _getExportPath(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$filename';
  }

  /// Generate report export file path
  static Future<String> getReportPath({required String type}) async {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final ext = type == 'pdf' ? 'pdf' : 'csv';
    return await _getExportPath('report_$timestamp.$ext');
  }
}

/// Lightweight sale data for report export
class ReportSaleData {
  final String receiptNumber;
  final DateTime date;
  final String paymentMethod;
  final double totalAmount;
  final double discount;
  final double finalAmount;

  ReportSaleData({
    required this.receiptNumber,
    required this.date,
    required this.paymentMethod,
    required this.totalAmount,
    required this.discount,
    required this.finalAmount,
  });
}
