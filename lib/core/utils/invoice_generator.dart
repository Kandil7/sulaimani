import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/sale_model.dart';
import '../../data/models/sale_item_model.dart';
import 'currency_utils.dart';
import 'date_utils.dart';

class InvoiceGenerator {
  static Future<pw.Document> generateInvoice({
    required SaleModel sale,
    required List<SaleItemModel> items,
    String? customerName,
    String? customerPhone,
    String? shopName,
    String? shopAddress,
    String? shopPhone,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      shopName ?? 'صيدلية السليماني',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (shopAddress != null)
                      pw.Text(
                        shopAddress,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    if (shopPhone != null)
                      pw.Text(
                        shopPhone,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Invoice Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('فاتورة رقم: ${sale.receiptNumber}'),
                  pw.Text(AppDateUtils.formatToDate(sale.date)),
                ],
              ),
              pw.SizedBox(height: 20),

              // Customer Info (if credit)
              if (customerName != null) ...[
                pw.Text('العميل: $customerName'),
                if (customerPhone != null) pw.Text('التليفون: $customerPhone'),
                pw.SizedBox(height: 10),
              ],

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'الصنف',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'الكمية',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'السعر',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'الإجمالي',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  ...items.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(item.product.value?.name ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('${item.quantity}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(CurrencyUtils.format(item.unitPrice)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(CurrencyUtils.format(item.total)),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 20),

              // Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'الإجمالي: ${CurrencyUtils.format(sale.totalAmount)}',
                      ),
                      if (sale.discount > 0)
                        pw.Text(
                          'الخصم: ${CurrencyUtils.format(sale.discount)}',
                        ),
                      pw.Text(
                        'الصافي: ${CurrencyUtils.format(sale.finalAmount)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'المدفوع: ${CurrencyUtils.format(sale.finalAmount)}',
                      ),
                      pw.Text(
                        'الباقي: ${CurrencyUtils.format(0)}',
                      ),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'شكراً لتعاملكم مع صيدلية السليماني',
                  style: const pw.TextStyle(fontSize: 10),
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
  }) async {
    final pdf = await generateInvoice(
      sale: sale,
      items: items,
      customerName: customerName,
      customerPhone: customerPhone,
      shopName: shopName,
      shopAddress: shopAddress,
      shopPhone: shopPhone,
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
  }) async {
    final pdf = await generateInvoice(
      sale: sale,
      items: items,
      customerName: customerName,
      customerPhone: customerPhone,
      shopName: shopName,
      shopAddress: shopAddress,
      shopPhone: shopPhone,
    );
    return pdf.save();
  }
}
