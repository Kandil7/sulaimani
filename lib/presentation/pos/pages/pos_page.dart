import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/currency_utils.dart';
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

/// Dialog for applying discount
class _DiscountDialog extends StatefulWidget {
  final double total;

  const _DiscountDialog({required this.total});

  @override
  State<_DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<_DiscountDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة خصم'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الحد الأقصى: ${CurrencyUtils.format(widget.total)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'مبلغ الخصم',
              prefixIcon: const Icon(Icons.discount),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final discount = double.tryParse(_controller.text) ?? 0;
            if (discount > 0 && discount <= widget.total) {
              Navigator.of(context).pop(discount);
            }
          },
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
      builder: (_) => BlocProvider.value(
        value: context.read<PosBloc>(),
        child: PaymentDialog(
          totalAmount: state.total,
          discount: state.discount,
          customers: widget.customers,
          selectedCustomerId: state.selectedCustomerId,
          customerDebt: customerDebt,
          onConfirm: (paymentType, paidAmount, customerId, notes) {
            // Close dialog first
            Navigator.of(context).pop();
            // Then confirm sale
            context.read<PosBloc>().add(ConfirmSale(
                  paymentType: paymentType,
                  paidAmount: paidAmount,
                  customerId: customerId,
                  notes: notes,
                ));
          },
          onCancel: () {
            Navigator.of(context).pop();
            context.read<PosBloc>().add(ClosePaymentDialog());
          },
          onCreateCustomer: (name, phone) {
            widget.onCreateCustomer(name, phone);
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
      final discount = await showDialog<double>(
        context: context,
        builder: (context) => _DiscountDialog(total: state.total),
      );
      if (discount != null && discount > 0) {
        context.read<PosBloc>().add(ApplyDiscount(discount));
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
            builder: (_) => InvoicePreviewDialog(
              sale: state.sale,
              items: state.items,
              pdfBytes: state.pdfBytes,
              onNewSale: () {
                Navigator.of(context).pop();
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
        if (state is PosActive && state.isPaymentDialogOpen) {
          _showPaymentDialog(context, state);
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

        // Keyboard shortcuts
        return KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.f1) {
                _searchFocusNode.requestFocus();
              } else if (event.logicalKey == LogicalKeyboardKey.f2) {
                if (activeState.cartItems.isNotEmpty) {
                  _handleOpenPayment();
                }
              } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                if (activeState.isPaymentDialogOpen) {
                  context.read<PosBloc>().add(ClosePaymentDialog());
                } else if (activeState.isExpiryWarningOpen) {
                  context.read<PosBloc>().add(CloseExpiryWarningDialog());
                } else if (activeState.cartItems.isNotEmpty) {
                  _handleClearCart();
                }
              } else if (event.logicalKey == LogicalKeyboardKey.f12) {
                _quickSale();
              }
            }
          },
          child: Scaffold(
            body: Row(
              children: [
                // Left Panel: Cart (40%)
                Expanded(
                  flex: 4,
                  child: CartPanel(
                    cartItems: activeState.cartItems,
                    total: activeState.total,
                    discount: activeState.discount,
                    finalTotal: activeState.finalTotal,
                    onQuantityChanged: _handleQuantityChange,
                    onRemove: _handleRemoveFromCart,
                    onClearCart: _handleClearCart,
                    onOpenPayment: _handleOpenPayment,
                    onRemoveDiscount: _handleRemoveDiscount,
                    onAddDiscount: _handleAddDiscount,
                    isProcessing: isProcessing,
                  ),
                ),

                // Right Panel: Products (60%)
                Expanded(
                  flex: 6,
                  child: Container(
                    color: AppColors.background,
                    child: Column(
                      children: [
                        // Search bar
                        Container(
                          padding: const EdgeInsets.all(AppSizes.md),
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
                            quantitiesInCart: quantities,
                            onProductTap: _handleAddToCart,
                            isLoading: state is PosInitial,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
