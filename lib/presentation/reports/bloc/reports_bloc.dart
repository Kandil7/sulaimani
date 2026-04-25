import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/generic_repository.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/models/sale_item_model.dart';
import '../../../data/models/customer_model.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GenericRepository<SaleModel> saleRepository;
  final GenericRepository<SaleItemModel> saleItemRepository;
  final GenericRepository<CustomerModel> customerRepository;

  DateTime _currentFromDate = DateTime.now();
  DateTime _currentToDate = DateTime.now();
  ReportFilter _currentFilter = ReportFilter.today;

  ReportsBloc({
    required this.saleRepository,
    required this.saleItemRepository,
    required this.customerRepository,
  }) : super(ReportsInitial()) {
    on<LoadReport>(_onLoadReport);
    on<ChangeFilter>(_onChangeFilter);
    on<ExportReport>(_onExportReport);
    on<RefreshReport>(_onRefreshReport);
  }

  DateTime get _startOfDay {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _endOfDay {
    return _startOfDay.add(const Duration(days: 1));
  }

  DateTime get _startOfWeek {
    final now = DateTime.now();
    final daysFromSaturday = now.weekday % 7;
    return DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysFromSaturday));
  }

  DateTime get _startOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  (DateTime, DateTime, ReportFilter) _getDateRangeForFilter(
      ReportFilter filter) {
    switch (filter) {
      case ReportFilter.today:
        return (_startOfDay, _endOfDay, ReportFilter.today);
      case ReportFilter.thisWeek:
        return (_startOfWeek, DateTime.now(), ReportFilter.thisWeek);
      case ReportFilter.thisMonth:
        return (_startOfMonth, DateTime.now(), ReportFilter.thisMonth);
      case ReportFilter.custom:
        return (
          _currentFromDate,
          _currentToDate.add(const Duration(days: 1)),
          ReportFilter.custom
        );
    }
  }

  Future<void> _onLoadReport(
    LoadReport event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final from = event.from;
      final to = event.to;
      final filter = event.filter;

      _currentFromDate = from;
      _currentToDate = to;
      _currentFilter = filter;

      // Get all sales
      final allSales = await saleRepository.getAll();

      // Filter sales by date range
      final filteredSales = allSales
          .where((sale) =>
              sale.createdAt
                  .isAfter(from.subtract(const Duration(seconds: 1))) &&
              sale.createdAt.isBefore(to))
          .toList();

      // Sort by date descending
      filteredSales.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Calculate totals
      final totalSales =
          filteredSales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
      final invoicesCount = filteredSales.length;
      final averageInvoice =
          invoicesCount > 0 ? totalSales / invoicesCount : 0.0;

      // Get total debt
      final customers = await customerRepository.getAll();
      final totalDebt =
          customers.fold<double>(0, (sum, c) => sum + c.debtBalance);

      // Generate daily sales data
      final dailySalesMap = <String, DailySalesReport>{};
      var currentDate = DateTime(from.year, from.month, from.day);
      final endDate = DateTime(to.year, to.month, to.day);

      while (!currentDate.isAfter(endDate)) {
        final dateKey =
            '${currentDate.year}-${currentDate.month}-${currentDate.day}';
        dailySalesMap[dateKey] = DailySalesReport(
          date: currentDate,
          amount: 0,
          count: 0,
        );
        currentDate = currentDate.add(const Duration(days: 1));
      }

      for (final sale in filteredSales) {
        final saleDateKey =
            '${sale.createdAt.year}-${sale.createdAt.month}-${sale.createdAt.day}';
        if (dailySalesMap.containsKey(saleDateKey)) {
          final existing = dailySalesMap[saleDateKey]!;
          dailySalesMap[saleDateKey] = DailySalesReport(
            date: existing.date,
            amount: existing.amount + sale.totalAmount,
            count: existing.count + 1,
          );
        }
      }

      final dailySales = dailySalesMap.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      // Get all sale items once
      final allSaleItems = await saleItemRepository.getAll();

      // Build lookup for sale items by sale id
      final saleItemsBySaleId = <int, List<SaleItemModel>>{};
      for (final item in allSaleItems) {
        final saleId = item.sale.value?.id ?? 0;
        if (saleId > 0) {
          saleItemsBySaleId.putIfAbsent(saleId, () => []).add(item);
        }
      }

      // Get top 5 products
      final productSalesMap = <int, ProductSalesData>{};

      for (final sale in filteredSales) {
        final items = saleItemsBySaleId[sale.id] ?? [];

        for (final item in items) {
          final productModel = item.product.value;
          final productId = productModel?.id ?? 0;
          final productName = productModel?.name ?? 'غير معروف';

          if (productSalesMap.containsKey(productId)) {
            final existing = productSalesMap[productId]!;
            productSalesMap[productId] = ProductSalesData(
              productName: productName,
              quantitySold: existing.quantitySold + item.quantity,
              revenue: existing.revenue + item.total,
            );
          } else {
            productSalesMap[productId] = ProductSalesData(
              productName: productName,
              quantitySold: item.quantity,
              revenue: item.total,
            );
          }
        }
      }

      final topProducts = productSalesMap.values.toList()
        ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

      final top5Products = topProducts.take(5).toList();

      // Map invoices to report items
      final invoices = filteredSales.map((sale) {
        String paymentTypeArabic;
        if (sale.paymentMethod == 'cash') {
          paymentTypeArabic = 'نقدي';
        } else if (sale.paymentMethod == 'deferred' ||
            sale.paymentMethod == 'credit') {
          paymentTypeArabic = 'آجل';
        } else {
          paymentTypeArabic = sale.paymentMethod;
        }

        return InvoiceReportItem(
          id: sale.id,
          invoiceNumber: sale.receiptNumber,
          customerName: sale.customerName,
          amount: sale.finalAmount,
          paymentType: paymentTypeArabic,
          date: sale.createdAt,
        );
      }).toList();

      // Calculate profit
      double totalProfit = 0;
      for (final sale in filteredSales) {
        final items = saleItemsBySaleId[sale.id] ?? [];

        for (final item in items) {
          final productModel = item.product.value;
          final sellingPrice = item.unitPrice;
          final purchasePrice = productModel?.purchasePrice ?? 0;
          final profit = (sellingPrice - purchasePrice) * item.quantity;
          totalProfit += profit;
        }
      }

      final profitMargin =
          totalSales > 0 ? (totalProfit / totalSales) * 100 : 0.0;

      final reportData = ReportData(
        totalSales: totalSales,
        invoicesCount: invoicesCount,
        averageInvoice: averageInvoice,
        totalDebt: totalDebt,
        dailySales: dailySales,
        topProducts: top5Products,
        invoices: invoices,
        fromDate: from,
        toDate: to,
        filter: filter,
        totalProfit: totalProfit,
        profitMargin: profitMargin,
      );

      emit(ReportsLoaded(reportData));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _onChangeFilter(
    ChangeFilter event,
    Emitter<ReportsState> emit,
  ) async {
    final (from, to, filter) = _getDateRangeForFilter(event.filter);
    add(LoadReport(from: from, to: to, filter: filter));
  }

  Future<void> _onExportReport(
    ExportReport event,
    Emitter<ReportsState> emit,
  ) async {
    // Export is handled in the UI
  }

  Future<void> _onRefreshReport(
    RefreshReport event,
    Emitter<ReportsState> emit,
  ) async {
    final (from, to, filter) = _getDateRangeForFilter(_currentFilter);
    add(LoadReport(from: from, to: to, filter: filter));
  }
}
