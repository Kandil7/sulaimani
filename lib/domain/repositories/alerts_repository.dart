import '../entities/alert_item.dart';

abstract class AlertsRepository {
  Future<List<AlertItem>> getExpiredProducts();
  Future<List<AlertItem>> getExpiringProducts(int daysThreshold);
  Future<List<AlertItem>> getLowStockProducts();
}
