import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/generic_repository.dart';
import '../../../data/models/product_model.dart';
import 'alerts_event.dart';
import 'alerts_state.dart';

class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  final GenericRepository<ProductModel> repository;

  AlertsBloc({required this.repository}) : super(AlertsInitial()) {
    on<LoadAlerts>(_onLoadAlerts);
  }

  Future<void> _onLoadAlerts(
    LoadAlerts event,
    Emitter<AlertsState> emit,
  ) async {
    emit(AlertsLoading());
    try {
      final products = await repository.getAll();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final expired = <ProductAlert>[];
      final expiringSoon = <ProductAlert>[];
      final lowStock = <ProductAlert>[];

      for (final p in products) {
        final expDate = p.expiryDate;
        if (expDate != null) {
          final expiryDay = DateTime(expDate.year, expDate.month, expDate.day);

          if (today.isAfter(expiryDay)) {
            expired.add(ProductAlert(
              productId: p.id,
              productName: p.name,
              type: 'Expired',
              expiryDate: p.expiryDate,
              quantity: p.stockQuantity,
              minimumStock: p.minimumStock,
            ));
          } else if (expiryDay.difference(today).inDays <= 30) {
            expiringSoon.add(ProductAlert(
              productId: p.id,
              productName: p.name,
              type: 'Expiring Soon',
              expiryDate: p.expiryDate,
              quantity: p.stockQuantity,
              minimumStock: p.minimumStock,
            ));
          }
        }

        if (p.stockQuantity <= p.minimumStock) {
          lowStock.add(ProductAlert(
            productId: p.id,
            productName: p.name,
            type: 'Low Stock',
            quantity: p.stockQuantity,
            minimumStock: p.minimumStock,
          ));
        }
      }

      emit(AlertsLoaded(
        expiredProducts: expired,
        expiringSoonProducts: expiringSoon,
        lowStockProducts: lowStock,
      ));
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }
}
