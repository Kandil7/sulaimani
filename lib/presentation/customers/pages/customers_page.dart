import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/responsive/responsive_layout.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/toast_notification.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/datasources/local/sale_local_datasource.dart';
import '../bloc/customers_bloc.dart';
import '../bloc/customers_event.dart';
import '../bloc/customers_state.dart';
import '../widgets/customers_toolbar.dart';
import '../widgets/customers_table.dart';
import '../widgets/customer_detail_panel.dart';
import '../widgets/add_customer_dialog.dart';
import '../widgets/record_payment_dialog.dart';
import '../widgets/edit_customer_dialog.dart';
import '../widgets/debt_statistics_card.dart';
import '../widgets/invoice_details_dialog.dart';

class CustomersPage extends StatefulWidget {
  final int? preselectedCustomerId;

  const CustomersPage({super.key, this.preselectedCustomerId});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<CustomersBloc>()..add(LoadCustomers());
        // If preselected customer ID is provided, select it after loading
        if (widget.preselectedCustomerId != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            bloc.add(SelectCustomer(widget.preselectedCustomerId));
          });
        }
        return bloc;
      },
      child: const CustomersView(),
    );
  }
}

class CustomersView extends StatelessWidget {
  const CustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ScreenUtils.isMobile(context);
    final isTablet = ScreenUtils.isTablet(context);

    return BlocListener<CustomersBloc, CustomersState>(
      listener: (context, state) {
        if (state is CustomerOperationSuccess) {
          ToastNotification.show(
            context,
            message: state.message,
            type: ToastType.success,
          );
        } else if (state is CustomersError) {
          ToastNotification.show(
            context,
            message: state.message,
            type: ToastType.error,
          );
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          isMobile ? AppSizes.md : AppSizes.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and add button
            _buildHeader(context, isMobile),
            SizedBox(height: isMobile ? AppSizes.md : AppSizes.lg),
            const CustomersToolbar(),
            SizedBox(height: isMobile ? AppSizes.md : AppSizes.lg),
            _buildContent(context, isMobile, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إدارة العملاء',
              style: isMobile ? AppTextStyles.h2 : AppTextStyles.h1,
            ),
            const SizedBox(height: AppSizes.xs),
            BlocBuilder<CustomersBloc, CustomersState>(
              builder: (context, state) {
                if (state is CustomersLoaded) {
                  return Text(
                    '${state.customers.length} عميل',
                    style: AppTextStyles.bodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddCustomerDialog(context),
          icon: const Icon(Icons.person_add, size: 18),
          label: Text(isMobile ? '' : 'إضافة عميل'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? AppSizes.md : AppSizes.lg,
              vertical: AppSizes.md,
            ),
            minimumSize: isMobile ? const Size(48, 48) : Size.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, bool isMobile, bool isTablet) {
    return BlocBuilder<CustomersBloc, CustomersState>(
      builder: (context, state) {
        if (state is CustomersLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        if (state is CustomersLoaded) {
          if (state.customers.isEmpty) {
            return _buildEmptyState(context);
          }

          // Mobile/Tablet: Stack layout without detail panel
          if (isMobile || isTablet) {
            return _buildMobileLayout(context, state);
          }

          // Desktop: Side-by-side layout
          return _buildDesktopLayout(context, state);
        }

        if (state is CustomersError) {
          return _buildErrorState(context, state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context, CustomersLoaded state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main content area
        Expanded(
          flex: 3,
          child: Column(
            children: [
              DebtStatisticsCard(customers: state.customers),
              const SizedBox(height: AppSizes.lg),
              _AnimatedContainer(
                child: SizedBox(
                  height: 400, // Fixed height for table on desktop
                  child: CustomersTable(
                    onEdit: (customer) =>
                        _showEditCustomerDialog(context, customer),
                    onPayment: (customer) =>
                        _showRecordPaymentDialog(context, customer),
                    onDelete: (customer) =>
                        _showDeleteConfirmation(context, customer),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.lg),
        // Detail panel
        Expanded(
          flex: 1,
          child: _AnimatedContainer(
            child: CustomerDetailPanel(
              onRecordPayment: () {
                final selectedCustomer = state.selectedCustomer;
                if (selectedCustomer != null) {
                  _showRecordPaymentDialog(context, selectedCustomer);
                }
              },
              onEdit: (customer) => _showEditCustomerDialog(context, customer),
              onDelete: (customer) =>
                  _showDeleteConfirmation(context, customer),
              onInvoiceTap: (sale) => _showInvoiceDetails(context, sale),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, CustomersLoaded state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          DebtStatisticsCard(customers: state.customers),
          const SizedBox(height: AppSizes.lg),
          CustomersTable(
            onEdit: (customer) => _showEditCustomerDialog(context, customer),
            onPayment: (customer) =>
                _showRecordPaymentDialog(context, customer),
            onDelete: (customer) => _showDeleteConfirmation(context, customer),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.xl),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          const Text(
            'حدث خطأ',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            message,
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xl),
          ElevatedButton.icon(
            onPressed: () {
              context.read<CustomersBloc>().add(LoadCustomers());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(AppSizes.xl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              const Text(
                'لا توجد عملاء',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'لم يتم إضافة أي عملاء حتى الآن\nقم بإضافة أول عميل للبدء',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.xl),
              ElevatedButton.icon(
                onPressed: () => _showAddCustomerDialog(context),
                icon: const Icon(Icons.person_add),
                label: const Text('إضافة أول عميل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xl,
                    vertical: AppSizes.md,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CustomersBloc>(),
        child: const AddCustomerDialog(),
      ),
    );
  }

  void _showEditCustomerDialog(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CustomersBloc>(),
        child: EditCustomerDialog(customer: customer),
      ),
    );
  }

  void _showRecordPaymentDialog(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CustomersBloc>(),
        child: RecordPaymentDialog(customer: customer),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: 'حذف العميل',
        message:
            'هل أنت متأكد من حذف "${customer.name}"؟\nسيتم حذف جميع بيانات العميل نهائياً.',
        confirmLabel: 'حذف',
        isDanger: true,
        onConfirm: () {
          context.read<CustomersBloc>().add(DeleteCustomer(customer.id));
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  void _showInvoiceDetails(BuildContext context, SaleModel sale) async {
    final items = await sl<SaleLocalDatasource>().getSaleItems(sale.id);
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) =>
          InvoiceDetailsDialog(sale: sale, items: items),
    );
  }
}

// Animated container for smooth transitions
class _AnimatedContainer extends StatefulWidget {
  final Widget child;

  const _AnimatedContainer({required this.child});

  @override
  State<_AnimatedContainer> createState() => _AnimatedContainerState();
}

class _AnimatedContainerState extends State<_AnimatedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}
