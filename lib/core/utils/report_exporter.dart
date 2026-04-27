import 'dart:io';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'currency_utils.dart';

/// Exports report data to PDF and CSV formats using Syncfusion
class ReportExporter {
  static Uint8List? _fontData;
  static Uint8List? _boldFontData;

  static Future<void> _ensureFonts() async {
    if (_fontData != null && _boldFontData != null) return;

    _fontData = (await rootBundle.load('assets/fonts/Cairo/Cairo-Regular.ttf'))
        .buffer
        .asUint8List();

    _boldFontData = (await rootBundle.load('assets/fonts/Cairo/Cairo-Bold.ttf'))
        .buffer
        .asUint8List();
  }

  /// Export sales data to a PDF file
  static Future<File> exportToPdf({
    required List<ReportSaleData> sales,
    required String title,
    required DateTime fromDate,
    required DateTime toDate,
    required double totalSales,
    required double totalProfit,
    required String filePath,
    String? shopName,
  }) async {
    await _ensureFonts();

    final PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 30;

    final PdfFont arabicFont = PdfTrueTypeFont(_fontData!, 10);
    final PdfFont arabicFontBold = PdfTrueTypeFont(_boldFontData!, 12);
    final PdfFont headerFont = PdfTrueTypeFont(_boldFontData!, 18);

    final PdfStringFormat rtlFormat = PdfStringFormat(
      textDirection: PdfTextDirection.rightToLeft,
      alignment: PdfTextAlignment.right,
    );

    final PdfStringFormat centerRtlFormat = PdfStringFormat(
      textDirection: PdfTextDirection.rightToLeft,
      alignment: PdfTextAlignment.center,
    );

    final PdfPage page = document.pages.add();
    final Size pageSize = page.getClientSize();
    double yPos = 0;

    // Header
    page.graphics.drawString(
      shopName ?? 'محل السليماني',
      headerFont,
      bounds: Rect.fromLTWH(0, yPos, pageSize.width, 30),
      format: centerRtlFormat,
    );
    yPos += 30;

    page.graphics.drawString(
      'تقرير المبيعات - $title',
      arabicFontBold,
      bounds: Rect.fromLTWH(0, yPos, pageSize.width, 25),
      format: centerRtlFormat,
    );
    yPos += 25;

    page.graphics.drawString(
      'من: ${_formatDate(fromDate)} - إلى: ${_formatDate(toDate)}',
      arabicFont,
      bounds: Rect.fromLTWH(0, yPos, pageSize.width, 20),
      format: centerRtlFormat,
    );
    yPos += 20;

    page.graphics.drawString(
      'تاريخ الطباعة: ${_formatDate(DateTime.now())}',
      arabicFont,
      bounds: Rect.fromLTWH(0, yPos, pageSize.width, 20),
      format: rtlFormat,
    );
    yPos += 25;

    page.graphics
        .drawLine(PdfPens.black, Offset(0, yPos), Offset(pageSize.width, yPos));
    yPos += 15;

    // Summary Box
    final PdfGrid summaryGrid = PdfGrid();
    summaryGrid.columns.add(count: 3);
    PdfGridRow summaryRow = summaryGrid.rows.add();

    summaryRow.cells[0].value =
        'إجمالي المبيعات\n${CurrencyUtils.format(totalSales)}';
    summaryRow.cells[1].value =
        'إجمالي الربح\n${CurrencyUtils.format(totalProfit)}';
    summaryRow.cells[2].value = 'عدد الفواتير\n${sales.length}';

    for (int i = 0; i < 3; i++) {
      summaryRow.cells[i].style.font = arabicFontBold;
      summaryRow.cells[i].stringFormat = centerRtlFormat;
      summaryRow.cells[i].style.backgroundBrush = PdfBrushes.lightGray;
    }

    final PdfLayoutResult summaryResult = summaryGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, yPos, pageSize.width, 0),
    )!;
    yPos = summaryResult.bounds.bottom + 20;

    // Sales Table
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 6);
    grid.headers.add(1);

    PdfGridRow headerRow = grid.headers[0];
    headerRow.cells[0].value = 'رقم الفاتورة';
    headerRow.cells[1].value = 'التاريخ';
    headerRow.cells[2].value = 'طريقة الدفع';
    headerRow.cells[3].value = 'الإجمالي';
    headerRow.cells[4].value = 'الخصم';
    headerRow.cells[5].value = 'الصافي';

    for (int i = 0; i < 6; i++) {
      headerRow.cells[i].style.font = arabicFontBold;
      headerRow.cells[i].style.backgroundBrush = PdfBrushes.darkGray;
      headerRow.cells[i].style.textBrush = PdfBrushes.white;
      headerRow.cells[i].stringFormat = centerRtlFormat;
    }

    for (final sale in sales) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = sale.receiptNumber;
      row.cells[1].value = _formatDate(sale.date);
      row.cells[2].value = sale.paymentMethod == 'cash' ? 'نقدي' : 'آجل';
      row.cells[3].value = CurrencyUtils.format(sale.totalAmount);
      row.cells[4].value = CurrencyUtils.format(sale.discount);
      row.cells[5].value = CurrencyUtils.format(sale.finalAmount);

      for (int i = 0; i < 6; i++) {
        row.cells[i].style.font = arabicFont;
        row.cells[i].stringFormat = rtlFormat;
      }
    }

    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, yPos, pageSize.width, 0),
    );

    final file = File(filePath);
    await file.writeAsBytes(await document.save());
    document.dispose();
    return file;
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
