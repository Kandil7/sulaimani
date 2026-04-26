import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../../data/models/product_model.dart';
import '../../../domain/entities/product.dart';
import '../../products/bloc/products_bloc.dart';
import '../../products/bloc/products_event.dart';
import '../../products/bloc/products_state.dart';
import '../../products/widgets/add_edit_product_dialog.dart';
import '../../products/widgets/product_detail_panel.dart';
import '../../products/widgets/products_table.dart';
import '../../products/widgets/products_toolbar.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductsBloc>()..add(LoadProducts()),
      child: const ProductsView(),
    );
  }
}

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  String _searchQuery = '';
  ProductType? _selectedFilter;
  int _currentPage = 0;
  ProductModel? _selectedProduct;
  String? _sortField;
  bool _sortAscending = true;

  Timer? _debounceTimer;
  static const int _itemsPerPage = 20;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductsBloc, ProductsState>(
      listener: (context, state) {
        if (state is ProductOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          setState(() {
            _selectedProduct = null;
          });
        } else if (state is ProductsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.products,
                  style: AppTextStyles.h1,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            ProductsToolbar(
              searchQuery: _searchQuery,
              selectedFilter: _selectedFilter,
              onSearch: _onSearch,
              onFilterChanged: _onFilterChanged,
              onAddPressed: _showAddDialog,
              onExportPressed: _exportProducts,
            ),
            const SizedBox(height: AppSizes.lg),
            Expanded(
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  if (state is ProductsLoading) {
                    return _buildLoadingState();
                  } else if (state is ProductsLoaded) {
                    return _buildLoadedState(state.products);
                  } else if (state is ProductsError) {
                    return ErrorState(
                      message: state.message,
                      onRetry: () =>
                          context.read<ProductsBloc>().add(LoadProducts()),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const LoadingSkeleton(
          height: 50,
          width: double.infinity,
        ),
        const SizedBox(height: AppSizes.md),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Column(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.md),
                  child: LoadingSkeleton(
                    height: 48,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedState(List<ProductModel> products) {
    var filteredProducts = _applyLocalFilters(products);

    final totalPages = (filteredProducts.length / _itemsPerPage).ceil();
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex =
        (startIndex + _itemsPerPage).clamp(0, filteredProducts.length);
    final pageProducts = filteredProducts.isEmpty
        ? <ProductModel>[]
        : filteredProducts.sublist(startIndex, endIndex);

    if (pageProducts.isEmpty && _currentPage > 0) {
      _currentPage = 0;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: ProductsTable(
            products: pageProducts,
            currentPage: _currentPage,
            totalPages: totalPages > 0 ? totalPages : 1,
            selectedProduct: _selectedProduct,
            onProductSelected: _onProductSelected,
            onEditProduct: _showEditDialog,
            onDeleteProduct: _onDeleteProduct,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
            },
            sortColumn: _sortField,
            sortAscending: _sortAscending,
            onSort: _onSort,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        ProductDetailPanel(
          product: _selectedProduct,
          onClose: () {
            setState(() => _selectedProduct = null);
          },
          onEdit: () {
            if (_selectedProduct != null) {
              _showEditDialog(_selectedProduct!);
            }
          },
          onDelete: () {
            if (_selectedProduct != null) {
              _onDeleteProduct(_selectedProduct!);
            }
          },
        ),
      ],
    );
  }

  List<ProductModel> _applyLocalFilters(List<ProductModel> products) {
    return products;
  }

  void _onSearch(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query;
        _currentPage = 0;
      });
      context.read<ProductsBloc>().add(SearchProducts(query));
    });
  }

  void _onFilterChanged(ProductType? type) {
    setState(() {
      _selectedFilter = type;
      _currentPage = 0;
    });
    context.read<ProductsBloc>().add(FilterByType(type));
  }

  void _onSort(String field) {
    setState(() {
      if (_sortField == field) {
        _sortAscending = !_sortAscending;
      } else {
        _sortField = field;
        _sortAscending = true;
      }
    });
    context.read<ProductsBloc>().add(SortProducts(
          field: field,
          ascending: _sortAscending,
        ));
  }

  void _onProductSelected(ProductModel product) {
    setState(() {
      _selectedProduct = _selectedProduct?.id == product.id ? null : product;
    });
  }

  void _showAddDialog() {
    final state = context.read<ProductsBloc>().state;
    final products =
        state is ProductsLoaded ? state.products : <ProductModel>[];
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductsBloc>(),
        child: AddEditProductDialog(
          existingProducts: products,
          onSave: (product) {
            context.read<ProductsBloc>().add(AddProduct(product));
          },
        ),
      ),
    );
  }

  void _showEditDialog(ProductModel product) {
    final state = context.read<ProductsBloc>().state;
    final products =
        state is ProductsLoaded ? state.products : <ProductModel>[];
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductsBloc>(),
        child: AddEditProductDialog(
          product: product,
          existingProducts: products,
          onSave: (updatedProduct) {
            context.read<ProductsBloc>().add(UpdateProduct(updatedProduct));
            if (_selectedProduct?.id == updatedProduct.id) {
              setState(() => _selectedProduct = updatedProduct);
            }
          },
        ),
      ),
    );
  }

  Future<void> _onDeleteProduct(ProductModel product) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'حذف المنتج',
      message: 'هل أنت متأكد من حذف "${product.name}"؟',
      confirmLabel: 'حذف',
      isDanger: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<ProductsBloc>().add(DeleteProduct(product.id));
      if (_selectedProduct?.id == product.id) {
        setState(() => _selectedProduct = null);
      }
    }
  }

  void _exportProducts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تصدير المنتجات...'),
      ),
    );
  }
}
