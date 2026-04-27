import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/datasources/local/product_local_datasource.dart';
import '../../../data/datasources/local/customer_local_datasource.dart';
import '../../../data/datasources/local/sale_local_datasource.dart';
import '../../../core/di/injection_container.dart';

enum SearchType { all, products, customers, invoices }

class GlobalSearchDialog extends StatefulWidget {
  const GlobalSearchDialog({super.key});

  @override
  State<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends State<GlobalSearchDialog>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  late TabController _tabController;

  List<ProductSearchResult> _productResults = [];
  List<CustomerSearchResult> _customerResults = [];
  List<InvoiceSearchResult> _invoiceResults = [];
  bool _isSearching = false;
  SearchType _currentType = SearchType.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      switch (_tabController.index) {
        case 0:
          _currentType = SearchType.all;
          break;
        case 1:
          _currentType = SearchType.products;
          break;
        case 2:
          _currentType = SearchType.customers;
          break;
        case 3:
          _currentType = SearchType.invoices;
          break;
      }
    });
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _productResults = [];
        _customerResults = [];
        _invoiceResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final productDatasource = sl<ProductLocalDatasource>();
      final customerDatasource = sl<CustomerLocalDatasource>();
      final saleDatasource = sl<SaleLocalDatasource>();

      final results = await Future.wait([
        _currentType == SearchType.invoices || _currentType == SearchType.all
            ? saleDatasource.getAll()
            : Future.value(<dynamic>[]),
        _currentType == SearchType.customers || _currentType == SearchType.all
            ? customerDatasource.getAll()
            : Future.value(<dynamic>[]),
        _currentType == SearchType.products || _currentType == SearchType.all
            ? productDatasource.getAll()
            : Future.value(<dynamic>[]),
      ]);

      // Search invoices
      if (_currentType == SearchType.invoices ||
          _currentType == SearchType.all) {
        final allSales = results[0] as List<dynamic>;
        _invoiceResults = allSales
            .where((s) {
              final sale = s as dynamic;
              return sale.receiptNumber.toString().contains(query) ||
                  (sale.customerName?.contains(query) ?? false);
            })
            .take(10)
            .map((s) => InvoiceSearchResult(
                  id: (s as dynamic).id,
                  receiptNumber: (s as dynamic).receiptNumber,
                  customerName: (s as dynamic).customerName ?? '-',
                  amount: (s as dynamic).finalAmount,
                  date: (s as dynamic).createdAt,
                ))
            .toList();
      } else {
        _invoiceResults = [];
      }

      // Search customers
      if (_currentType == SearchType.customers ||
          _currentType == SearchType.all) {
        final allCustomers = results[1] as List<dynamic>;
        _customerResults = allCustomers
            .where((c) {
              final customer = c as dynamic;
              return customer.name.contains(query) ||
                  customer.phone.contains(query) ||
                  (customer.address?.contains(query) ?? false);
            })
            .take(10)
            .map((c) => CustomerSearchResult(
                  id: (c as dynamic).id,
                  name: (c as dynamic).name,
                  phone: (c as dynamic).phone,
                  debtBalance: (c as dynamic).debtBalance,
                ))
            .toList();
      } else {
        _customerResults = [];
      }

      // Search products
      if (_currentType == SearchType.products ||
          _currentType == SearchType.all) {
        final allProducts = results[2] as List<dynamic>;
        _productResults = allProducts
            .where((p) {
              final product = p as dynamic;
              return product.name.contains(query) ||
                  (product.barcode?.contains(query) ?? false) ||
                  (product.description?.contains(query) ?? false);
            })
            .take(10)
            .map((p) => ProductSearchResult(
                  id: (p as dynamic).id,
                  name: (p as dynamic).name,
                  barcode: (p as dynamic).barcode,
                  stockQuantity: (p as dynamic).stockQuantity,
                  salePrice: (p as dynamic).sellingPrice,
                ))
            .toList();
      } else {
        _productResults = [];
      }
    } catch (e) {
      debugPrint('Search error: $e');
    }

    setState(() => _isSearching = false);
  }

  void _navigateToProduct(int productId) {
    Navigator.pop(context);
    context.go('/products?preselect=$productId');
  }

  void _navigateToCustomer(int customerId) {
    Navigator.pop(context);
    context.go('/customers?preselect=$customerId');
  }

  void _navigateToInvoice(int invoiceId) {
    Navigator.pop(context);
    context.go('/invoices?preselect=$invoiceId');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSizes.xl),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with search field
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusLg),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white, size: 24),
                      const SizedBox(width: AppSizes.sm),
                      const Text(
                        'بحث شامل',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    onChanged: _performSearch,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن منتج، عميل، أو فاتورة...',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.7)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon:
                                  const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tab bar
            Container(
              color: AppColors.background,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'الكل (${_getTotalCount()})'),
                  const Tab(text: 'منتجات'),
                  const Tab(text: 'عملاء'),
                  const Tab(text: 'فواتير'),
                ],
              ),
            ),
            // Results
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAllResults(),
                        _buildProductResults(),
                        _buildCustomerResults(),
                        _buildInvoiceResults(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  int _getTotalCount() {
    return _productResults.length +
        _customerResults.length +
        _invoiceResults.length;
  }

  Widget _buildAllResults() {
    if (_productResults.isEmpty &&
        _customerResults.isEmpty &&
        _invoiceResults.isEmpty) {
      return _buildEmptyState();
    }
    return ListView(
      padding: const EdgeInsets.all(AppSizes.sm),
      children: [
        if (_productResults.isNotEmpty) ...[
          _buildSectionHeader('منتجات', Icons.inventory_2),
          ..._productResults.take(3).map(_buildProductTile),
          if (_productResults.length > 3)
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: Text('عرض المزيد (${_productResults.length})'),
            ),
        ],
        if (_customerResults.isNotEmpty) ...[
          _buildSectionHeader('عملاء', Icons.people),
          ..._customerResults.take(3).map(_buildCustomerTile),
          if (_customerResults.length > 3)
            TextButton(
              onPressed: () => _tabController.animateTo(2),
              child: Text('عرض المزيد (${_customerResults.length})'),
            ),
        ],
        if (_invoiceResults.isNotEmpty) ...[
          _buildSectionHeader('فواتير', Icons.receipt),
          ..._invoiceResults.take(3).map(_buildInvoiceTile),
          if (_invoiceResults.length > 3)
            TextButton(
              onPressed: () => _tabController.animateTo(3),
              child: Text('عرض المزيد (${_invoiceResults.length})'),
            ),
        ],
      ],
    );
  }

  Widget _buildProductResults() {
    if (_productResults.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.sm),
      itemCount: _productResults.length,
      itemBuilder: (context, index) =>
          _buildProductTile(_productResults[index]),
    );
  }

  Widget _buildCustomerResults() {
    if (_customerResults.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.sm),
      itemCount: _customerResults.length,
      itemBuilder: (context, index) =>
          _buildCustomerTile(_customerResults[index]),
    );
  }

  Widget _buildInvoiceResults() {
    if (_invoiceResults.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.sm),
      itemCount: _invoiceResults.length,
      itemBuilder: (context, index) =>
          _buildInvoiceTile(_invoiceResults[index]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            _searchController.text.isEmpty ? 'ابدأ بالبحث' : 'لا توجد نتائج',
            style: AppTextStyles.bodyL.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSizes.xs),
          Text(title,
              style: AppTextStyles.label.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildProductTile(ProductSearchResult product) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child:
            const Icon(Icons.inventory_2, color: AppColors.primary, size: 20),
      ),
      title: Text(product.name, style: AppTextStyles.bodyL),
      subtitle: Text(
        product.barcode ?? 'بدون باركود',
        style: AppTextStyles.caption,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${product.stockQuantity} قطعة', style: AppTextStyles.bodyM),
          Text('${product.salePrice.toStringAsFixed(0)} ج',
              style: AppTextStyles.caption),
        ],
      ),
      onTap: () => _navigateToProduct(product.id),
    );
  }

  Widget _buildCustomerTile(CustomerSearchResult customer) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.secondary.withOpacity(0.1),
        child: const Icon(Icons.person, color: AppColors.secondary, size: 20),
      ),
      title: Text(customer.name, style: AppTextStyles.bodyL),
      subtitle: Text(customer.phone, style: AppTextStyles.caption),
      trailing: Text(
        '${customer.debtBalance.toStringAsFixed(0)} ج',
        style: TextStyle(
          color:
              customer.debtBalance > 0 ? AppColors.danger : AppColors.success,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () => _navigateToCustomer(customer.id),
    );
  }

  Widget _buildInvoiceTile(InvoiceSearchResult invoice) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.warning.withOpacity(0.1),
        child: const Icon(Icons.receipt, color: AppColors.warning, size: 20),
      ),
      title: Text(invoice.receiptNumber, style: AppTextStyles.bodyL),
      subtitle: Text(invoice.customerName, style: AppTextStyles.caption),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${invoice.amount.toStringAsFixed(0)} ج',
              style: AppTextStyles.bodyM),
          Text(
            '${invoice.date.day}/${invoice.date.month}/${invoice.date.year}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
      onTap: () => _navigateToInvoice(invoice.id),
    );
  }
}

// Search result models
class ProductSearchResult {
  final int id;
  final String name;
  final String? barcode;
  final int stockQuantity;
  final double salePrice;

  ProductSearchResult({
    required this.id,
    required this.name,
    this.barcode,
    required this.stockQuantity,
    required this.salePrice,
  });
}

class CustomerSearchResult {
  final int id;
  final String name;
  final String phone;
  final double debtBalance;

  CustomerSearchResult({
    required this.id,
    required this.name,
    required this.phone,
    required this.debtBalance,
  });
}

class InvoiceSearchResult {
  final int id;
  final String receiptNumber;
  final String customerName;
  final double amount;
  final DateTime date;

  InvoiceSearchResult({
    required this.id,
    required this.receiptNumber,
    required this.customerName,
    required this.amount,
    required this.date,
  });
}
