import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/alerts_state.dart';

class AlertSection extends StatefulWidget {
  final String title;
  final String type;
  final Color color;
  final IconData icon;
  final List<ProductAlert> alerts;
  final Function(ProductAlert)? onEditProduct;

  const AlertSection({
    super.key,
    required this.title,
    required this.type,
    required this.color,
    required this.icon,
    required this.alerts,
    this.onEditProduct,
  });

  @override
  State<AlertSection> createState() => _AlertSectionState();
}

class _AlertSectionState extends State<AlertSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusMd),
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(AppSizes.radiusMd),
                  bottom: _isExpanded
                      ? Radius.zero
                      : const Radius.circular(AppSizes.radiusMd),
                ),
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: widget.color, size: 20),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.h3.copyWith(color: widget.color),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text(
                      '${widget.alerts.length}',
                      style: AppTextStyles.label.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.color,
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (_isExpanded)
            if (widget.alerts.isEmpty)
              _buildEmptyState()
            else
              _buildAlertsList()
          else
            const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.success,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'لا توجد منتجات في هذه الفئة',
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsList() {
    return Column(
      children: widget.alerts.map((alert) {
        return _AlertRowWidget(
          alert: alert,
          color: widget.color,
          onEdit: widget.onEditProduct != null
              ? () => widget.onEditProduct!(alert)
              : null,
        );
      }).toList(),
    );
  }
}

class _AlertRowWidget extends StatelessWidget {
  final ProductAlert alert;
  final Color color;
  final VoidCallback? onEdit;

  const _AlertRowWidget({
    required this.alert,
    required this.color,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysLeft = alert.expiryDate != null
        ? DateTime(alert.expiryDate!.year, alert.expiryDate!.month,
                alert.expiryDate!.day)
            .difference(today)
            .inDays
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Type indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // Product name
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.productName,
                  style: AppTextStyles.bodyL.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  alert.type,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Quantity/Stock
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الكمية', style: AppTextStyles.caption),
                Text(
                  '${alert.quantity}',
                  style: AppTextStyles.bodyM.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Date or countdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('متبقي', style: AppTextStyles.caption),
                if (daysLeft != null)
                  Text(
                    daysLeft < 0 ? 'منتهي' : '$daysLeft يوم',
                    style: AppTextStyles.bodyM.copyWith(
                      color: daysLeft < 0
                          ? AppColors.danger
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text('-', style: AppTextStyles.bodyM),
              ],
            ),
          ),

          // Actions
          if (onEdit != null)
            ElevatedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('تعديل'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
