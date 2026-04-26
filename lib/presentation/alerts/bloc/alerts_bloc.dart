import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/generic_repository.dart';
import '../../../data/models/product_model.dart';
import 'alerts_event.dart';
import 'alerts_state.dart';

class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  final GenericRepository<ProductModel> repository;

  AlertsBloc({required this.repository}) : super(AlertsInitial()) {
    on<LoadAlerts>(_onLoadAlerts);
    on<DismissAlert>(_onDismissAlert);
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
      final processedProductIds = <int>{};

      for (final p in products) {
        final expDate = p.expiryDate;
        final isExpired = expDate != null &&
            today.isAfter(DateTime(expDate.year, expDate.month, expDate.day));
        final isExpiringSoon = expDate != null &&
            !isExpired &&
            DateTime(expDate.year, expDate.month, expDate.day)
                    .difference(today)
                    .inDays <=
                30;
        final isLowStock = p.stockQuantity <= p.minimumStock;

        // Priority: expired > expiring > low stock
        // A product can only appear in ONE category (deduplication)
        if (isExpired) {
          // Deduplication: if product is expired, don't also show as low stock
          if (!processedProductIds.contains(p.id)) {
            expired.add(ProductAlert(
              productId: p.id,
              productName: p.name,
              type: 'Expired',
              expiryDate: p.expiryDate,
              quantity: p.stockQuantity,
              minimumStock: p.minimumStock,
            ));
            processedProductIds.add(p.id);
          }
        } else if (isExpiringSoon) {
          if (!processedProductIds.contains(p.id)) {
            expiringSoon.add(ProductAlert(
              productId: p.id,
              productName: p.name,
              type: 'Expiring Soon',
              expiryDate: p.expiryDate,
              quantity: p.stockQuantity,
              minimumStock: p.minimumStock,
            ));
            processedProductIds.add(p.id);
          }
        } else if (isLowStock) {
          if (!processedProductIds.contains(p.id)) {
            lowStock.add(ProductAlert(
              productId: p.id,
              productName: p.name,
              type: 'Low Stock',
              quantity: p.stockQuantity,
              minimumStock: p.minimumStock,
            ));
            processedProductIds.add(p.id);
          }
        }
      }

      // Sort by nearest expiry first (most urgent first)
      expired.sort((a, b) => (a.expiryDate ?? DateTime.now())
          .compareTo(b.expiryDate ?? DateTime.now()));
      expiringSoon.sort((a, b) => (a.expiryDate ?? DateTime.now())
          .compareTo(b.expiryDate ?? DateTime.now()));

      emit(AlertsLoaded(
        expiredProducts: expired,
        expiringSoonProducts: expiringSoon,
        lowStockProducts: lowStock,
      ));
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }

  void _onDismissAlert(DismissAlert event, Emitter<AlertsState> emit) {
    if (state is AlertsLoaded) {
      final currentState = state as AlertsLoaded;
      switch (event.alertType) {
        case 'Expired':
          final updatedExpired = currentState.expiredProducts
              .where((a) => a.productId != event.productId)
              .toList();
          emit(AlertsLoaded(
            expiredProducts: updatedExpired,
            expiringSoonProducts: currentState.expiringSoonProducts,
            lowStockProducts: currentState.lowStockProducts,
          ));
          break;
        case 'Expiring Soon':
          final updatedExpiring = currentState.expiringSoonProducts
              .where((a) => a.productId != event.productId)
              .toList();
          emit(AlertsLoaded(
            expiredProducts: currentState.expiredProducts,
            expiringSoonProducts: updatedExpiring,
            lowStockProducts: currentState.lowStockProducts,
          ));
          break;
        case 'Low Stock':
          final updatedLowStock = currentState.lowStockProducts
              .where((a) => a.productId != event.productId)
              .toList();
          emit(AlertsLoaded(
            expiredProducts: currentState.expiredProducts,
            expiringSoonProducts: currentState.expiringSoonProducts,
            lowStockProducts: updatedLowStock,
          ));
          break;
      }
    }
  }
}
