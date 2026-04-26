import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
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
    return BlocBuilder<CustomersBloc, CustomersState>(
      builder: (context, state) {
        if (state is! CustomersLoaded || state.selectedCustomer == null) {
          return Container(
            width: 320,
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
            child: const Center(
              child: Text(
                'اختر عميلاً لعرض التفاصيل',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        final customer = state.selectedCustomer!;

        return Container(
          width: 320,
          padding: const EdgeInsets.all(AppSizes.md),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('تفاصيل العميل', style: AppTextStyles.h3),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      context
                          .read<CustomersBloc>()
                          .add(const SelectCustomer(null));
                    },
                    icon: const Icon(Icons.close, size: 20),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                customer.name,
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                customer.phone,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSizes.lg),
              _buildDebtCard(customer),
              const SizedBox(height: AppSizes.lg),
              _buildInfoSection(customer),
              const SizedBox(height: AppSizes.lg),
              const Text('سجل المشتريات', style: AppTextStyles.h3),
              const SizedBox(height: AppSizes.sm),
              Expanded(
                child: CustomerPaymentHistory(
                  customerId: customer.id,
                  onInvoiceTap: onInvoiceTap,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              _buildQuickActions(context, customer),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebtCard(CustomerModel customer) {
    if (customer.hasDebt) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.dangerSurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.danger.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.warning_amber,
              color: AppColors.danger,
              size: 32,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              '${customer.debtBalance.toStringAsFixed(0)} ج',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            const Text(
              'للأسف هذا العميل لديه دين',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.successSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 32,
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            '0 ج',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          const Text(
            'لا يوجد دين على هذا العميل',
            style: TextStyle(
              color: AppColors.success,
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
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSizes.sm),
              const Text('تاريخ التسجيل:', style: AppTextStyles.bodyM),
              const Spacer(),
              Text(
                _formatDate(customer.createdAt),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, CustomerModel customer) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: customer.hasDebt ? onRecordPayment : null,
            icon: const Icon(Icons.payment),
            label: const Text('تسجيل دفعة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => onEdit(customer),
            icon: const Icon(Icons.edit),
            label: const Text('تعديل'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => onDelete(customer),
            icon: const Icon(Icons.delete),
            label: const Text('حذف'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
