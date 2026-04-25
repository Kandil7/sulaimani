import 'package:equatable/equatable.dart';

enum ReportFilter { today, thisWeek, thisMonth, custom }

class ReportData extends Equatable {
  final double totalSales;
  final int invoicesCount;
  final double averageInvoice;
  final double totalDebt;
  final List<DailySalesReport> dailySales;
  final List<ProductSalesData> topProducts;
  final List<InvoiceReportItem> invoices;
  final DateTime fromDate;
  final DateTime toDate;
  final ReportFilter filter;
  final double totalProfit;
  final double profitMargin;

  const ReportData({
    required this.totalSales,
    required this.invoicesCount,
    required this.averageInvoice,
    required this.totalDebt,
    required this.dailySales,
    required this.topProducts,
    required this.invoices,
    required this.fromDate,
    required this.toDate,
    required this.filter,
    required this.totalProfit,
    required this.profitMargin,
  });

  @override
  List<Object?> get props => [
        totalSales,
        invoicesCount,
        averageInvoice,
        totalDebt,
        dailySales,
        topProducts,
        invoices,
        fromDate,
        toDate,
        filter,
        totalProfit,
        profitMargin,
      ];
}

class DailySalesReport extends Equatable {
  final DateTime date;
  final double amount;
  final int count;

  const DailySalesReport({
    required this.date,
    required this.amount,
    required this.count,
  });

  @override
  List<Object?> get props => [date, amount, count];
}

class ProductSalesData extends Equatable {
  final String productName;
  final int quantitySold;
  final double revenue;

  const ProductSalesData({
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });

  @override
  List<Object?> get props => [productName, quantitySold, revenue];
}

class InvoiceReportItem extends Equatable {
  final int id;
  final String invoiceNumber;
  final String? customerName;
  final double amount;
  final String paymentType;
  final DateTime date;

  const InvoiceReportItem({
    required this.id,
    required this.invoiceNumber,
    this.customerName,
    required this.amount,
    required this.paymentType,
    required this.date,
  });

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        customerName,
        amount,
        paymentType,
        date,
      ];
}

abstract class ReportsState extends Equatable {
  const ReportsState();
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final ReportData data;

  const ReportsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}
