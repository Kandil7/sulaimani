import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/models/product_model.dart';

class ProductPOSCard extends StatefulWidget {
  final ProductModel product;
  final int quantityInCart;
  final VoidCallback onTap;

  const ProductPOSCard({
    super.key,
    required this.product,
    required this.onTap,
    this.quantityInCart = 0,
  });

  @override
  State<ProductPOSCard> createState() => _ProductPOSCardState();
}

class _ProductPOSCardState extends State<ProductPOSCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _showCheckmark = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() => _showCheckmark = true);
    widget.onTap();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showCheckmark = false);
      }
    });
  }

  Color _getStockColor() {
    if (widget.product.stockQuantity <= 0) {
      return AppColors.error;
    } else if (widget.product.stockQuantity <= widget.product.minimumStock) {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  IconData _getProductIcon() {
    final name = widget.product.name.toLowerCase();
    if (name.contains('حبوب') ||
        name.contains('كبسول') ||
        name.contains('قرص')) {
      return Icons.medication;
    } else if (name.contains('شراب') || name.contains('سائل')) {
      return Icons.local_drink;
    } else if (name.contains('دهان') ||
        name.contains('مرهم') ||
        name.contains('كريم')) {
      return Icons.sanitizer;
    } else if (name.contains(' injection') || name.contains('حقن')) {
      return Icons.vaccines;
    }
    return Icons.medication;
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = widget.product.stockQuantity <= 0;
    final hasLowStock =
        widget.product.stockQuantity <= widget.product.minimumStock;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: isOutOfStock ? 0.5 : 1.0,
            child: Card(
              elevation: _elevationAnimation.value,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                side: BorderSide(
                  color: _showCheckmark
                      ? AppColors.success
                      : (hasLowStock
                          ? AppColors.warning.withOpacity(0.5)
                          : Colors.transparent),
                  width: _showCheckmark || hasLowStock ? 2 : 0,
                ),
              ),
              child: InkWell(
                onTap: isOutOfStock ? null : _handleTap,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Product icon
                      Stack(
                        children: [
                          Icon(
                            _getProductIcon(),
                            size: 36,
                            color: AppColors.primary,
                          ),
                          if (widget.quantityInCart > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${widget.quantityInCart}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.xs),
                      // Product name
                      Text(
                        widget.product.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      // Price
                      Text(
                        CurrencyUtils.format(widget.product.sellingPrice),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      // Stock indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getStockColor(),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.product.stockQuantity}',
                            style: TextStyle(
                              fontSize: 11,
                              color: _getStockColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (isOutOfStock)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'نفد',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
