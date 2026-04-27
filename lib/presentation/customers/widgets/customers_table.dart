import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/responsive/responsive_layout.dart';
import '../../../data/models/customer_model.dart';
import '../bloc/customers_bloc.dart';
import '../bloc/customers_event.dart';
import '../bloc/customers_state.dart';

class CustomersTable extends StatefulWidget {
  final Function(CustomerModel) onEdit;
  final Function(CustomerModel) onPayment;
  final Function(CustomerModel) onDelete;

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
  static const int _pageSize = 15;

  @override
  Widget build(BuildContext context) {
    final isMobile = ScreenUtils.isMobile(context);
    final isTablet = ScreenUtils.isTablet(context);

    return BlocBuilder<CustomersBloc, CustomersState>(
      builder: (context, state) {
        if (state is CustomersLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
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

          // Mobile/Tablet: Card list view
          if (isMobile || isTablet) {
            return _buildCardList(
                context, state, pageCustomers, startIndex, totalPages);
          }

          // Desktop: Table view
          return _buildTableView(
              context, state, pageCustomers, startIndex, totalPages);
        }

        if (state is CustomersError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.danger),
                const SizedBox(height: AppSizes.md),
                Text(
                  state.message,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTableView(BuildContext context, CustomersLoaded state,
      List<CustomerModel> pageCustomers, int startIndex, int totalPages) {
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
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 56,
                  columnSpacing: 24,
                  horizontalMargin: 16,
                  columns: const [
                    DataColumn(label: Text('#', style: AppTextStyles.label)),
                    DataColumn(
                        label: Text('الاسم', style: AppTextStyles.label)),
                    DataColumn(
                        label: Text('التليفون', style: AppTextStyles.label)),
                    DataColumn(
                        label: Text('الدين', style: AppTextStyles.label)),
                    DataColumn(
                        label:
                            Text('تاريخ التسجيل', style: AppTextStyles.label)),
                    DataColumn(
                        label: Text('إجراءات', style: AppTextStyles.label)),
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
                        DataCell(_buildCustomerNameCell(customer)),
                        DataCell(Text(customer.phone)),
                        DataCell(_buildDebtCell(customer.debtBalance)),
                        DataCell(Text(_formatDate(customer.createdAt))),
                        DataCell(_buildActionButtons(customer)),
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

  Widget _buildCardList(
    BuildContext context,
    CustomersLoaded state,
    List<CustomerModel> pageCustomers,
    int startIndex,
    int totalPages,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: pageCustomers.length,
            itemBuilder: (context, index) {
              final customer = pageCustomers[index];
              final globalIndex = startIndex + index;
              final isSelected = state.selectedCustomer?.id == customer.id;

              return _CustomerCard(
                customer: customer,
                index: globalIndex + 1,
                isSelected: isSelected,
                onTap: () {
                  context
                      .read<CustomersBloc>()
                      .add(SelectCustomer(customer.id));
                },
                onEdit: () => widget.onEdit(customer),
                onPayment: () => widget.onPayment(customer),
                onDelete: () => widget.onDelete(customer),
              );
            },
          ),
        ),
        const SizedBox(height: AppSizes.md),
        _buildPagination(totalPages, state.filteredCustomers.length),
      ],
    );
  }

  Widget _buildCustomerNameCell(CustomerModel customer) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.primary,
          child: Text(
            customer.name.isNotEmpty ? customer.name[0] : 'ع',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Text(
          customer.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 16,
        ),
        const SizedBox(width: 4),
        const Text(
          '0 ج',
          style: TextStyle(color: AppColors.success),
        ),
      ],
    );
  }

  Widget _buildActionButtons(CustomerModel customer) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: Icons.edit,
          color: AppColors.primary,
          tooltip: 'تعديل',
          onTap: () => widget.onEdit(customer),
        ),
        _ActionButton(
          icon: Icons.payment,
          color: customer.hasDebt ? AppColors.warning : AppColors.textSecondary,
          tooltip: 'تسجيل دفعة',
          onTap: customer.hasDebt ? () => widget.onPayment(customer) : null,
        ),
        _ActionButton(
          icon: Icons.delete,
          color: AppColors.danger,
          tooltip: 'حذف',
          onTap: () => widget.onDelete(customer),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
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
            const Text('لا توجد عملاء', style: AppTextStyles.h3),
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

  Widget _buildPagination(int totalPages, int totalItems) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed:
                _currentPage > 0 ? () => setState(() => _currentPage--) : null,
            icon: const Icon(Icons.chevron_right),
            color: AppColors.textSecondary,
            iconSize: 20,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Text(
              '${_currentPage + 1} / $totalPages',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: _currentPage < totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.textSecondary,
            iconSize: 20,
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            '($totalItems)',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xs),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _CustomerCard extends StatefulWidget {
  final CustomerModel customer;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onPayment;
  final VoidCallback onDelete;

  const _CustomerCard({
    required this.customer,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onPayment,
    required this.onDelete,
  });

  @override
  State<_CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<_CustomerCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        transform:
            _isPressed ? (Matrix4.identity()..scale(0.98)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color:
              widget.isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: widget.isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Text(
                  widget.customer.name.isNotEmpty
                      ? widget.customer.name[0]
                      : 'ع',
                  style: const TextStyle(
                    color: Colors.white,
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
                      widget.customer.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.customer.phone,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.customer.hasDebt)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          color: AppColors.danger,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.customer.debtBalance.toStringAsFixed(0)} ج',
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    )
                  else
                    const Text(
                      '0 ج',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(widget.customer.createdAt),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSizes.sm),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      widget.onEdit();
                      break;
                    case 'payment':
                      widget.onPayment();
                      break;
                    case 'delete':
                      widget.onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('تعديل'),
                      ],
                    ),
                  ),
                  if (widget.customer.hasDebt)
                    const PopupMenuItem(
                      value: 'payment',
                      child: Row(
                        children: [
                          Icon(Icons.payment,
                              size: 18, color: AppColors.warning),
                          SizedBox(width: 8),
                          Text('تسجيل دفعة'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: AppColors.danger),
                        SizedBox(width: 8),
                        Text('حذف'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
