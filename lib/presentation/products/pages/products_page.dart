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

  static const int _itemsPerPage = 20;

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
            // Page Title
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

            // Toolbar
            ProductsToolbar(
              searchQuery: _searchQuery,
              selectedFilter: _selectedFilter,
              onSearch: _onSearch,
              onFilterChanged: _onFilterChanged,
              onAddPressed: _showAddDialog,
              onExportPressed: _exportProducts,
            ),
            const SizedBox(height: AppSizes.lg),

            // Main Content
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
    // Apply filters
    var filteredProducts = _applyFilters(products);

    // Pagination
    final totalPages = (filteredProducts.length / _itemsPerPage).ceil();
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex =
        (startIndex + _itemsPerPage).clamp(0, filteredProducts.length);
    final pageProducts = filteredProducts.isEmpty
        ? <ProductModel>[]
        : filteredProducts.sublist(startIndex, endIndex);

    // Reset page if out of bounds
    if (pageProducts.isEmpty && _currentPage > 0) {
      _currentPage = 0;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Products Table
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
          ),
        ),
        const SizedBox(width: AppSizes.md),

        // Detail Panel
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

  List<ProductModel> _applyFilters(List<ProductModel> products) {
    var result = products;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.barcode.toLowerCase().contains(query) ||
            p.scientificName.toLowerCase().contains(query);
      }).toList();
    }

    // Apply type filter
    // Note: ProductModel doesn't have type field, so we would need to add it
    // For now, we just return the search filtered results

    return result;
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 0;
    });
    context.read<ProductsBloc>().add(SearchProducts(query));
  }

  void _onFilterChanged(ProductType? type) {
    setState(() {
      _selectedFilter = type;
      _currentPage = 0;
    });
    // Note: Would need to add filter event to ProductsBloc
  }

  void _onProductSelected(ProductModel product) {
    setState(() {
      _selectedProduct = _selectedProduct?.id == product.id ? null : product;
    });
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductsBloc>(),
        child: AddEditProductDialog(
          onSave: (product) {
            context.read<ProductsBloc>().add(AddProduct(product));
          },
        ),
      ),
    );
  }

  void _showEditDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductsBloc>(),
        child: AddEditProductDialog(
          product: product,
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
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تصدير المنتجات...'),
      ),
    );
  }
}
