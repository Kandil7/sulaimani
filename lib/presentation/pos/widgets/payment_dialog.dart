import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/models/customer_model.dart';

class PaymentDialog extends StatefulWidget {
  final double totalAmount;
  final double discount;
  final List<CustomerModel> customers;
  final int? selectedCustomerId;
  final double? customerDebt;
  final bool isLoading;
  final Function(
          String paymentType, double paidAmount, int? customerId, String? notes)
      onConfirm;
  final VoidCallback onCancel;
  final Function(double) onDiscountChanged;

  const PaymentDialog({
    super.key,
    required this.totalAmount,
    required this.discount,
    required this.customers,
    required this.selectedCustomerId,
    this.customerDebt,
    required this.onConfirm,
    required this.onCancel,
    required this.onDiscountChanged,
    this.isLoading = false,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String _paymentType = 'cash';
  final _paidAmountController = TextEditingController();
  final _discountController = TextEditingController();
  final _notesController = TextEditingController();
  final _newCustomerNameController = TextEditingController();
  final _newCustomerPhoneController = TextEditingController();
  int? _selectedCustomerId;
  bool _showAddCustomer = false;

  @override
  void initState() {
    super.initState();
    _paymentType = widget.selectedCustomerId != null ? 'credit' : 'cash';
    _selectedCustomerId = widget.selectedCustomerId;
    _paidAmountController.text = widget.totalAmount.toStringAsFixed(2);
    if (widget.discount > 0) {
      _discountController.text = widget.discount.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _paidAmountController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    _newCustomerNameController.dispose();
    _newCustomerPhoneController.dispose();
    super.dispose();
  }

  double get _finalTotal {
    return widget.totalAmount -
        (double.tryParse(_discountController.text) ?? 0);
  }

  double get _paidAmount => double.tryParse(_paidAmountController.text) ?? 0;

  double get _change => _paidAmount - _finalTotal;

  bool get _isValid {
    if (_paymentType == 'cash') {
      return _paidAmount >= _finalTotal;
    } else {
      return _selectedCustomerId != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.payment,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: AppSizes.sm),
                const Text(
                  'الدفع وإتمام البيع',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancel,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: AppSizes.md),

            // Total amount display
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'المبلغ الإجمالي:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    CurrencyUtils.format(widget.totalAmount),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Payment type selection
            Row(
              children: [
                Expanded(
                  child: _buildPaymentTypeButton('cash', '💵 نقدي'),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: _buildPaymentTypeButton('credit', '📋 بالأجل'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            // Conditional content based on payment type
            if (_paymentType == 'cash')
              _buildCashPaymentFields()
            else
              _buildCreditPaymentFields(),

            // Discount field
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: _discountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'الخصم (اختياري)',
                prefixIcon: const Icon(Icons.discount),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              onChanged: (value) {
                final discount = double.tryParse(value) ?? 0;
                widget.onDiscountChanged(discount);
              },
            ),

            // Notes field
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.isLoading ? null : widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSizes.md),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isValid && !widget.isLoading
                        ? () => widget.onConfirm(
                              _paymentType,
                              _paidAmount,
                              _selectedCustomerId,
                              _notesController.text.isEmpty
                                  ? null
                                  : _notesController.text,
                            )
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSizes.md),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('إتمام البيع'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTypeButton(String type, String label) {
    final isSelected = _paymentType == type;
    return InkWell(
      onTap: () => setState(() => _paymentType = type),
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildCashPaymentFields() {
    return Column(
      children: [
        // Paid amount field
        TextField(
          controller: _paidAmountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'المبلغ المدفوع',
            prefixIcon: const Icon(Icons.money),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSizes.sm),

        // Quick amount buttons
        Row(
          children: [
            _buildQuickAmountButton(_finalTotal),
            _buildQuickAmountButton(
              (_finalTotal / 10).ceil() * 10.0,
            ),
            _buildQuickAmountButton(
              (_finalTotal / 50).ceil() * 50.0,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),

        // Change display
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: _change >= 0
                ? AppColors.successSurface
                : AppColors.dangerSurface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _change >= 0 ? 'الباقي:' : 'المطلوب:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _change >= 0 ? AppColors.success : AppColors.error,
                ),
              ),
              Text(
                CurrencyUtils.format(_change.abs()),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _change >= 0 ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmountButton(double amount) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: OutlinedButton(
          onPressed: () {
            _paidAmountController.text = amount.toStringAsFixed(2);
            setState(() {});
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: Text(
            CurrencyUtils.format(amount),
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ),
    );
  }

  Widget _buildCreditPaymentFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer dropdown
        const Text(
          'اختر العميل:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        if (!_showAddCustomer) ...[
          DropdownButtonFormField<int>(
            value: _selectedCustomerId,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
            ),
            hint: const Text('اختر عميل...'),
            items: widget.customers.map((customer) {
              return DropdownMenuItem<int>(
                value: customer.id,
                child: Text(customer.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCustomerId = value;
              });
            },
          ),
          const SizedBox(height: AppSizes.sm),

          // Add new customer button
          TextButton.icon(
            onPressed: () {
              setState(() => _showAddCustomer = true);
            },
            icon: const Icon(Icons.add),
            label: const Text('إضافة عميل جديد'),
          ),
        ] else ...[
          // Add new customer form
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Column(
              children: [
                const Text(
                  'إضافة عميل جديد',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  controller: _newCustomerNameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  controller: _newCustomerPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'التليفون',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() => _showAddCustomer = false);
                      },
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton(
                      onPressed: _newCustomerNameController.text.isNotEmpty
                          ? () {
                              // Handle new customer creation
                              setState(() => _showAddCustomer = false);
                            }
                          : null,
                      child: const Text('إضافة'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        // Customer debt display
        if (_selectedCustomerId != null && widget.customerDebt != null) ...[
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.warningSurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الديون السابقة:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                Text(
                  CurrencyUtils.format(widget.customerDebt!),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
