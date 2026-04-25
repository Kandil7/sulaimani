import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/models/sale_item_model.dart';

class CartItemRow extends StatelessWidget {
  final SaleItemModel item;
  final int index;
  final int availableStock;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemRow({
    super.key,
    required this.item,
    required this.index,
    required this.availableStock,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product.value;
    final showStockWarning = item.quantity > availableStock;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // Product info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product?.name ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${CurrencyUtils.format(item.unitPrice)} / وحدة',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (showStockWarning)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningSurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'المخزون: $availableStock',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Quantity controls
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decrease button
                InkWell(
                  onTap: item.quantity > 1
                      ? () => onQuantityChanged(item.quantity - 1)
                      : onRemove,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppSizes.radiusSm - 1),
                  ),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    child: Icon(
                      item.quantity > 1 ? Icons.remove : Icons.delete_outline,
                      size: 16,
                      color: item.quantity > 1
                          ? AppColors.textPrimary
                          : AppColors.error,
                    ),
                  ),
                ),
                // Quantity display
                Container(
                  width: 36,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      vertical: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                // Increase button
                InkWell(
                  onTap: item.quantity < availableStock
                      ? () => onQuantityChanged(item.quantity + 1)
                      : null,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(AppSizes.radiusSm - 1),
                  ),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: item.quantity < availableStock
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          // Total for this item
          SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyUtils.format(item.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${item.quantity} × ${CurrencyUtils.format(item.unitPrice)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.xs),
          // Remove button
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              child: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
