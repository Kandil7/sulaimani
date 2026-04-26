import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';

abstract class AlertsState extends Equatable {
  const AlertsState();
  @override
  List<Object?> get props => [];
}

class AlertsInitial extends AlertsState {}

class AlertsLoading extends AlertsState {}

class AlertsLoaded extends AlertsState {
  final List<ProductAlert> expiredProducts;
  final List<ProductAlert> expiringSoonProducts;
  final List<ProductAlert> lowStockProducts;

  const AlertsLoaded({
    required this.expiredProducts,
    required this.expiringSoonProducts,
    required this.lowStockProducts,
  });

  int get totalCount =>
      expiredProducts.length +
      expiringSoonProducts.length +
      lowStockProducts.length;

  @override
  List<Object?> get props =>
      [expiredProducts, expiringSoonProducts, lowStockProducts];
}

class AlertsError extends AlertsState {
  final String message;
  const AlertsError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProductAlert extends Equatable {
  final int productId;
  final String productName;
  final String type;
  final DateTime? expiryDate;
  final int quantity;
  final int minimumStock;
  final ProductModel? product;

  const ProductAlert({
    required this.productId,
    required this.productName,
    required this.type,
    this.expiryDate,
    required this.quantity,
    required this.minimumStock,
    this.product,
  });

  @override
  List<Object?> get props =>
      [productId, productName, type, expiryDate, quantity, minimumStock];
}
