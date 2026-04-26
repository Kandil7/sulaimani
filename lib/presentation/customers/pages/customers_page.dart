import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
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

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CustomersBloc>()..add(LoadCustomers()),
      child: const CustomersView(),
    );
  }
}

class CustomersView extends StatelessWidget {
  const CustomersView({super.key});

  @override
  Widget build(BuildContext context) {
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
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('إدارة العملاء', style: AppTextStyles.h1),
                ElevatedButton.icon(
                  onPressed: () => _showAddCustomerDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة عميل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.lg,
                      vertical: AppSizes.md,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            const CustomersToolbar(),
            const SizedBox(height: AppSizes.lg),
            Expanded(
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<CustomersBloc, CustomersState>(
      builder: (context, state) {
        if (state is CustomersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CustomersLoaded) {
          if (state.customers.isEmpty) {
            return _buildEmptyState(context);
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    DebtStatisticsCard(customers: state.customers),
                    const SizedBox(height: AppSizes.lg),
                    Expanded(
                      child: CustomersTable(
                        onEdit: (customer) =>
                            _showEditCustomerDialog(context, customer),
                        onPayment: (customer) =>
                            _showRecordPaymentDialog(context, customer),
                        onDelete: (customer) =>
                            _showDeleteConfirmation(context, customer),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.lg),
              Expanded(
                flex: 1,
                child: CustomerDetailPanel(
                  onRecordPayment: () {
                    final selectedCustomer = state.selectedCustomer;
                    if (selectedCustomer != null) {
                      _showRecordPaymentDialog(context, selectedCustomer);
                    }
                  },
                  onEdit: (customer) =>
                      _showEditCustomerDialog(context, customer),
                  onDelete: (customer) =>
                      _showDeleteConfirmation(context, customer),
                  onInvoiceTap: (sale) => _showInvoiceDetails(context, sale),
                ),
              ),
            ],
          );
        }

        if (state is CustomersError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.danger,
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  state.message,
                  style: const TextStyle(color: AppColors.danger),
                ),
                const SizedBox(height: AppSizes.lg),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<CustomersBloc>().add(LoadCustomers());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSizes.lg),
            const Text(
              'لا توجد عملاء',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'لم يتم إضافة أي عملاء حتى الآن',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.xl),
            ElevatedButton.icon(
              onPressed: () => _showAddCustomerDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة أول عميل'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CustomersBloc>(),
        child: const AddCustomerDialog(),
      ),
    );
  }

  void _showEditCustomerDialog(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CustomersBloc>(),
        child: EditCustomerDialog(customer: customer),
      ),
    );
  }

  void _showRecordPaymentDialog(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CustomersBloc>(),
        child: RecordPaymentDialog(customer: customer),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'حذف العميل',
        message: 'هل أنت متأكد من حذف "${customer.name}"؟',
        confirmLabel: 'حذف',
        isDanger: true,
        onConfirm: () {
          context.read<CustomersBloc>().add(DeleteCustomer(customer.id));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showInvoiceDetails(BuildContext context, SaleModel sale) async {
    final items = await sl<SaleLocalDatasource>().getSaleItems(sale.id);
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => InvoiceDetailsDialog(sale: sale, items: items),
    );
  }
}
