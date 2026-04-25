import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/generic_repository.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/models/customer_model.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GenericRepository<ProductModel> productRepository;
  final GenericRepository<SaleModel> saleRepository;
  final GenericRepository<CustomerModel> customerRepository;

  DashboardBloc({
    required this.productRepository,
    required this.saleRepository,
    required this.customerRepository,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get today's sales
      final todaySales = await saleRepository.getAll();
      final todayInvoices = todaySales
          .where((sale) =>
              sale.createdAt.isAfter(startOfDay) &&
              sale.createdAt.isBefore(endOfDay))
          .toList();
      final todaySalesTotal =
          todayInvoices.fold<double>(0, (sum, sale) => sum + sale.totalAmount);

      // Get all products count
      final products = await productRepository.getAll();
      final totalProducts = products.length;

      // Get alerts count (low stock + expiring)
      final alertsCount = products.where((p) {
        if (p.expiryDate != null) {
          final daysUntilExpiry =
              p.expiryDate!.difference(DateTime.now()).inDays;
          return p.stockQuantity <= p.minimumStock || daysUntilExpiry <= 30;
        }
        return p.stockQuantity <= p.minimumStock;
      }).length;

      // Get total debt
      final customers = await customerRepository.getAll();
      final totalDebt =
          customers.fold<double>(0, (sum, c) => sum + c.debtBalance);

      // Get last 7 days sales
      final last7Days = <DailySales>[];
      for (int i = 6; i >= 0; i--) {
        final date = startOfDay.subtract(Duration(days: i));
        final nextDate = date.add(const Duration(days: 1));
        final daySales = await saleRepository.getAll();
        final dayInvoices = daySales
            .where((s) =>
                s.createdAt.isAfter(date) && s.createdAt.isBefore(nextDate))
            .toList();
        last7Days.add(DailySales(
          date: date,
          amount: dayInvoices.fold<double>(0, (sum, s) => sum + s.totalAmount),
          count: dayInvoices.length,
        ));
      }

      // Get recent sales
      final allSales = await saleRepository.getAll();
      allSales.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final recentSales = allSales
          .take(5)
          .map((s) => RecentSale(
                id: s.id,
                invoiceNumber: s.receiptNumber,
                amount: s.finalAmount,
                paymentType: s.paymentMethod == 'cash' ? 'نقدي' : 'آجل',
                createdAt: s.createdAt,
              ))
          .toList();

      // Get urgent alerts
      final urgentAlerts = products
          .where((p) {
            if (p.expiryDate != null) {
              final daysUntilExpiry =
                  p.expiryDate!.difference(DateTime.now()).inDays;
              return daysUntilExpiry <= 0 || p.stockQuantity <= p.minimumStock;
            }
            return p.stockQuantity <= p.minimumStock;
          })
          .take(3)
          .map((p) => AlertItem(
                productId: p.id,
                productName: p.name,
                type: p.expiryDate != null &&
                        p.expiryDate!.difference(DateTime.now()).inDays <= 0
                    ? 'منتهي'
                    : 'مخزون منخفض',
                message: p.expiryDate != null &&
                        p.expiryDate!.difference(DateTime.now()).inDays <= 0
                    ? 'منتهي الصلاحية'
                    : '${p.stockQuantity} قطعة',
              ))
          .toList();

      emit(DashboardLoaded(
        todaySales: todaySalesTotal,
        todayInvoicesCount: todayInvoices.length,
        totalProductsCount: totalProducts,
        alertsCount: alertsCount,
        totalDebt: totalDebt,
        last7DaysSales: last7Days,
        recentSales: recentSales,
        urgentAlerts: urgentAlerts,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    add(LoadDashboard());
  }
}
