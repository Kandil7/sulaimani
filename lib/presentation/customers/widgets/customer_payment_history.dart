import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/datasources/local/sale_local_datasource.dart';
import '../../../data/models/sale_model.dart';

class CustomerPaymentHistory extends StatefulWidget {
  final int customerId;

  const CustomerPaymentHistory({
    super.key,
    required this.customerId,
  });

  @override
  State<CustomerPaymentHistory> createState() => _CustomerPaymentHistoryState();
}

class _CustomerPaymentHistoryState extends State<CustomerPaymentHistory> {
  List<SaleModel> _sales = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final datasource = sl<SaleLocalDatasource>();
      final sales = await datasource.getByCustomerId(widget.customerId);
      setState(() {
        _sales = sales;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          'خطأ: $_error',
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }

    if (_sales.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: const Center(
          child: Text(
            'لا توجد مشتريات سابقة',
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
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.sm),
        itemCount: _sales.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final sale = _sales[index];
          return _SaleHistoryTile(sale: sale);
        },
      ),
    );
  }
}

class _SaleHistoryTile extends StatelessWidget {
  final SaleModel sale;

  const _SaleHistoryTile({required this.sale});

  @override
  Widget build(BuildContext context) {
    final isCredit = sale.paymentMethod == 'credit';
    final isCash = sale.paymentMethod == 'cash';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      child: Row(
        children: [
          // Payment method indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCredit
                  ? AppColors.warning
                  : isCash
                      ? AppColors.success
                      : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          // Date and receipt
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.receiptNumber,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _formatDate(sale.date),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyUtils.format(sale.finalAmount),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? AppColors.warning : AppColors.success,
                ),
              ),
              Text(
                isCredit ? 'آجل' : 'نقدي',
                style: TextStyle(
                  fontSize: 10,
                  color: isCredit ? AppColors.warning : AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
