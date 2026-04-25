import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/repositories/generic_repository.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/customer_model.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';
import '../bloc/pos_state.dart';
import '../widgets/pos_search_bar.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_panel.dart';
import '../widgets/invoice_preview_dialog.dart';

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
      ),
    );
  }
}

class _PosView extends StatefulWidget {
  final FocusNode searchFocusNode;
  final List<CustomerModel> customers;
  final Map<int, double> customerDebts;
  final VoidCallback onCustomerDebtRequest;

  const _PosView({
    required this.searchFocusNode,
    required this.customers,
    required this.customerDebts,
    required this.onCustomerDebtRequest,
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

  void _quickSale() {
    final state = context.read<PosBloc>().state;
    if (state is PosActive && state.cartItems.isNotEmpty) {
      context.read<PosBloc>().add(ConfirmSale(
            paymentType: 'cash',
            paidAmount: state.finalTotal,
            customerId: null,
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
