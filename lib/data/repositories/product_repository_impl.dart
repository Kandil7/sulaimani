import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local/product_local_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDatasource _datasource;

  ProductRepositoryImpl(this._datasource);

  Product _mapModelToEntity(ProductModel model) {
    return Product(
      id: model.id,
      barcode: model.barcode,
      name: model.name,
      scientificName: model.scientificName,
      description: model.description,
      purchasePrice: model.purchasePrice,
      sellingPrice: model.sellingPrice,
      stockQuantity: model.stockQuantity,
      minimumStock: model.minimumStock,
      expiryDate: model.expiryDate,
      type: ProductType.medicine,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  @override
  Future<List<Product>> getAll() async {
    final models = await _datasource.getAll();
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<Product?> getById(int id) async {
    final model = await _datasource.getById(id);
    return model != null ? _mapModelToEntity(model) : null;
  }

  @override
  Future<int> insert(Product product) async {
    final model = ProductModel()
      ..barcode = product.barcode
      ..name = product.name
      ..scientificName = product.scientificName ?? ''
      ..description = product.description
      ..purchasePrice = product.purchasePrice
      ..sellingPrice = product.sellingPrice
      ..stockQuantity = product.stockQuantity
      ..minimumStock = product.minimumStock
      ..expiryDate = product.expiryDate
      ..createdAt = product.createdAt
      ..updatedAt = product.updatedAt ?? DateTime.now();
    return await _datasource.insert(model);
  }

  @override
  Future<void> update(Product product) async {
    final model = ProductModel()
      ..id = product.id ?? 0
      ..barcode = product.barcode
      ..name = product.name
      ..scientificName = product.scientificName ?? ''
      ..description = product.description
      ..purchasePrice = product.purchasePrice
      ..sellingPrice = product.sellingPrice
      ..stockQuantity = product.stockQuantity
      ..minimumStock = product.minimumStock
      ..expiryDate = product.expiryDate
      ..createdAt = product.createdAt
      ..updatedAt = DateTime.now();
    await _datasource.update(model);
  }

  @override
  Future<bool> delete(int id) async {
    return await _datasource.delete(id);
  }

  @override
  Future<List<Product>> getExpiringProducts(int daysThreshold) async {
    final models = await _datasource.getExpiringProducts(daysThreshold);
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<List<Product>> getExpiredProducts() async {
    final models = await _datasource.getExpiredProducts();
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<List<Product>> getLowStockProducts() async {
    final models = await _datasource.getLowStockProducts();
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final models = await _datasource.searchProducts(query);
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<Product?> getByBarcode(String barcode) async {
    final model = await _datasource.getByBarcode(barcode);
    return model != null ? _mapModelToEntity(model) : null;
  }
}
