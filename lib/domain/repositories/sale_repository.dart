import '../entities/sale.dart';
import '../entities/cart_item.dart';
import 'generic_repository.dart';

abstract class SaleRepository extends GenericRepository<Sale> {
  Future<Sale> createSale({
    required List<CartItem> items,
    required double totalAmount,
    required double discount,
    required double finalAmount,
    required String paymentType,
    int? customerId,
    double? paidAmount,
  });
  Future<List<Sale>> getByDateRange(DateTime from, DateTime to);
  Future<Sale?> getById(int id);
  Future<List<Sale>> getAll();
  Future<bool> delete(int id);
}
