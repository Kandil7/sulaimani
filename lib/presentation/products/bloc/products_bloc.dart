import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/generic_repository.dart';
import '../../../data/models/product_model.dart';
import 'products_event.dart';
import 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GenericRepository<ProductModel> repository;
  
  List<ProductModel> _allProducts = [];

  ProductsBloc({required this.repository}) : super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<SearchProducts>(_onSearchProducts);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());
    try {
      final products = await repository.getAll();
      _allProducts = products;
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onAddProduct(AddProduct event, Emitter<ProductsState> emit) async {
    try {
      await repository.insert(event.product);
      emit(const ProductOperationSuccess('تم إضافة المنتج بنجاح'));
      add(LoadProducts());
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(UpdateProduct event, Emitter<ProductsState> emit) async {
    try {
      await repository.update(event.product);
      emit(const ProductOperationSuccess('تم تحديث المنتج بنجاح'));
      add(LoadProducts());
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(DeleteProduct event, Emitter<ProductsState> emit) async {
    try {
      await repository.delete(event.id);
      emit(const ProductOperationSuccess('تم حذف المنتج بنجاح'));
      add(LoadProducts());
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  void _onSearchProducts(SearchProducts event, Emitter<ProductsState> emit) {
    if (event.query.isEmpty) {
      emit(ProductsLoaded(_allProducts));
      return;
    }
    
    final query = event.query.toLowerCase();
    final filtered = _allProducts.where((p) {
      return p.name.toLowerCase().contains(query) || 
             p.barcode.toLowerCase().contains(query) ||
             p.scientificName.toLowerCase().contains(query);
    }).toList();
    
    emit(ProductsLoaded(filtered));
  }
}
