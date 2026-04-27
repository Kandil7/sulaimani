import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/theme/responsive/responsive_layout.dart';
import '../../../domain/repositories/generic_repository.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/customer_model.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';
import '../bloc/pos_state.dart';
import '../widgets/pos_search_bar.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_panel.dart';
import '../widgets/payment_dialog.dart';
import '../widgets/invoice_preview_dialog.dart';
import '../widgets/expiry_warning_dialog.dart';

/// Result of discount dialog
class DiscountDialogResult {
  final double discountAmount;
  final bool isPercentage;

  DiscountDialogResult(
      {required this.discountAmount, required this.isPercentage});
}

/// Dialog for applying discount (fixed amount or percentage)
class _DiscountDialog extends StatefulWidget {
  final double total;

  const _DiscountDialog({required this.total});

  @override
  State<_DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<_DiscountDialog> {
  final _controller = TextEditingController();
  bool _isPercentage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _value => double.tryParse(_controller.text) ?? 0;

  double get _previewDiscount => _isPercentage
      ? (widget.total * _value / 100).clamp(0, widget.total)
      : _value;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة خصم'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإجمالي قبل الخصم: ${CurrencyUtils.format(widget.total)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          // Toggle between fixed and percentage
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isPercentage = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                    decoration: BoxDecoration(
                      color: !_isPercentage
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(AppSizes.radiusSm),
                        bottomRight: Radius.circular(AppSizes.radiusSm),
                      ),
                      border: Border.all(
                        color: !_isPercentage
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      'مبلغ ثابت',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !_isPercentage
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: !_isPercentage
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isPercentage = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                    decoration: BoxDecoration(
                      color:
                          _isPercentage ? AppColors.primary : AppColors.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppSizes.radiusSm),
                        bottomLeft: Radius.circular(AppSizes.radiusSm),
                      ),
                      border: Border.all(
                        color: _isPercentage
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      'نسبة مئوية',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isPercentage
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight:
                            _isPercentage ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: _isPercentage ? 'نسبة الخصم (%)' : 'مبلغ الخصم',
              prefixIcon: const Icon(Icons.discount),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              suffixText: _isPercentage ? '%' : null,
            ),
          ),
          if (_value > 0) ...[
            const SizedBox(height: AppSizes.sm),
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'قيمة الخصم:',
                    style: TextStyle(fontSize: 12, color: AppColors.success),
                  ),
                  Text(
                    CurrencyUtils.format(_previewDiscount),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'الإجمالي بعد الخصم: ${CurrencyUtils.format(widget.total - _previewDiscount)}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _value > 0
              ? () {
                  Navigator.of(context).pop(DiscountDialogResult(
                    discountAmount: _previewDiscount,
                    isPercentage: _isPercentage,
                  ));
                }
              : null,
          child: const Text('تطبيق'),
        ),
      ],
    );
  }
}

class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  final _searchFocusNode = FocusNode();
  List<CustomerModel> _customers = [];
  Map<int, double> _customerDebts = {};

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    try {
      final customerRepo = sl<GenericRepository<CustomerModel>>();
      final customers = await customerRepo.getAll();

      final debts = <int, double>{};
      for (final customer in customers) {
        debts[customer.id] = customer.debtBalance;
      }

      setState(() {
        _customers = customers;
        _customerDebts = debts;
      });
    } catch (e) {
      debugPrint('Error loading customers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PosBloc>()..add(LoadAllProducts()),
      child: _PosView(
        searchFocusNode: _searchFocusNode,
        customers: _customers,
        customerDebts: _customerDebts,
        onCustomerDebtRequest: _loadCustomers,
        onCreateCustomer: (name, phone) async {
          final customerRepo = sl<GenericRepository<CustomerModel>>();
          final newCustomer = CustomerModel()
            ..name = name
            ..phone = phone
            ..debtBalance = 0.0
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();
          await customerRepo.insert(newCustomer);
          _loadCustomers();
        },
      ),
    );
  }
}

class _PosView extends StatefulWidget {
  final FocusNode searchFocusNode;
  final List<CustomerModel> customers;
  final Map<int, double> customerDebts;
  final VoidCallback onCustomerDebtRequest;
  final Function(String name, String phone) onCreateCustomer;

  const _PosView({
    required this.searchFocusNode,
    required this.customers,
    required this.customerDebts,
    required this.onCustomerDebtRequest,
    required this.onCreateCustomer,
  });

  @override
  State<_PosView> createState() => _PosViewState();
}

class _PosViewState extends State<_PosView> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _paymentDialogShown = false;
  bool _expiryDialogShown = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showPaymentDialog(BuildContext context, PosActive state) {
    // Get customer debt if selected
    double? customerDebt;
    if (state.selectedCustomerId != null) {
      customerDebt = widget.customerDebts[state.selectedCustomerId];
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<PosBloc>(),
        child: PaymentDialog(
          totalAmount: state.total,
          discount: state.discount,
          customers: widget.customers,
          selectedCustomerId: state.selectedCustomerId,
          customerDebt: customerDebt,
          onConfirm: (paymentType, paidAmount, customerId, notes) {
            // Close dialog using dialog context
            Navigator.of(dialogContext).pop();
            // Then confirm sale
            context.read<PosBloc>().add(ConfirmSale(
                  paymentType: paymentType,
                  paidAmount: paidAmount,
                  customerId: customerId,
                  notes: notes,
                ));
          },
          onCancel: () {
            Navigator.of(dialogContext).pop();
            context.read<PosBloc>().add(ClosePaymentDialog());
          },
          onCreateCustomer: (name, phone) {
            widget.onCreateCustomer(name, phone);
          },
        ),
      ),
    );
  }

  void _showExpiryWarningDialog(BuildContext context, PosActive state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<PosBloc>(),
        child: ExpiryWarningDialog(
          product: state.pendingExpiryProduct!,
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            context.read<PosBloc>().add(ConfirmExpiryWarning());
          },
          onCancel: () {
            Navigator.of(dialogContext).pop();
            context.read<PosBloc>().add(CloseExpiryWarningDialog());
          },
        ),
      ),
    );
  }

  void _handleSearch(String query) {
    context.read<PosBloc>().add(SearchProductPos(query));
  }

  void _handleAddToCart(ProductModel product) {
    context.read<PosBloc>().add(AddToCart(product));
  }

  void _handleQuantityChange(int index, int quantity) {
    context.read<PosBloc>().add(UpdateCartItemQuantity(index, quantity));
  }

  void _handleRemoveFromCart(int index) {
    context.read<PosBloc>().add(RemoveFromCart(index));
  }

  void _handleClearCart() {
    context.read<PosBloc>().add(ClearCart());
  }

  void _handleOpenPayment() {
    context.read<PosBloc>().add(OpenPaymentDialog());
  }

  void _handleRemoveDiscount() {
    context.read<PosBloc>().add(RemoveDiscount());
  }

  void _handleAddDiscount() async {
    final state = context.read<PosBloc>().state;
    if (state is PosActive) {
      // Show discount dialog and get discount amount from user
      final result = await showDialog<DiscountDialogResult>(
        context: context,
        builder: (context) => _DiscountDialog(total: state.total),
      );
      if (result != null && result.discountAmount > 0) {
        context.read<PosBloc>().add(ApplyDiscount(
              result.discountAmount,
              isPercentage: result.isPercentage,
            ));
      }
    }
  }

  void _quickSale() {
    final state = context.read<PosBloc>().state;
    if (state is PosActive && state.cartItems.isNotEmpty) {
      context.read<PosBloc>().add(ConfirmSale(
            paymentType: 'cash',
            paidAmount: state.finalTotal,
            customerId: null,
            notes: '',
          ));
    }
  }

  /// Build desktop/tablet layout with side-by-side panels
  Widget _buildDesktopLayout(
    BuildContext context,
    PosActive activeState,
    Map<int, int> quantitiesInCart,
    bool isProcessing,
  ) {
    final isTablet = ScreenUtils.isTablet(context);
    // Responsive flex: 4:6 on desktop, 5:5 on tablet
    final flex = ResponsiveFlex.getTwoPanelFlex(
      context,
      desktopSmallFlex: 4,
      desktopLargeFlex: 6,
      tabletSmallFlex: 5,
      tabletLargeFlex: 5,
    );

    return Row(
      children: [
        // Left Panel: Cart
        Expanded(
          flex: flex.$1,
          child: CartPanel(
            cartItems: activeState.cartItems,
            total: activeState.total,
            discount: activeState.discount,
            finalTotal: activeState.finalTotal,
            isDiscountPercentage: activeState.isDiscountPercentage,
            onQuantityChanged: _handleQuantityChange,
            onRemove: _handleRemoveFromCart,
            onClearCart: _handleClearCart,
            onOpenPayment: _handleOpenPayment,
            onRemoveDiscount: _handleRemoveDiscount,
            onAddDiscount: _handleAddDiscount,
            isProcessing: isProcessing,
          ),
        ),

        // Right Panel: Products
        Expanded(
          flex: flex.$2,
          child: Container(
            color: AppColors.background,
            child: Column(
              children: [
                // Search bar
                Container(
                  padding: EdgeInsets.all(isTablet ? AppSizes.sm : AppSizes.md),
                  color: Colors.white,
                  child: PosSearchBar(
                    focusNode: _searchFocusNode,
                    onSearch: _handleSearch,
                    onClear: () => _handleSearch(''),
                  ),
                ),

                // Product grid
                Expanded(
                  child: ProductGrid(
                    products: activeState.searchResults,
                    quantitiesInCart: quantitiesInCart,
                    onProductTap: _handleAddToCart,
                    isLoading: isProcessing,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build mobile layout with stacked panels
  Widget _buildMobileLayout(
    BuildContext context,
    PosActive activeState,
    Map<int, int> quantitiesInCart,
    bool isProcessing,
  ) {
    return Column(
      children: [
        // Top: Products (takes most space on mobile)
        Expanded(
          flex: 3,
          child: Container(
            color: AppColors.background,
            child: Column(
              children: [
                // Search bar
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  color: Colors.white,
                  child: PosSearchBar(
                    focusNode: _searchFocusNode,
                    onSearch: _handleSearch,
                    onClear: () => _handleSearch(''),
                  ),
                ),
                // Product grid
                Expanded(
                  child: ProductGrid(
                    products: activeState.searchResults,
                    quantitiesInCart: quantitiesInCart,
                    onProductTap: _handleAddToCart,
                    isLoading: isProcessing,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom: Cart summary bar - show compact on mobile
        _buildMobileCartBar(activeState),
      ],
    );
  }

  /// Build compact cart bar for mobile view
  Widget _buildMobileCartBar(PosActive activeState) {
    final itemCount =
        activeState.cartItems.fold(0, (sum, item) => sum + item.quantity);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Cart info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$itemCount عناصر',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'الإجمالي: ${CurrencyUtils.format(activeState.finalTotal)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Action buttons
            Row(
              children: [
                if (activeState.cartItems.isNotEmpty) ...[
                  IconButton(
                    onPressed: _handleClearCart,
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.danger,
                    tooltip: 'مسح السلة',
                  ),
                  const SizedBox(width: AppSizes.xs),
                ],
                ElevatedButton(
                  onPressed: activeState.cartItems.isNotEmpty
                      ? _handleOpenPayment
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.lg,
                      vertical: AppSizes.sm,
                    ),
                  ),
                  child: const Text('دفع'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PosBloc, PosState>(
      listener: (context, state) {
        // Handle side effects
        if (state is PosSaleSuccess) {
          // Show invoice preview
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => InvoicePreviewDialog(
              sale: state.sale,
              items: state.items,
              pdfBytes: state.pdfBytes,
              onNewSale: () {
                // Pop the dialog using dialog context
                Navigator.of(dialogContext).pop();
                // Reload products for a new sale
                context.read<PosBloc>().add(LoadAllProducts());
              },
            ),
          );
        } else if (state is PosError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }

        // Handle opening payment dialog
        if (state is PosActive &&
            state.isPaymentDialogOpen &&
            !_paymentDialogShown) {
          _paymentDialogShown = true;
          _showPaymentDialog(context, state);
        } else if (state is PosActive && !state.isPaymentDialogOpen) {
          _paymentDialogShown = false;
        }

        // Handle expiry warning dialog
        if (state is PosActive &&
            state.isExpiryWarningOpen &&
            state.pendingExpiryProduct != null &&
            !_expiryDialogShown) {
          _expiryDialogShown = true;
          _showExpiryWarningDialog(context, state);
        } else if (state is PosActive && !state.isExpiryWarningOpen) {
          _expiryDialogShown = false;
        }
      },
      builder: (context, state) {
        // Get active state
        final activeState = state is PosActive ? state : const PosActive();
        final isProcessing = state is PosProcessing;

        // Build quantities map
        final quantities = <int, int>{};
        for (final item in activeState.cartItems) {
          final productId = item.product.value?.id;
          if (productId != null) {
            quantities[productId] =
                (quantities[productId] ?? 0) + item.quantity;
          }
        }

        // Keyboard shortcuts - use Focus widget to capture keys globally in POS
        return Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.f1) {
                _searchFocusNode.requestFocus();
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.f2) {
                if (activeState.cartItems.isNotEmpty) {
                  _handleOpenPayment();
                  return KeyEventResult.handled;
                }
              } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                if (activeState.isPaymentDialogOpen) {
                  context.read<PosBloc>().add(ClosePaymentDialog());
                  return KeyEventResult.handled;
                } else if (activeState.isExpiryWarningOpen) {
                  context.read<PosBloc>().add(CloseExpiryWarningDialog());
                  return KeyEventResult.handled;
                } else if (activeState.cartItems.isNotEmpty) {
                  _handleClearCart();
                  return KeyEventResult.handled;
                }
              } else if (event.logicalKey == LogicalKeyboardKey.f12) {
                _quickSale();
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: Scaffold(
            body: ScreenUtils.isMobile(context)
                ? _buildMobileLayout(
                    context,
                    activeState,
                    quantities,
                    isProcessing,
                  )
                : _buildDesktopLayout(
                    context,
                    activeState,
                    quantities,
                    isProcessing,
                  ),
          ),
        );
      },
    );
  }
}
