import 'package:isar/isar.dart';
import '../../models/product_model.dart';
import '../../../domain/entities/alert_item.dart';

class AlertsLocalDatasource {
  final Isar isar;

  AlertsLocalDatasource(this.isar);

  Future<List<AlertItem>> getExpiredProducts() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final products = await isar
        .collection<ProductModel>()
        .filter()
        .expiryDateIsNotNull()
        .expiryDateLessThan(today)
        .findAll();

    return products
        .map((p) => AlertItem(
              productId: p.id,
              productName: p.name,
              type: AlertType.expired,
              message:
                  'Product expired on ${p.expiryDate?.day}/${p.expiryDate?.month}/${p.expiryDate?.year}',
              createdAt: DateTime.now(),
            ))
        .toList();
  }

  Future<List<AlertItem>> getExpiringProducts(int daysThreshold) async {
    final now = DateTime.now();
    final threshold = now.add(Duration(days: daysThreshold));

    final products = await isar
        .collection<ProductModel>()
        .filter()
        .expiryDateIsNotNull()
        .expiryDateGreaterThan(now.subtract(const Duration(days: 1)))
        .expiryDateLessThan(threshold)
        .findAll();

    return products
        .map((p) => AlertItem(
              productId: p.id,
              productName: p.name,
              type: AlertType.expiringSoon,
              message:
                  'Expires on ${p.expiryDate?.day}/${p.expiryDate?.month}/${p.expiryDate?.year}',
              createdAt: DateTime.now(),
            ))
        .toList();
  }

  Future<List<AlertItem>> getLowStockProducts() async {
    final products = await isar.collection<ProductModel>().where().findAll();

    final lowStock =
        products.where((p) => p.stockQuantity <= p.minimumStock).toList();

    return lowStock
        .map((p) => AlertItem(
              productId: p.id,
              productName: p.name,
              type: AlertType.lowStock,
              message:
                  'Current stock: ${p.stockQuantity}, Minimum: ${p.minimumStock}',
              createdAt: DateTime.now(),
            ))
        .toList();
  }
}
