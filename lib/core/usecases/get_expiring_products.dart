import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/product.dart';

class GetExpiringProducts {
  final ProductRepository repository;

  GetExpiringProducts(this.repository);

  Future<List<Product>> call(int daysThreshold) async {
    return await repository.getExpiringProducts(daysThreshold);
  }
}
