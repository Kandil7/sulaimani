import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';

abstract class PosEvent extends Equatable {
  const PosEvent();

  @override
  List<Object?> get props => [];
}

/// Load all products for search grid on init
class LoadAllProducts extends PosEvent {}

/// Search products in the grid
class SearchProductPos extends PosEvent {
  final String query;

  const SearchProductPos(this.query);

  @override
  List<Object?> get props => [query];
}

/// Add product to cart
class AddToCart extends PosEvent {
  final ProductModel product;
  final bool skipExpiryWarning;

  const AddToCart(this.product, {this.skipExpiryWarning = false});

  @override
  List<Object?> get props => [product, skipExpiryWarning];
}

/// Remove item from cart
class RemoveFromCart extends PosEvent {
  final int index;

  const RemoveFromCart(this.index);

  @override
  List<Object?> get props => [index];
}

/// Update quantity of cart item
class UpdateCartItemQuantity extends PosEvent {
  final int index;
  final int quantity;

  const UpdateCartItemQuantity(this.index, this.quantity);

  @override
  List<Object?> get props => [index, quantity];
}

/// Clear the entire cart
class ClearCart extends PosEvent {}

/// Select customer for credit sale
class SelectCustomer extends PosEvent {
  final int? customerId;

  const SelectCustomer(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

/// Apply fixed discount to cart
class ApplyDiscount extends PosEvent {
  final double discountAmount;

  const ApplyDiscount(this.discountAmount);

  @override
  List<Object?> get props => [discountAmount];
}

/// Remove applied discount
class RemoveDiscount extends PosEvent {}

/// Confirm sale with payment details
class ConfirmSale extends PosEvent {
  final String paymentType; // 'cash' or 'credit'
  final double paidAmount;
  final int? customerId;
  final String? notes;

  const ConfirmSale({
    required this.paymentType,
    required this.paidAmount,
    this.customerId,
    this.notes,
  });

  @override
  List<Object?> get props => [paymentType, paidAmount, customerId, notes];
}

/// Open payment dialog
class OpenPaymentDialog extends PosEvent {}

/// Close payment dialog
class ClosePaymentDialog extends PosEvent {}

/// Open expiry warning dialog and set pending product
class OpenExpiryWarningDialog extends PosEvent {
  final ProductModel product;

  const OpenExpiryWarningDialog(this.product);

  @override
  List<Object?> get props => [product];
}

/// Close expiry warning dialog
class CloseExpiryWarningDialog extends PosEvent {}

/// Confirm adding product despite expiry warning
class ConfirmExpiryWarning extends PosEvent {}
