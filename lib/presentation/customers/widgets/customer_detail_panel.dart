import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/responsive/responsive_layout.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/models/customer_model.dart';
import '../bloc/customers_bloc.dart';
import '../bloc/customers_event.dart';
import '../bloc/customers_state.dart';
import 'customer_payment_history.dart';

class CustomerDetailPanel extends StatelessWidget {
  final VoidCallback onRecordPayment;
  final Function(CustomerModel) onEdit;
  final Function(CustomerModel) onDelete;
  final Function(SaleModel)? onInvoiceTap;

  const CustomerDetailPanel({
    super.key,
    required this.onRecordPayment,
    required this.onEdit,
    required this.onDelete,
    this.onInvoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ScreenUtils.isMobile(context);

    return BlocBuilder<CustomersBloc, CustomersState>(
      builder: (context, state) {
        if (state is! CustomersLoaded || state.selectedCustomer == null) {
          return _buildEmptyState(isMobile);
        }

        final customer = state.selectedCustomer!;
        return _buildCustomerDetails(context, customer, isMobile);
      },
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 320,
      constraints: const BoxConstraints(minHeight: 400),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          const Text(
            'اختر عميلاً',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'اختر عميلاً من الجدول لعرض التفاصيل',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails(
      BuildContext context, CustomerModel customer, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 320,
      constraints: const BoxConstraints(minHeight: 400),
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
        children: [
          // Header with close button
          _buildHeader(context, isMobile),
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer name and phone
                  _buildCustomerInfo(customer),
                  const SizedBox(height: AppSizes.lg),
                  // Debt card
                  _buildDebtCard(customer),
                  const SizedBox(height: AppSizes.lg),
                  // Info section
                  _buildInfoSection(customer),
                  const SizedBox(height: AppSizes.lg),
                  // Payment history
                  const Text('سجل المشتريات', style: AppTextStyles.h3),
                  const SizedBox(height: AppSizes.sm),
                  SizedBox(
                    height: 200,
                    child: CustomerPaymentHistory(
                      customerId: customer.id,
                      onInvoiceTap: onInvoiceTap,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  // Quick actions
                  _buildQuickActions(context, customer),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? AppSizes.sm : AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(AppSizes.radiusLg),
          topLeft: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSizes.sm),
          const Flexible(
            child: Text('تفاصيل العميل',
                style: AppTextStyles.h3, overflow: TextOverflow.ellipsis),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              context.read<CustomersBloc>().add(const SelectCustomer(null));
            },
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(CustomerModel customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary,
              child: Text(
                customer.name.isNotEmpty ? customer.name[0] : 'ع',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: AppTextStyles.h2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          customer.phone,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (customer.address != null &&
                      customer.address!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            customer.address!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDebtCard(CustomerModel customer) {
    final hasDebt = customer.hasDebt;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: hasDebt ? AppColors.dangerSurface : AppColors.successSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: hasDebt
              ? AppColors.danger.withOpacity(0.3)
              : AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            hasDebt ? Icons.warning_amber : Icons.check_circle,
            color: hasDebt ? AppColors.danger : AppColors.success,
            size: 32,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            hasDebt ? '${customer.debtBalance.toStringAsFixed(0)} ج' : '0 ج',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: hasDebt ? AppColors.danger : AppColors.success,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            hasDebt ? 'مديونية مستحقة' : 'لا يوجد دين',
            style: TextStyle(
              color: hasDebt ? AppColors.danger : AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(CustomerModel customer) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.shopping_cart,
            label: 'إجمالي المشتريات',
            value: '${customer.totalPurchases} عملية',
          ),
          const SizedBox(height: AppSizes.sm),
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'تاريخ التسجيل',
            value: _formatDate(customer.createdAt),
          ),
          const SizedBox(height: AppSizes.sm),
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'آخر معاملة',
            value: customer.updatedAt != null
                ? _formatDate(customer.updatedAt!)
                : '-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSizes.sm),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.bodyM,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, CustomerModel customer) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: customer.hasDebt ? onRecordPayment : null,
            icon: const Icon(Icons.payment, size: 18),
            label: const Text('تسجيل دفعة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onEdit(customer),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('تعديل'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onDelete(customer),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('حذف'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
