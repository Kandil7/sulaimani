import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/sale_item_model.dart';
import '../../../data/models/sale_model.dart';

abstract class PosState extends Equatable {
  const PosState();

  @override
  List<Object?> get props => [];
}

/// Initial loading state
class PosInitial extends PosState {}

/// Active POS state with cart and products
class PosActive extends PosState {
  final List<SaleItemModel> cartItems;
  final double total;
  final double discount;
  final double finalTotal;
  final List<ProductModel> allProducts;
  final List<ProductModel> searchResults;
  final int? selectedCustomerId;
  final String paymentType;
  final double paidAmount;
  final bool isPaymentDialogOpen;
  final bool isExpiryWarningOpen;
  final ProductModel? pendingExpiryProduct;

  const PosActive({
    this.cartItems = const [],
    this.total = 0.0,
    this.discount = 0.0,
    this.finalTotal = 0.0,
    this.allProducts = const [],
    this.searchResults = const [],
    this.selectedCustomerId,
    this.paymentType = 'cash',
    this.paidAmount = 0.0,
    this.isPaymentDialogOpen = false,
    this.isExpiryWarningOpen = false,
    this.pendingExpiryProduct,
  });

  /// Calculate item count in cart
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// Check if cart is empty
  bool get isEmpty => cartItems.isEmpty;

  /// Get cart quantity for a specific product
  int getQuantityInCart(int productId) {
    final item = cartItems
        .where((item) => item.product.value?.id == productId)
        .firstOrNull;
    return item?.quantity ?? 0;
  }

  PosActive copyWith({
    List<SaleItemModel>? cartItems,
    double? total,
    double? discount,
    double? finalTotal,
    List<ProductModel>? allProducts,
    List<ProductModel>? searchResults,
    int? selectedCustomerId,
    bool clearCustomerId = false,
    String? paymentType,
    double? paidAmount,
    bool? isPaymentDialogOpen,
    bool? isExpiryWarningOpen,
    ProductModel? pendingExpiryProduct,
    bool clearPendingExpiryProduct = false,
  }) {
    return PosActive(
      cartItems: cartItems ?? this.cartItems,
      total: total ?? this.total,
      discount: discount ?? this.discount,
      finalTotal: finalTotal ?? this.finalTotal,
      allProducts: allProducts ?? this.allProducts,
      searchResults: searchResults ?? this.searchResults,
      selectedCustomerId: clearCustomerId
          ? null
          : (selectedCustomerId ?? this.selectedCustomerId),
      paymentType: paymentType ?? this.paymentType,
      paidAmount: paidAmount ?? this.paidAmount,
      isPaymentDialogOpen: isPaymentDialogOpen ?? this.isPaymentDialogOpen,
      isExpiryWarningOpen: isExpiryWarningOpen ?? this.isExpiryWarningOpen,
      pendingExpiryProduct: clearPendingExpiryProduct
          ? null
          : (pendingExpiryProduct ?? this.pendingExpiryProduct),
    );
  }

  @override
  List<Object?> get props => [
        cartItems,
        total,
        discount,
        finalTotal,
        allProducts,
        searchResults,
        selectedCustomerId,
        paymentType,
        paidAmount,
        isPaymentDialogOpen,
        isExpiryWarningOpen,
        pendingExpiryProduct,
      ];
}

/// Processing sale in progress
class PosProcessing extends PosState {}

/// Sale completed successfully
class PosSaleSuccess extends PosState {
  final SaleModel sale;
  final List<SaleItemModel> items;
  final Uint8List pdfBytes;

  const PosSaleSuccess({
    required this.sale,
    required this.items,
    required this.pdfBytes,
  });

  @override
  List<Object?> get props => [sale, items, pdfBytes];
}

/// Error state
class PosError extends PosState {
  final String message;

  const PosError(this.message);

  @override
  List<Object?> get props => [message];
}
