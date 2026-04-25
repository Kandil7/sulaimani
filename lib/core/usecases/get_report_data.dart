import '../../domain/repositories/sale_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/customer_repository.dart';

class GetReportData {
  final SaleRepository saleRepository;
  final ProductRepository productRepository;
  final CustomerRepository customerRepository;

  GetReportData({
    required this.saleRepository,
    required this.productRepository,
    required this.customerRepository,
  });

  Future<Map<String, dynamic>> call(DateTime from, DateTime to) async {
    final sales = await saleRepository.getByDateRange(from, to);
    final products = await productRepository.getAll();
    final customers = await customerRepository.getAll();

    final totalSales = sales.length;
    final totalRevenue = sales.fold<double>(
      0,
      (sum, sale) => sum + sale.totalAmount,
    );

    final totalProductsCount = products.length;
    final totalCustomersCount = customers.length;

    final totalStockValue = products.fold<double>(
      0,
      (sum, product) => sum + (product.stockQuantity * product.sellingPrice),
    );

    final totalDebt = customers.fold<double>(
      0,
      (sum, customer) => sum + customer.debtBalance,
    );

    // Group sales by payment type
    final cashSales = sales.where((s) => s.paymentType.name == 'cash').length;
    final creditSales =
        sales.where((s) => s.paymentType.name == 'credit').length;

    return {
      'totalSales': totalSales,
      'totalRevenue': totalRevenue,
      'totalProductsCount': totalProductsCount,
      'totalCustomersCount': totalCustomersCount,
      'totalStockValue': totalStockValue,
      'totalDebt': totalDebt,
      'cashSales': cashSales,
      'creditSales': creditSales,
      'fromDate': from,
      'toDate': to,
    };
  }
}
