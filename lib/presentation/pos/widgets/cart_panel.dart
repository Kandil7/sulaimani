import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/models/sale_item_model.dart';
import 'cart_item_row.dart';

/// Dialog to apply discount
Future<double?> _showDiscountDialog(
    BuildContext context, double maxDiscount) async {
  final controller = TextEditingController();

  return showDialog<double>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('إضافة خصم'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الحد الأقصى: ${CurrencyUtils.format(maxDiscount)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'مبلغ الخصم',
              prefixIcon: const Icon(Icons.discount),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final discount = double.tryParse(controller.text) ?? 0;
            if (discount > 0 && discount <= maxDiscount) {
              Navigator.of(context).pop(discount);
            }
          },
          child: const Text('تطبيق'),
        ),
      ],
    ),
  );
}

class CartPanel extends StatelessWidget {
  final List<SaleItemModel> cartItems;
  final double total;
  final double discount;
  final double finalTotal;
  final Function(int, int) onQuantityChanged;
  final Function(int) onRemove;
  final VoidCallback onClearCart;
  final VoidCallback onOpenPayment;
  final VoidCallback onRemoveDiscount;
  final VoidCallback onAddDiscount;
  final bool isProcessing;

  const CartPanel({
    super.key,
    required this.cartItems,
    required this.total,
    required this.discount,
    required this.finalTotal,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onClearCart,
    required this.onOpenPayment,
    required this.onRemoveDiscount,
    required this.onAddDiscount,
    this.isProcessing = false,
  });

  int get _itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '🧾الفاتورة الحالية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    '$_itemCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Cart items list
          Expanded(
            child: cartItems.isEmpty
                ? _buildEmptyCart()
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final product = item.product.value;
                      return CartItemRow(
                        item: item,
                        index: index,
                        availableStock: product?.stockQuantity ?? 0,
                        onQuantityChanged: (qty) =>
                            onQuantityChanged(index, qty),
                        onRemove: () => onRemove(index),
                      );
                    },
                  ),
          ),
          // Totals section
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Column(
              children: [
                // Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'المجموع:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      CurrencyUtils.format(total),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Discount row (show when discount > 0)
                if (discount > 0) ...[
                  const SizedBox(height: AppSizes.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'الخصم: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            '- ${CurrencyUtils.format(discount)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: onRemoveDiscount,
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ] else if (total > 0) ...[
                  // Show "Add Discount" button when no discount and total > 0
                  const SizedBox(height: AppSizes.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onAddDiscount,
                      icon: const Icon(Icons.discount, size: 16),
                      label: const Text('إضافة خصم'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
                const Divider(height: AppSizes.lg),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'الصافي:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      CurrencyUtils.format(finalTotal),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                // Action buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: cartItems.isEmpty || isProcessing
                            ? null
                            : onClearCart,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.md,
                          ),
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                          ),
                        ),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    // Payment button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: cartItems.isEmpty || isProcessing
                            ? null
                            : onOpenPayment,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.md,
                          ),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                          ),
                        ),
                        child: isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('دفع (F2)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'السلة فارغة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            'أضف منتجات من اليمين',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
