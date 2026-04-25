import 'package:isar/isar.dart';
import '../../models/product_model.dart';

class ProductLocalDatasource {
  final Isar isar;

  ProductLocalDatasource(this.isar);

  Future<List<ProductModel>> getAll() async {
    return await isar.productModels.where().findAll();
  }

  Future<ProductModel?> getById(int id) async {
    return await isar.productModels.get(id);
  }

  Future<int> insert(ProductModel product) async {
    return await isar.writeTxn(() async {
      return await isar.productModels.put(product);
    });
  }

  Future<void> update(ProductModel product) async {
    await isar.writeTxn(() async {
      await isar.productModels.put(product);
    });
  }

  Future<bool> delete(int id) async {
    return await isar.writeTxn(() async {
      return await isar.productModels.delete(id);
    });
  }

  Future<List<ProductModel>> getExpiringProducts(int daysThreshold) async {
    final now = DateTime.now();
    final threshold = now.add(Duration(days: daysThreshold));
    return await isar.productModels
        .filter()
        .expiryDateIsNotNull()
        .expiryDateLessThan(threshold)
        .expiryDateGreaterThan(now.subtract(const Duration(days: 1)))
        .findAll();
  }

  Future<List<ProductModel>> getExpiredProducts() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return await isar.productModels
        .filter()
        .expiryDateIsNotNull()
        .expiryDateLessThan(today)
        .findAll();
  }

  Future<List<ProductModel>> getLowStockProducts() async {
    final products = await isar.productModels.where().findAll();
    return products.where((p) => p.stockQuantity <= p.minimumStock).toList();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final lowerQuery = query.toLowerCase();
    return await isar.productModels
        .filter()
        .nameContains(lowerQuery, caseSensitive: false)
        .or()
        .barcodeContains(lowerQuery, caseSensitive: false)
        .or()
        .scientificNameContains(lowerQuery, caseSensitive: false)
        .findAll();
  }

  Future<ProductModel?> getByBarcode(String barcode) async {
    return await isar.productModels
        .filter()
        .barcodeEqualTo(barcode)
        .findFirst();
  }

  Future<List<ProductModel>> getByIds(List<int> ids) async {
    return await isar.productModels
        .getAll(ids)
        .then((list) => list.whereType<ProductModel>().toList());
  }
}
