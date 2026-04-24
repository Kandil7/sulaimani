import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/sale_item_model.dart';

abstract class PosState extends Equatable {
  const PosState();

  @override
  List<Object?> get props => [];
}

class PosInitial extends PosState {}

class PosActive extends PosState {
  final List<SaleItemModel> cartItems;
  final double total;
  final List<ProductModel> searchResults;

  const PosActive({
    this.cartItems = const [],
    this.total = 0.0,
    this.searchResults = const [],
  });

  PosActive copyWith({
    List<SaleItemModel>? cartItems,
    double? total,
    List<ProductModel>? searchResults,
  }) {
    return PosActive(
      cartItems: cartItems ?? this.cartItems,
      total: total ?? this.total,
      searchResults: searchResults ?? this.searchResults,
    );
  }

  @override
  List<Object?> get props => [cartItems, total, searchResults];
}

class PosSaleCompleted extends PosState {
  final String receiptNumber;

  const PosSaleCompleted(this.receiptNumber);

  @override
  List<Object?> get props => [receiptNumber];
}

class PosError extends PosState {
  final String message;

  const PosError(this.message);

  @override
  List<Object?> get props => [message];
}
