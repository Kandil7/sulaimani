import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/sale_model.dart';
import '../../data/models/sale_item_model.dart';
import 'currency_utils.dart';
import 'date_utils.dart';

class InvoiceGenerator {
  static pw.Font? _arabicFont;
  static pw.Font? _arabicFontBold;

  static Future<void> _ensureFonts() async {
    if (_arabicFont != null) return;
    final fontData =
        await rootBundle.load('assets/fonts/Cairo/Cairo-Regular.ttf');
    final fontBytes = fontData.buffer.asByteData();
    final boldData = await rootBundle.load('assets/fonts/Cairo/Cairo-Bold.ttf');
    final boldBytes = boldData.buffer.asByteData();
    _arabicFont = pw.Font.ttf(fontBytes);
    _arabicFontBold = pw.Font.ttf(boldBytes);
  }

  static pw.Widget _cell(
    String text, {
    pw.Font? font,
    PdfColor? color,
    bool alignCenter = false,
    double fontSize = 9,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font ?? _arabicFont,
          fontSize: fontSize,
          color: color ?? PdfColors.black,
        ),
        textAlign: alignCenter ? pw.TextAlign.center : pw.TextAlign.right,
      ),
    );
  }

  static Future<pw.Document> generateInvoice({
    required SaleModel sale,
    required List<SaleItemModel> items,
    String? customerName,
    String? customerPhone,
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    String? header,
    String? footer,
  }) async {
    await _ensureFonts();
    final pdf = pw.Document();
    final font = _arabicFont!;
    final fontBold = _arabicFontBold!;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ── Header ──
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      shopName ?? 'صيدلية السليماني',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                      textDirection: pw.TextDirection.rtl,
                    ),
                    if (shopAddress != null)
                      pw.Text(
                        shopAddress,
                        style: pw.TextStyle(font: font, fontSize: 9),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    if (shopPhone != null)
                      pw.Text(
                        shopPhone,
                        style: pw.TextStyle(font: font, fontSize: 9),
                        textDirection: pw.TextDirection.rtl,
                      ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // ── Invoice Info ──
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'فاتورة رقم: ${sale.receiptNumber}',
                    style: pw.TextStyle(font: font, fontSize: 10),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        AppDateUtils.formatToDate(sale.date),
                        style: pw.TextStyle(font: font, fontSize: 10),
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.Text(
                        sale.paymentMethod == 'cash' ? 'نقدي' : 'آجل',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: sale.paymentMethod == 'cash'
                              ? PdfColors.green700
                              : PdfColors.orange700,
                        ),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),

              // ── Customer Info ──
              if (customerName != null) ...[
                pw.Text(
                  'العميل: $customerName',
                  style: pw.TextStyle(font: font, fontSize: 10),
                  textDirection: pw.TextDirection.rtl,
                ),
                if (customerPhone != null)
                  pw.Text(
                    'التليفون: $customerPhone',
                    style: pw.TextStyle(font: font, fontSize: 9),
                    textDirection: pw.TextDirection.rtl,
                  ),
                pw.SizedBox(height: 8),
              ],

              // ── Items Table ──
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _cell('الصنف', font: fontBold),
                      _cell('الكمية', font: fontBold, alignCenter: true),
                      _cell('السعر', font: fontBold),
                      _cell('الإجمالي', font: fontBold),
                    ],
                  ),
                  ...items.map((item) {
                    return pw.TableRow(
                      children: [
                        _cell(item.product.value?.name ?? '—'),
                        _cell('${item.quantity}', alignCenter: true),
                        _cell(CurrencyUtils.format(item.unitPrice)),
                        _cell(
                          CurrencyUtils.format(item.total),
                          font: fontBold,
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 16),

              // ── Summary (right-aligned in RTL) ──
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          CurrencyUtils.format(sale.totalAmount),
                          style: pw.TextStyle(font: font, fontSize: 10),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.SizedBox(width: 8),
                        pw.SizedBox(
                          width: 65,
                          child: pw.Text(
                            'الإجمالي:',
                            style: pw.TextStyle(font: font, fontSize: 10),
                            textDirection: pw.TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                    if (sale.discount > 0)
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            '- ${CurrencyUtils.format(sale.discount)}',
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 10,
                              color: PdfColors.green700,
                            ),
                            textDirection: pw.TextDirection.rtl,
                          ),
                          pw.SizedBox(width: 8),
                          pw.SizedBox(
                            width: 65,
                            child: pw.Text(
                              'الخصم:',
                              style: pw.TextStyle(font: font, fontSize: 10),
                              textDirection: pw.TextDirection.rtl,
                            ),
                          ),
                        ],
                      ),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          CurrencyUtils.format(sale.finalAmount),
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.SizedBox(width: 8),
                        pw.SizedBox(
                          width: 65,
                          child: pw.Text(
                            'الصافي:',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textDirection: pw.TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          CurrencyUtils.format(sale.paidAmount),
                          style: pw.TextStyle(font: font, fontSize: 10),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.SizedBox(width: 8),
                        pw.SizedBox(
                          width: 65,
                          child: pw.Text(
                            'المدفوع:',
                            style: pw.TextStyle(font: font, fontSize: 10),
                            textDirection: pw.TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                    if (sale.remainingAmount > 0)
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            CurrencyUtils.format(sale.remainingAmount),
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 10,
                              color: PdfColors.orange700,
                            ),
                            textDirection: pw.TextDirection.rtl,
                          ),
                          pw.SizedBox(width: 8),
                          pw.SizedBox(
                            width: 65,
                            child: pw.Text(
                              'الباقي:',
                              style: pw.TextStyle(font: font, fontSize: 10),
                              textDirection: pw.TextDirection.rtl,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              pw.Spacer(),

              // ── Footer ──
              pw.Divider(),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  footer ?? 'شكراً لتعاملكم مع صيدلية السليماني',
                  style: pw.TextStyle(font: font, fontSize: 8),
                  textDirection: pw.TextDirection.rtl,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
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
  }) async {
    final pdf = await generateInvoice(
      sale: sale,
      items: items,
      customerName: customerName,
      customerPhone: customerPhone,
      shopName: shopName,
      shopAddress: shopAddress,
      shopPhone: shopPhone,
      header: header,
      footer: footer,
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
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
  }) async {
    final pdf = await generateInvoice(
      sale: sale,
      items: items,
      customerName: customerName,
      customerPhone: customerPhone,
      shopName: shopName,
      shopAddress: shopAddress,
      shopPhone: shopPhone,
      header: header,
      footer: footer,
    );
    return pdf.save();
  }
}
