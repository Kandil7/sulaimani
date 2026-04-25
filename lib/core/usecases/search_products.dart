import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/product.dart';

class SearchProducts {
  final ProductRepository repository;

  SearchProducts(this.repository);

  Future<List<Product>> call(String query) async {
    if (query.isEmpty) {
      return await repository.getAll();
    }
    return await repository.searchProducts(query);
  }
}
