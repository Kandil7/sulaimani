import '../../domain/repositories/product_repository.dart';

class GetProductStats {
  final ProductRepository repository;

  GetProductStats(this.repository);

  Future<Map<String, dynamic>> call() async {
    final allProducts = await repository.getAll();
    final lowStockProducts = await repository.getLowStockProducts();
    final expiringProducts = await repository.getExpiringProducts(30);
    final expiredProducts = await repository.getExpiredProducts();

    final totalStockValue = allProducts.fold<double>(
      0,
      (sum, product) => sum + (product.stockQuantity * product.sellingPrice),
    );

    return {
      'totalProducts': allProducts.length,
      'lowStockCount': lowStockProducts.length,
      'expiringCount': expiringProducts.length,
      'expiredCount': expiredProducts.length,
      'totalStockValue': totalStockValue,
    };
  }
}
