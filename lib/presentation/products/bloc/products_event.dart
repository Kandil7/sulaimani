import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';
import '../../../domain/entities/product.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductsEvent {}

class AddProduct extends ProductsEvent {
  final ProductModel product;

  const AddProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProduct extends ProductsEvent {
  final ProductModel product;

  const UpdateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProduct extends ProductsEvent {
  final int id;

  const DeleteProduct(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchProducts extends ProductsEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter products by type (medicine / pesticide).
class FilterByType extends ProductsEvent {
  final ProductType? type;

  const FilterByType(this.type);

  @override
  List<Object?> get props => [type];
}

/// Sort products by a given field.
class SortProducts extends ProductsEvent {
  final String field;
  final bool ascending;

  const SortProducts({required this.field, required this.ascending});

  @override
  List<Object?> get props => [field, ascending];
}
