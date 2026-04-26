import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/generic_repository.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/models/sale_item_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/datasources/local/sale_local_datasource.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../core/utils/invoice_generator.dart';
import 'pos_event.dart';
import 'pos_state.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final GenericRepository<ProductModel> productRepository;
  final GenericRepository<SaleModel> saleRepository;
  final GenericRepository<SaleItemModel> saleItemRepository;
  final GenericRepository<CustomerModel> customerRepository;
  final SaleLocalDatasource saleDatasource;
  final SettingsRepository settingsRepository;

  PosBloc({
    required this.productRepository,
    required this.saleRepository,
    required this.saleItemRepository,
    required this.customerRepository,
    required this.saleDatasource,
    required this.settingsRepository,
  }) : super(PosInitial()) {
    on<LoadAllProducts>(_onLoadAllProducts);
    on<SearchProductPos>(_onSearchProductPos);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<ClearCart>(_onClearCart);
    on<SelectCustomer>(_onSelectCustomer);
    on<ApplyDiscount>(_onApplyDiscount);
    on<RemoveDiscount>(_onRemoveDiscount);
    on<ConfirmSale>(_onConfirmSale);
    on<OpenPaymentDialog>(_onOpenPaymentDialog);
    on<ClosePaymentDialog>(_onClosePaymentDialog);
    on<OpenExpiryWarningDialog>(_onOpenExpiryWarningDialog);
    on<CloseExpiryWarningDialog>(_onCloseExpiryWarningDialog);
    on<ConfirmExpiryWarning>(_onConfirmExpiryWarning);
  }

  /// Check if product is expired or expiring soon (within 30 days)
  bool _isProductExpiring(ProductModel product) {
    if (product.expiryDate == null) return false;
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    return product.expiryDate!.isBefore(thirtyDaysFromNow);
  }

  /// Check if product is completely expired
  bool _isProductExpired(ProductModel product) {
    if (product.expiryDate == null) return false;
    return product.expiryDate!.isBefore(DateTime.now());
  }

  /// Calculate total from cart items
  double _calculateTotal(List<SaleItemModel> items) {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  /// Generate unique receipt number
  Future<String> _generateReceiptNumber() async {
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    // Count today's sales directly via datasource
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    final todaySales =
        await saleDatasource.getByDateRange(todayStart, todayEnd);

    final sequence = (todaySales.length + 1).toString().padLeft(3, '0');
    return 'INV-$dateStr-$sequence';
  }

  /// Load all products on init
  Future<void> _onLoadAllProducts(
      LoadAllProducts event, Emitter<PosState> emit) async {
    try {
      final products = await productRepository.getAll();
      // Filter only products with stock > 0
      final availableProducts =
          products.where((p) => p.stockQuantity > 0).toList();
      emit(PosActive(
          allProducts: availableProducts, searchResults: availableProducts));
    } catch (e) {
      emit(PosError('فشل في تحميل المنتجات: $e'));
    }
  }

  /// Search products by name or barcode
  void _onSearchProductPos(SearchProductPos event, Emitter<PosState> emit) {
    final currentState =
        state is PosActive ? state as PosActive : const PosActive();

    if (event.query.isEmpty) {
      emit(currentState.copyWith(searchResults: currentState.allProducts));
      return;
    }

    final query = event.query.toLowerCase();
    final filtered = currentState.allProducts.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.barcode.toLowerCase().contains(query);
    }).toList();

    emit(currentState.copyWith(searchResults: filtered));
  }

  /// Add product to cart with validation
  void _onAddToCart(AddToCart event, Emitter<PosState> emit) {
    final currentState =
        state is PosActive ? state as PosActive : const PosActive();

    // Check if product exists
    if (event.product.id == 0) {
      emit(const PosError('المنتج غير موجود'));
      emit(currentState);
      return;
    }

    // Check if stock > 0
    if (event.product.stockQuantity <= 0) {
      emit(const PosError('المنتج نفد من المخزن'));
      emit(currentState);
      return;
    }

    // Check expiry warning (unless skipped)
    if (!event.skipExpiryWarning) {
      if (_isProductExpired(event.product) ||
          _isProductExpiring(event.product)) {
        emit(currentState.copyWith(
          isExpiryWarningOpen: true,
          pendingExpiryProduct: event.product,
        ));
        return;
      }
    }

    // Check if already in cart
    final existingIndex = currentState.cartItems
        .indexWhere((item) => item.product.value?.id == event.product.id);

    final updatedCart = List<SaleItemModel>.from(currentState.cartItems);

    if (existingIndex >= 0) {
      // Check stock availability
      final existingQty = updatedCart[existingIndex].quantity;
      final newQty = existingQty + 1;

      if (newQty > event.product.stockQuantity) {
        emit(const PosError('الكمية المطلوبة تتجاوز المخزون المتاح'));
        emit(currentState);
        return;
      }

      updatedCart[existingIndex].quantity = newQty;
      updatedCart[existingIndex].total =
          newQty * updatedCart[existingIndex].unitPrice;
    } else {
      final newItem = SaleItemModel()
        ..product.value = event.product
        ..quantity = 1
        ..unitPrice = event.product.sellingPrice
        ..total = event.product.sellingPrice;
      updatedCart.add(newItem);
    }

    final total = _calculateTotal(updatedCart);
    final discount = currentState.discount;
    final finalTotal = (total - discount).clamp(0.0, double.infinity);

    emit(currentState.copyWith(
      cartItems: updatedCart,
      total: total,
      finalTotal: finalTotal,
      searchResults: currentState.searchResults,
    ));
  }

  /// Remove item from cart
  void _onRemoveFromCart(RemoveFromCart event, Emitter<PosState> emit) {
    if (state is PosActive) {
      final currentState = state as PosActive;
      final updatedCart = List<SaleItemModel>.from(currentState.cartItems);

      if (event.index >= 0 && event.index < updatedCart.length) {
        updatedCart.removeAt(event.index);
      }

      final total = _calculateTotal(updatedCart);
      final discount = currentState.discount;
      final finalTotal = (total - discount).clamp(0.0, double.infinity);

      emit(currentState.copyWith(
        cartItems: updatedCart,
        total: total,
        finalTotal: finalTotal,
      ));
    }
  }

  /// Update cart item quantity
  void _onUpdateCartItemQuantity(
      UpdateCartItemQuantity event, Emitter<PosState> emit) {
    if (state is PosActive) {
      final currentState = state as PosActive;

      if (event.index >= 0 && event.index < currentState.cartItems.length) {
        final item = currentState.cartItems[event.index];
        final product = item.product.value;

        // Validate stock
        if (product != null && event.quantity > product.stockQuantity) {
          emit(const PosError('الكمية المطلوبة تتجاوز المخزون المتاح'));
          emit(currentState);
          return;
        }

        if (event.quantity <= 0) {
          // Remove item if quantity is 0
          final updatedCart = List<SaleItemModel>.from(currentState.cartItems);
          updatedCart.removeAt(event.index);

          final total = _calculateTotal(updatedCart);
          final discount = currentState.discount;
          final finalTotal = (total - discount).clamp(0.0, double.infinity);

          emit(currentState.copyWith(
            cartItems: updatedCart,
            total: total,
            finalTotal: finalTotal,
          ));
          return;
        }

        final updatedCart = List<SaleItemModel>.from(currentState.cartItems);
        updatedCart[event.index].quantity = event.quantity;
        updatedCart[event.index].total =
            event.quantity * updatedCart[event.index].unitPrice;

        final total = _calculateTotal(updatedCart);
        final discount = currentState.discount;
        final finalTotal = (total - discount).clamp(0.0, double.infinity);

        emit(currentState.copyWith(
          cartItems: updatedCart,
          total: total,
          finalTotal: finalTotal,
        ));
      }
    }
  }

  /// Clear cart and reset state
  void _onClearCart(ClearCart event, Emitter<PosState> emit) {
    final currentState =
        state is PosActive ? state as PosActive : const PosActive();
    emit(currentState.copyWith(
      cartItems: [],
      total: 0.0,
      discount: 0.0,
      finalTotal: 0.0,
      clearCustomerId: true,
      paymentType: 'cash',
      paidAmount: 0.0,
    ));
  }

  /// Select customer for credit sale
  void _onSelectCustomer(SelectCustomer event, Emitter<PosState> emit) {
    final currentState =
        state is PosActive ? state as PosActive : const PosActive();
    emit(currentState.copyWith(
      selectedCustomerId: event.customerId,
      paymentType: event.customerId != null ? 'credit' : 'cash',
    ));
  }

  /// Apply discount to cart
  void _onApplyDiscount(ApplyDiscount event, Emitter<PosState> emit) {
    final currentState =
        state is PosActive ? state as PosActive : const PosActive();

    if (event.discountAmount < 0) {
      emit(const PosError('الخصم لا يمكن أن يكون سالباً'));
      emit(currentState);
      return;
    }

    if (event.discountAmount > currentState.total) {
      emit(const PosError('الخصم لا يمكن أن يتجاوز الإجمالي'));
      emit(currentState);
      return;
    }

    final finalTotal = currentState.total - event.discountAmount;

    emit(currentState.copyWith(
      discount: event.discountAmount,
      finalTotal: finalTotal,
    ));
  }

  /// Remove discount
  void _onRemoveDiscount(RemoveDiscount event, Emitter<PosState> emit) {
    final currentState =
        state is PosActive ? state as PosActive : const PosActive();

    emit(currentState.copyWith(
      discount: 0.0,
      finalTotal: currentState.total,
    ));
  }

  /// Open payment dialog
  void _onOpenPaymentDialog(OpenPaymentDialog event, Emitter<PosState> emit) {
    final currentState =
        state is PosActive ? state as PosActive : const PosActive();
    emit(currentState.copyWith(
      isPaymentDialogOpen: true,
      paidAmount: currentState.finalTotal,
    ));
  }

  /// Close payment dialog
  void _onClosePaymentDialog(ClosePaymentDialog event, Emitter<PosState> emit) {
    final currentState =
        state is PosActive ? state as PosActive : const PosActive();
    emit(currentState.copyWith(isPaymentDialogOpen: false));
  }

  /// Open expiry warning dialog
  void _onOpenExpiryWarningDialog(
      OpenExpiryWarningDialog event, Emitter<PosState> emit) {
    final currentState =
        state is PosActive ? state as PosActive : const PosActive();
    emit(currentState.copyWith(
      isExpiryWarningOpen: true,
      pendingExpiryProduct: event.product,
    ));
  }

  /// Close expiry warning dialog
  void _onCloseExpiryWarningDialog(
      CloseExpiryWarningDialog event, Emitter<PosState> emit) {
    final currentState =
        state is PosActive ? state as PosActive : const PosActive();
    emit(currentState.copyWith(
      isExpiryWarningOpen: false,
      clearPendingExpiryProduct: true,
    ));
  }

  /// Confirm adding product despite expiry warning
  void _onConfirmExpiryWarning(
      ConfirmExpiryWarning event, Emitter<PosState> emit) {
    final currentState =
        state is PosActive ? state as PosActive : const PosActive();

    if (currentState.pendingExpiryProduct != null) {
      // Add product with skip warning flag
      final product = currentState.pendingExpiryProduct!;

      // Log expiry warning confirmation for audit trail (US-04 AC3)
      final isExpired = _isProductExpired(product);
      final expiryInfo = product.expiryDate != null
          ? 'expires ${product.expiryDate!.toIso8601String()}'
          : 'no expiry date';
      debugPrint(
          '[EXPIRY_WARNING_CONFIRMED] Product: ${product.name} (ID: ${product.id}, Barcode: ${product.barcode}, $expiryInfo) - User proceeded with sale despite ${isExpired ? "EXPIRED" : "EXPIRING_SOON"} warning at ${DateTime.now().toIso8601String()}');

      final existingIndex = currentState.cartItems
          .indexWhere((item) => item.product.value?.id == product.id);

      final updatedCart = List<SaleItemModel>.from(currentState.cartItems);

      if (existingIndex >= 0) {
        final existingQty = updatedCart[existingIndex].quantity;
        final newQty = existingQty + 1;

        if (newQty > product.stockQuantity) {
          emit(const PosError('الكمية المطلوبة تتجاوز المخزون المتاح'));
          emit(currentState.copyWith(
            isExpiryWarningOpen: false,
            clearPendingExpiryProduct: true,
          ));
          return;
        }

        updatedCart[existingIndex].quantity = newQty;
        updatedCart[existingIndex].total =
            newQty * updatedCart[existingIndex].unitPrice;
      } else {
        final newItem = SaleItemModel()
          ..product.value = product
          ..quantity = 1
          ..unitPrice = product.sellingPrice
          ..total = product.sellingPrice;
        updatedCart.add(newItem);
      }

      final total = _calculateTotal(updatedCart);
      final discount = currentState.discount;
      final finalTotal = (total - discount).clamp(0.0, double.infinity);

      emit(currentState.copyWith(
        cartItems: updatedCart,
        total: total,
        finalTotal: finalTotal,
        isExpiryWarningOpen: false,
        clearPendingExpiryProduct: true,
      ));
    }
  }

  /// Confirm sale with payment processing
  Future<void> _onConfirmSale(ConfirmSale event, Emitter<PosState> emit) async {
    final currentState =
        state is PosActive ? state as PosActive : const PosActive();

    if (currentState.cartItems.isEmpty) {
      emit(const PosError('السلة فارغة'));
      emit(currentState);
      return;
    }

    // Validate cash payment
    if (event.paymentType == 'cash' &&
        event.paidAmount < currentState.finalTotal) {
      emit(const PosError('المبلغ المدفوع أقل من الإجمالي'));
      emit(currentState);
      return;
    }

    // Validate credit has customer
    if (event.paymentType == 'credit' && event.customerId == null) {
      emit(const PosError('يرجى اختيار عميل للبيع بالأجل'));
      emit(currentState);
      return;
    }

    emit(PosProcessing());

    try {
      // Generate receipt number
      final receiptNumber = await _generateReceiptNumber();

      // Get customer info for credit sales (needed before creating sale)
      String? customerName;
      String? customerPhone;
      if (event.paymentType == 'credit' && event.customerId != null) {
        final customer = await customerRepository.getById(event.customerId!);
        if (customer != null) {
          customerName = customer.name;
          customerPhone = customer.phone;
        }
      }

      // Create sale model
      final change = event.paidAmount - currentState.finalTotal;
      final sale = SaleModel()
        ..receiptNumber = receiptNumber
        ..date = DateTime.now()
        ..totalAmount = currentState.total
        ..discount = currentState.discount
        ..finalAmount = currentState.finalTotal
        ..paymentMethod = event.paymentType
        ..paidAmount = event.paidAmount
        ..remainingAmount = event.paymentType == 'credit'
            ? currentState.finalTotal
            : (change < 0 ? currentState.finalTotal - event.paidAmount : 0)
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..customerId = event.paymentType == 'credit' ? event.customerId : null
        ..customerName = customerName;

      // Create sale items
      final saleItems = <SaleItemModel>[];
      for (final cartItem in currentState.cartItems) {
        final saleItem = SaleItemModel()
          ..product.value = cartItem.product.value
          ..quantity = cartItem.quantity
          ..unitPrice = cartItem.unitPrice
          ..total = cartItem.total;
        saleItems.add(saleItem);
      }

      // Use atomic transaction from datasource (does sale insert + item linking + stock decrement)
      final saleId = await saleDatasource.createSaleWithItems(
        saleItems: saleItems,
        sale: sale,
        customerId: event.paymentType == 'credit' ? event.customerId : null,
      );

      // Get the created sale with updated ID
      final createdSale = await saleDatasource.getById(saleId);
      if (createdSale == null) {
        emit(const PosError('فشل في إنشاء الفاتورة'));
        emit(currentState);
        return;
      }

      // Fetch shop settings for invoice customization
      final shopSettings = await settingsRepository.getSettings();

      final pdfBytes = await InvoiceGenerator.generatePdfBytes(
        sale: createdSale,
        items: saleItems,
        customerName: customerName,
        customerPhone: customerPhone,
        shopName: shopSettings.pharmacyName,
        shopAddress: shopSettings.pharmacyAddress,
        shopPhone: shopSettings.pharmacyPhone,
        header: shopSettings.invoiceHeader,
        footer: shopSettings.invoiceFooter,
      );

      emit(PosSaleSuccess(
        sale: createdSale,
        items: saleItems,
        pdfBytes:
            pdfBytes is Uint8List ? pdfBytes : Uint8List.fromList(pdfBytes),
      ));

      // Reset to fresh state
      emit(PosActive(
          allProducts: currentState.allProducts,
          searchResults: currentState.allProducts));
    } catch (e) {
      emit(PosError('فشل في إتمام البيع: $e'));
      emit(currentState);
    }
  }
}
