import '../entities/product.dart';
import 'generic_repository.dart';

abstract class ProductRepository extends GenericRepository<Product> {
  Future<List<Product>> getExpiringProducts(int daysThreshold);
  Future<List<Product>> getExpiredProducts();
  Future<List<Product>> getLowStockProducts();
  Future<List<Product>> searchProducts(String query);
  Future<Product?> getByBarcode(String barcode);
}
