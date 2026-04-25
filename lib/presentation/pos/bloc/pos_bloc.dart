import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/generic_repository.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/models/sale_item_model.dart';
import 'pos_event.dart';
import 'pos_state.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final GenericRepository<ProductModel> productRepository;
  final GenericRepository<SaleModel> saleRepository;

  PosBloc({required this.productRepository, required this.saleRepository})
      : super(PosInitial()) {
    on<SearchProductPos>(_onSearchProductPos);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<ProcessSale>(_onProcessSale);
    on<ClearCart>(_onClearCart);
  }

  Future<void> _onSearchProductPos(
      SearchProductPos event, Emitter<PosState> emit) async {
    final currentState =
        state is PosActive ? state as PosActive : const PosActive();
    if (event.query.isEmpty) {
      emit(currentState.copyWith(searchResults: []));
      return;
    }

    try {
      final allProducts = await productRepository.getAll();
      final query = event.query.toLowerCase();
      final searchResults = allProducts.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.barcode.toLowerCase().contains(query);
      }).toList();

      emit(currentState.copyWith(searchResults: searchResults));
    } catch (e) {
      emit(PosError(e.toString()));
    }
  }

  void _onAddToCart(AddToCart event, Emitter<PosState> emit) {
    final currentState =
        state is PosActive ? state as PosActive : const PosActive();

    // Check if already in cart
    final existingIndex = currentState.cartItems
        .indexWhere((item) => item.product.value?.id == event.product.id);

    final updatedCart = List<SaleItemModel>.from(currentState.cartItems);

    if (existingIndex >= 0) {
      updatedCart[existingIndex].quantity += 1;
      updatedCart[existingIndex].total = updatedCart[existingIndex].quantity *
          updatedCart[existingIndex].unitPrice;
    } else {
      final newItem = SaleItemModel()
        ..product.value = event.product
        ..quantity = 1
        ..unitPrice = event.product.sellingPrice
        ..total = event.product.sellingPrice;
      updatedCart.add(newItem);
    }

    final total = updatedCart.fold(0.0, (sum, item) => sum + item.total);
    emit(currentState.copyWith(cartItems: updatedCart, total: total));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<PosState> emit) {
    if (state is PosActive) {
      final currentState = state as PosActive;
      final updatedCart = List<SaleItemModel>.from(currentState.cartItems);
      updatedCart.removeAt(event.index);
      final total = updatedCart.fold(0.0, (sum, item) => sum + item.total);
      emit(currentState.copyWith(cartItems: updatedCart, total: total));
    }
  }

  void _onUpdateCartItemQuantity(
      UpdateCartItemQuantity event, Emitter<PosState> emit) {
    if (state is PosActive) {
      final currentState = state as PosActive;
      final updatedCart = List<SaleItemModel>.from(currentState.cartItems);
      updatedCart[event.index].quantity = event.quantity;
      updatedCart[event.index].total =
          event.quantity * updatedCart[event.index].unitPrice;
      final total = updatedCart.fold(0.0, (sum, item) => sum + item.total);
      emit(currentState.copyWith(cartItems: updatedCart, total: total));
    }
  }

  Future<void> _onProcessSale(ProcessSale event, Emitter<PosState> emit) async {
    if (state is PosActive) {
      final currentState = state as PosActive;
      if (currentState.cartItems.isEmpty) return;

      try {
        final receiptNo = 'REC-${DateTime.now().millisecondsSinceEpoch}';
        final sale = SaleModel()
          ..receiptNumber = receiptNo
          ..date = DateTime.now()
          ..totalAmount = currentState.total
          ..discount = 0
          ..finalAmount = currentState.total
          ..paymentMethod = 'cash'
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        await saleRepository.insert(sale);

        emit(PosSaleCompleted(receiptNo));
        emit(const PosActive());
      } catch (e) {
        emit(PosError(e.toString()));
      }
    }
  }

  void _onClearCart(ClearCart event, Emitter<PosState> emit) {
    emit(const PosActive());
  }
}
