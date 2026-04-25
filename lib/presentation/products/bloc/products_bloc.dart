import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/generic_repository.dart';
import '../../../data/models/product_model.dart';
import '../../../domain/entities/product.dart';
import 'products_event.dart';
import 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GenericRepository<ProductModel> repository;

  List<ProductModel> _allProducts = [];
  String? _currentSearchQuery;
  ProductType? _currentTypeFilter;
  String? _sortField;
  bool _sortAscending = true;

  ProductsBloc({required this.repository}) : super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<SearchProducts>(_onSearchProducts);
    on<FilterByType>(_onFilterByType);
    on<SortProducts>(_onSortProducts);
  }

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());
    try {
      final products = await repository.getAll();
      _allProducts = products;
      _emitFiltered(emit);
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onAddProduct(
      AddProduct event, Emitter<ProductsState> emit) async {
    try {
      await repository.insert(event.product);
      emit(const ProductOperationSuccess('تم إضافة المنتج بنجاح'));
      add(LoadProducts());
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
      UpdateProduct event, Emitter<ProductsState> emit) async {
    try {
      await repository.update(event.product);
      emit(const ProductOperationSuccess('تم تحديث المنتج بنجاح'));
      add(LoadProducts());
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
      DeleteProduct event, Emitter<ProductsState> emit) async {
    try {
      await repository.delete(event.id);
      emit(const ProductOperationSuccess('تم حذف المنتج بنجاح'));
      add(LoadProducts());
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  void _onSearchProducts(SearchProducts event, Emitter<ProductsState> emit) {
    _currentSearchQuery =
        event.query.isEmpty ? null : event.query.toLowerCase();
    _emitFiltered(emit);
  }

  void _onFilterByType(FilterByType event, Emitter<ProductsState> emit) {
    _currentTypeFilter = event.type;
    _emitFiltered(emit);
  }

  void _onSortProducts(SortProducts event, Emitter<ProductsState> emit) {
    _sortField = event.field;
    _sortAscending = event.ascending;
    _emitFiltered(emit);
  }

  void _emitFiltered(Emitter<ProductsState> emit) {
    var result = List<ProductModel>.from(_allProducts);

    // Apply search filter
    if (_currentSearchQuery != null && _currentSearchQuery!.isNotEmpty) {
      result = result.where((p) {
        return p.name.toLowerCase().contains(_currentSearchQuery!) ||
            p.barcode.toLowerCase().contains(_currentSearchQuery!) ||
            p.scientificName.toLowerCase().contains(_currentSearchQuery!);
      }).toList();
    }

    // Apply type filter
    if (_currentTypeFilter != null) {
      final typeStr =
          _currentTypeFilter == ProductType.medicine ? 'medicine' : 'pesticide';
      result = result.where((p) => p.productType == typeStr).toList();
    }

    // Apply sorting
    if (_sortField != null) {
      result.sort((a, b) {
        int cmp;
        switch (_sortField!) {
          case 'quantity':
            cmp = a.stockQuantity.compareTo(b.stockQuantity);
            break;
          case 'price':
            cmp = a.sellingPrice.compareTo(b.sellingPrice);
            break;
          case 'expiry':
            final aDate = a.expiryDate ?? DateTime(9999);
            final bDate = b.expiryDate ?? DateTime(9999);
            cmp = aDate.compareTo(bDate);
            break;
          case 'name':
            cmp = a.name.compareTo(b.name);
            break;
          default:
            cmp = 0;
        }
        return _sortAscending ? cmp : -cmp;
      });
    }

    emit(ProductsLoaded(result));
  }
}
