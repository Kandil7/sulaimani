import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/datasources/local/sale_local_datasource.dart';
import '../../../data/datasources/local/customer_payment_local_datasource.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/models/customer_payment_model.dart';

class CustomerPaymentHistory extends StatefulWidget {
  final int customerId;
  final Function(SaleModel)? onInvoiceTap;

  const CustomerPaymentHistory({
    super.key,
    required this.customerId,
    this.onInvoiceTap,
  });

  @override
  State<CustomerPaymentHistory> createState() => _CustomerPaymentHistoryState();
}

class _CustomerPaymentHistoryState extends State<CustomerPaymentHistory> {
  List<SaleModel> _sales = [];
  List<CustomerPaymentModel> _payments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final saleDatasource = sl<SaleLocalDatasource>();
      final paymentDatasource = sl<CustomerPaymentLocalDatasource>();

      final results = await Future.wait([
        saleDatasource.getByCustomerId(widget.customerId),
        paymentDatasource.getByCustomerId(widget.customerId),
      ]);

      setState(() {
        _sales = results[0] as List<SaleModel>;
        _payments = results[1] as List<CustomerPaymentModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Merges sales and payments into one chronological timeline (newest first)
  List<_TimelineItem> _buildTimeline() {
    final items = <_TimelineItem>[];

    for (final sale in _sales) {
      items.add(_TimelineItem(
        date: sale.date,
        type: 'sale',
        label: 'شراء (${sale.paymentMethod == 'credit' ? 'آجل' : 'نقدي'})',
        receiptNumber: sale.receiptNumber,
        amount: sale.finalAmount,
        isPositive: sale.paymentMethod == 'credit',
        notes: null,
        sale: sale,
      ));
    }

    for (final payment in _payments) {
      items.add(_TimelineItem(
        date: payment.paymentDate,
        type: 'payment',
        label: payment.paymentType == 'full_settlement'
            ? 'سداد كامل'
            : payment.paymentType == 'partial'
                ? 'سداد جزئي'
                : 'تسوية',
        receiptNumber: payment.linkedSaleId != null
            ? 'فاتورة #${payment.linkedSaleId}'
            : null,
        amount: payment.amount,
        isPositive: false,
        notes: payment.note,
      ));
    }

    // Sort by date descending (newest first)
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          'خطأ: $_error',
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }

    final timeline = _buildTimeline();

    if (timeline.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: const Center(
          child: Text(
            'لا توجد معاملات سابقة',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section headers
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            child: Row(
              children: [
                const SizedBox(width: 24),
                const Expanded(
                  child: Text(
                    'الوصف',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 80,
                  child: Text(
                    'المبلغ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.sm),
              itemCount: timeline.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = timeline[index];
                return _TimelineTile(
                  item: item,
                  onTap: item.sale != null
                      ? () => widget.onInvoiceTap?.call(item.sale!)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem {
  final DateTime date;
  final String type; // 'sale' or 'payment'
  final String label;
  final String? receiptNumber;
  final double amount;
  final bool isPositive; // sale=credit adds to debt, payment reduces debt
  final String? notes;
  final SaleModel? sale; // for clickable invoice

  _TimelineItem({
    required this.date,
    required this.type,
    required this.label,
    this.receiptNumber,
    required this.amount,
    required this.isPositive,
    this.notes,
    this.sale,
  });
}

class _TimelineTile extends StatelessWidget {
  final _TimelineItem item;
  final VoidCallback? onTap;

  const _TimelineTile({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSale = item.type == 'sale';
    final isPayment = item.type == 'payment';
    final isCreditSale = isSale && item.isPositive;
    final isClickable = isSale && item.sale != null;

    Color iconColor;
    IconData icon;
    if (isPayment) {
      iconColor = AppColors.success;
      icon = Icons.payments;
    } else if (isCreditSale) {
      iconColor = AppColors.warning;
      icon = Icons.receipt_long;
    } else {
      iconColor = AppColors.success;
      icon = Icons.receipt;
    }

    return InkWell(
      onTap: isClickable ? onTap : null,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.xs,
          vertical: AppSizes.xs,
        ),
        child: Row(
          children: [
            // Type icon
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 14, color: iconColor),
            ),
            const SizedBox(width: AppSizes.sm),
            // Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isCreditSale
                              ? AppColors.warning
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (isClickable) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.open_in_new,
                          size: 10,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${_formatDate(item.date)}${item.receiptNumber != null ? ' • ${item.receiptNumber}' : ''}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (item.notes != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      item.notes!,
                      style: TextStyle(
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Amount
            SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyUtils.format(item.amount),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPayment
                          ? AppColors.success
                          : isCreditSale
                              ? AppColors.warning
                              : AppColors.success,
                    ),
                  ),
                  Text(
                    isPayment
                        ? 'سداد'
                        : isCreditSale
                            ? 'آجل'
                            : 'نقدي',
                    style: TextStyle(
                      fontSize: 9,
                      color: isPayment
                          ? AppColors.success
                          : isCreditSale
                              ? AppColors.warning
                              : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
