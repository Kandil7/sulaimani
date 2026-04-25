import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/customers_bloc.dart';
import '../bloc/customers_event.dart';
import '../bloc/customers_state.dart';

class CustomersTable extends StatefulWidget {
  final Function(Customer) onEdit;
  final Function(Customer) onPayment;
  final Function(Customer) onDelete;

  const CustomersTable({
    super.key,
    required this.onEdit,
    required this.onPayment,
    required this.onDelete,
  });

  @override
  State<CustomersTable> createState() => _CustomersTableState();
}

class _CustomersTableState extends State<CustomersTable> {
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomersBloc, CustomersState>(
      builder: (context, state) {
        if (state is CustomersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CustomersLoaded) {
          if (state.filteredCustomers.isEmpty) {
            return _buildEmptyState();
          }

          final totalPages =
              (state.filteredCustomers.length / _pageSize).ceil();
          final startIndex = _currentPage * _pageSize;
          final endIndex =
              (startIndex + _pageSize > state.filteredCustomers.length)
                  ? state.filteredCustomers.length
                  : startIndex + _pageSize;
          final pageCustomers =
              state.filteredCustomers.sublist(startIndex, endIndex);

          return Column(
            children: [
              Expanded(
                child: Container(
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor:
                            WidgetStateProperty.all(AppColors.background),
                        columns: const [
                          DataColumn(
                              label: Text('#', style: AppTextStyles.label)),
                          DataColumn(
                              label: Text('الاسم', style: AppTextStyles.label)),
                          DataColumn(
                              label:
                                  Text('التليفون', style: AppTextStyles.label)),
                          DataColumn(
                              label: Text('الدين', style: AppTextStyles.label)),
                          DataColumn(
                              label: Text('تاريخ التسجيل',
                                  style: AppTextStyles.label)),
                          DataColumn(
                              label:
                                  Text('إجراءات', style: AppTextStyles.label)),
                        ],
                        rows: List.generate(pageCustomers.length, (index) {
                          final customer = pageCustomers[index];
                          final globalIndex = startIndex + index;
                          final isSelected =
                              state.selectedCustomer?.id == customer.id;

                          return DataRow(
                            color: WidgetStateProperty.all(
                              isSelected
                                  ? AppColors.primarySurface
                                  : globalIndex.isEven
                                      ? Colors.transparent
                                      : AppColors.background.withOpacity(0.5),
                            ),
                            onSelectChanged: (_) {
                              context
                                  .read<CustomersBloc>()
                                  .add(SelectCustomer(customer.id));
                            },
                            cells: [
                              DataCell(Text('${globalIndex + 1}')),
                              DataCell(
                                Text(
                                  customer.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  customer.phone,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              DataCell(
                                _buildDebtCell(customer.debtBalance),
                              ),
                              DataCell(
                                Text(
                                  _formatDate(customer.createdAt),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      onPressed: () => widget.onEdit(customer),
                                      tooltip: 'تعديل',
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.payment,
                                        color: customer.hasDebt
                                            ? AppColors.warning
                                            : AppColors.textSecondary,
                                        size: 20,
                                      ),
                                      onPressed: customer.hasDebt
                                          ? () => widget.onPayment(customer)
                                          : null,
                                      tooltip: 'تسجيل دفعة',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: AppColors.danger,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          widget.onDelete(customer),
                                      tooltip: 'حذف',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              _buildPagination(totalPages, state.filteredCustomers.length),
            ],
          );
        }

        if (state is CustomersError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: AppColors.danger),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyState() {
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
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSizes.md),
            const Text(
              'لا توجد عملاء',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'لم يتم إضافة أي عملاء حتى الآن',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtCell(double debt) {
    if (debt > 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber,
            color: AppColors.danger,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${debt.toStringAsFixed(0)} ج',
            style: const TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
    return const Text(
      '0 ج',
      style: TextStyle(color: AppColors.textSecondary),
    );
  }

  Widget _buildPagination(int totalPages, int totalItems) {
    if (totalPages <= 1) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 0
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_right),
          color: AppColors.textSecondary,
        ),
        Text(
          '${_currentPage + 1} / $totalPages',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        IconButton(
          onPressed: _currentPage < totalPages - 1
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_left),
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSizes.md),
        Text(
          '($totalItems عميل)',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
