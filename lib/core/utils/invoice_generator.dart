import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../data/models/sale_model.dart';
import '../../data/models/sale_item_model.dart';
import 'currency_utils.dart';
import 'date_utils.dart';

class InvoiceGenerator {
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

  static Future<List<int>> generateInvoiceBytes({
    required SaleModel sale,
    required List<SaleItemModel> items,
    String? customerName,
    String? customerPhone,
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    String? header,
    String? footer,
    String? logoPath,
  }) async {
    await _ensureFonts();

    // Create a new PDF document
    final PdfDocument document = PdfDocument();
    document.pageSettings.size = PdfPageSize.a5;
    document.pageSettings.margins.all = 20;

    // Add a page to the document
    final PdfPage page = document.pages.add();
    final Size pageSize = page.getClientSize();

    // Create fonts
    final PdfFont arabicFont = PdfTrueTypeFont(_fontData!, 10);
    final PdfFont arabicFontBold = PdfTrueTypeFont(_boldFontData!, 12);
    final PdfFont headerFont = PdfTrueTypeFont(_boldFontData!, 16);
    final PdfFont smallFont = PdfTrueTypeFont(_fontData!, 8);

    // RTL format
    final PdfStringFormat rtlFormat = PdfStringFormat(
      textDirection: PdfTextDirection.rightToLeft,
      alignment: PdfTextAlignment.right,
    );

    final PdfStringFormat centerRtlFormat = PdfStringFormat(
      textDirection: PdfTextDirection.rightToLeft,
      alignment: PdfTextAlignment.center,
    );

    double yPos = 0;

    // ── Header ──
    // Load logo if exists
    if (logoPath != null && logoPath.isNotEmpty) {
      try {
        final File file = File(logoPath);
        if (await file.exists()) {
          final Uint8List logoBytes = await file.readAsBytes();
          final PdfBitmap logoImage = PdfBitmap(logoBytes);
          page.graphics.drawImage(logoImage, Rect.fromLTWH(0, yPos, 50, 50));
        }
      } catch (e) {
        debugPrint('Failed to load logo: $e');
      }
    }

    // Shop Info (Centered)
    page.graphics.drawString(
      shopName ?? 'محل السليماني',
      headerFont,
      bounds: Rect.fromLTWH(0, yPos, pageSize.width, 30),
      format: centerRtlFormat,
    );
    yPos += 25;

    if (shopAddress != null) {
      page.graphics.drawString(
        shopAddress,
        arabicFont,
        bounds: Rect.fromLTWH(0, yPos, pageSize.width, 20),
        format: centerRtlFormat,
      );
      yPos += 15;
    }

    if (shopPhone != null) {
      page.graphics.drawString(
        shopPhone,
        arabicFont,
        bounds: Rect.fromLTWH(0, yPos, pageSize.width, 20),
        format: centerRtlFormat,
      );
      yPos += 15;
    }

    yPos += 10;
    page.graphics.drawLine(
        PdfPens.darkGray, Offset(0, yPos), Offset(pageSize.width, yPos));
    yPos += 10;

    // ── Invoice Info ──
    // Left side: Invoice number
    page.graphics.drawString(
      'فاتورة رقم: ${sale.receiptNumber}',
      arabicFont,
      bounds: Rect.fromLTWH(0, yPos, pageSize.width / 2, 20),
      format: PdfStringFormat(textDirection: PdfTextDirection.rightToLeft),
    );

    // Right side: Date and Payment Method
    page.graphics.drawString(
      AppDateUtils.formatToDateTime(sale.date),
      arabicFont,
      bounds: Rect.fromLTWH(pageSize.width / 2, yPos, pageSize.width / 2, 20),
      format: rtlFormat,
    );
    yPos += 15;

    final String paymentMethodStr =
        sale.paymentMethod == 'cash' ? 'نقدي' : 'آجل';
    final PdfBrush paymentBrush =
        sale.paymentMethod == 'cash' ? PdfBrushes.green : PdfBrushes.orange;

    page.graphics.drawString(
      paymentMethodStr,
      arabicFontBold,
      brush: paymentBrush,
      bounds: Rect.fromLTWH(pageSize.width / 2, yPos, pageSize.width / 2, 20),
      format: rtlFormat,
    );
    yPos += 20;

    // ── Customer Info ──
    if (customerName != null) {
      page.graphics.drawString(
        'العميل: $customerName',
        arabicFont,
        bounds: Rect.fromLTWH(0, yPos, pageSize.width, 20),
        format: rtlFormat,
      );
      yPos += 15;
      if (customerPhone != null) {
        page.graphics.drawString(
          'التليفون: $customerPhone',
          arabicFont,
          bounds: Rect.fromLTWH(0, yPos, pageSize.width, 20),
          format: rtlFormat,
        );
        yPos += 15;
      }
      yPos += 5;
    }

    // ── Notes ──
    if (sale.notes != null && sale.notes!.isNotEmpty) {
      final PdfLayoutResult result = PdfTextElement(
        text: 'ملاحظة: ${sale.notes}',
        font: arabicFont,
        format: rtlFormat,
      ).draw(
        page: page,
        bounds: Rect.fromLTWH(0, yPos, pageSize.width, 100),
      )!;
      yPos = result.bounds.bottom + 10;
    }

    // ── Items Table ──
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 4);
    grid.headers.add(1);

    PdfGridRow headerRow = grid.headers[0];
    headerRow.cells[0].value = 'الصنف';
    headerRow.cells[1].value = 'الكمية';
    headerRow.cells[2].value = 'السعر';
    headerRow.cells[3].value = 'الإجمالي';

    // Apply header style
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.font = arabicFontBold;
      headerRow.cells[i].style.backgroundBrush = PdfBrushes.lightGray;
      headerRow.cells[i].style.textBrush = PdfBrushes.black;
      headerRow.cells[i].stringFormat = centerRtlFormat;
    }

    // Add items
    for (final item in items) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = item.product.value?.name ?? '—';
      row.cells[1].value = '${item.quantity}';
      row.cells[2].value = CurrencyUtils.format(item.unitPrice);
      row.cells[3].value = CurrencyUtils.format(item.total);

      for (int i = 0; i < row.cells.count; i++) {
        row.cells[i].style.font = arabicFont;
        row.cells[i].stringFormat = i == 1 ? centerRtlFormat : rtlFormat;
      }
    }

    // Set column widths
    grid.columns[0].width = pageSize.width * 0.45;
    grid.columns[1].width = pageSize.width * 0.15;
    grid.columns[2].width = pageSize.width * 0.20;
    grid.columns[3].width = pageSize.width * 0.20;

    grid.style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);

    final PdfLayoutResult gridResult = grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, yPos, pageSize.width, 0),
    )!;

    yPos = gridResult.bounds.bottom + 15;

    // ── Summary ──
    void drawSummaryRow(String label, String value, PdfFont font,
        {PdfBrush? brush}) {
      page.graphics.drawString(
        label,
        font,
        bounds: Rect.fromLTWH(pageSize.width - 150, yPos, 70, 20),
        format: rtlFormat,
      );
      page.graphics.drawString(
        value,
        font,
        brush: brush,
        bounds: Rect.fromLTWH(pageSize.width - 80, yPos, 80, 20),
        format: rtlFormat,
      );
      yPos += 15;
    }

    drawSummaryRow(
        'الإجمالي:', CurrencyUtils.format(sale.totalAmount), arabicFont);
    if (sale.discount > 0) {
      drawSummaryRow(
          'الخصم:', '- ${CurrencyUtils.format(sale.discount)}', arabicFont,
          brush: PdfBrushes.green);
    }

    yPos += 5;
    page.graphics.drawLine(PdfPens.darkGray, Offset(pageSize.width - 150, yPos),
        Offset(pageSize.width, yPos));
    yPos += 5;

    drawSummaryRow(
        'الصافي:', CurrencyUtils.format(sale.finalAmount), arabicFontBold);
    drawSummaryRow(
        'المدفوع:', CurrencyUtils.format(sale.paidAmount), arabicFont);

    if (sale.remainingAmount > 0) {
      drawSummaryRow(
          'الباقي:', CurrencyUtils.format(sale.remainingAmount), arabicFont,
          brush: PdfBrushes.orange);
    }

    // ── Footer ──
    final double footerY = pageSize.height - 30;
    page.graphics.drawLine(
        PdfPens.darkGray, Offset(0, footerY), Offset(pageSize.width, footerY));
    page.graphics.drawString(
      footer ?? 'شكراً لتعاملكم مع السليماني للتنمية الزراعية',
      smallFont,
      bounds: Rect.fromLTWH(0, footerY + 5, pageSize.width, 20),
      format: centerRtlFormat,
    );

    // Save and dispose
    final List<int> bytes = await document.save();
    document.dispose();
    return bytes;
  }

  static Future<void> printInvoice({
    required SaleModel sale,
    required List<SaleItemModel> items,
    String? customerName,
    String? customerPhone,
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    String? header,
    String? footer,
    String? logoPath,
  }) async {
    final bytes = await generateInvoiceBytes(
      sale: sale,
      items: items,
      customerName: customerName,
      customerPhone: customerPhone,
      shopName: shopName,
      shopAddress: shopAddress,
      shopPhone: shopPhone,
      header: header,
      footer: footer,
      logoPath: logoPath,
    );

    await Printing.layoutPdf(
        onLayout: (format) async => Uint8List.fromList(bytes));
  }

  static Future<List<int>> generatePdfBytes({
    required SaleModel sale,
    required List<SaleItemModel> items,
    String? customerName,
    String? customerPhone,
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    String? header,
    String? footer,
    String? logoPath,
  }) async {
    return await generateInvoiceBytes(
      sale: sale,
      items: items,
      customerName: customerName,
      customerPhone: customerPhone,
      shopName: shopName,
      shopAddress: shopAddress,
      shopPhone: shopPhone,
      header: header,
      footer: footer,
      logoPath: logoPath,
    );
  }
}
