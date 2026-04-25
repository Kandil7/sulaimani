import '../../domain/entities/alert_item.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../datasources/local/alerts_local_datasource.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  final AlertsLocalDatasource _datasource;

  AlertsRepositoryImpl(this._datasource);

  @override
  Future<List<AlertItem>> getExpiredProducts() async {
    return await _datasource.getExpiredProducts();
  }

  @override
  Future<List<AlertItem>> getExpiringProducts(int daysThreshold) async {
    return await _datasource.getExpiringProducts(daysThreshold);
  }

  @override
  Future<List<AlertItem>> getLowStockProducts() async {
    return await _datasource.getLowStockProducts();
  }
}
