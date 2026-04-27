import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/theme/app_text_styles.dart';
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

  bool get _isExpired {
    final expiry = widget.product.expiryDate;
    if (expiry == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDate = DateTime(expiry.year, expiry.month, expiry.day);
    return today.isAfter(expiryDate);
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
    final isExpired = _isExpired;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: isOutOfStock ? 0.5 : (isExpired ? 0.7 : 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(
                  color: _showCheckmark
                      ? AppColors.success
                      : isExpired
                          ? AppColors.danger.withOpacity(0.5)
                          : (hasLowStock
                              ? AppColors.warning.withOpacity(0.5)
                              : AppColors.border),
                  width: _showCheckmark || isExpired || hasLowStock ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _showCheckmark
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.shadowLight,
                    blurRadius: _elevationAnimation.value,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isOutOfStock ? null : _handleTap,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.sm),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Product icon with container
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSizes.sm),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMd),
                              ),
                              child: Icon(
                                _getProductIcon(),
                                size: 28,
                                color: AppColors.primary,
                              ),
                            ),
                            if (widget.quantityInCart > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            AppColors.primary.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${widget.quantityInCart}',
                                    style: AppTextStyles.badge,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.sm),
                        // Product name
                        Text(
                          widget.product.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        // Price
                        Text(
                          CurrencyUtils.format(widget.product.sellingPrice),
                          style: AppTextStyles.moneySm,
                        ),
                        const SizedBox(height: AppSizes.xs),
                        // Stock indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _getStockColor(),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.product.stockQuantity}',
                              style: AppTextStyles.captionSm.copyWith(
                                color: _getStockColor(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (isOutOfStock || isExpired)
                          Container(
                            margin: const EdgeInsets.only(top: AppSizes.xs),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.dangerSurface,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSm),
                            ),
                            child: Text(
                              isOutOfStock ? 'نفد' : 'منتهي',
                              style: AppTextStyles.captionSm.copyWith(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
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
