import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';

abstract class PosEvent extends Equatable {
  const PosEvent();

  @override
  List<Object?> get props => [];
}

class SearchProductPos extends PosEvent {
  final String query;

  const SearchProductPos(this.query);

  @override
  List<Object?> get props => [query];
}

class AddToCart extends PosEvent {
  final ProductModel product;

  const AddToCart(this.product);

  @override
  List<Object?> get props => [product];
}

class RemoveFromCart extends PosEvent {
  final int index;

  const RemoveFromCart(this.index);

  @override
  List<Object?> get props => [index];
}

class UpdateCartItemQuantity extends PosEvent {
  final int index;
  final int quantity;

  const UpdateCartItemQuantity(this.index, this.quantity);

  @override
  List<Object?> get props => [index, quantity];
}

class ProcessSale extends PosEvent {}
class ClearCart extends PosEvent {}
