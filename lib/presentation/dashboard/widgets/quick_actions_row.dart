import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback? onQuickSaleTap;
  final VoidCallback? onAddProductTap;
  final VoidCallback? onRecordPaymentTap;

  const QuickActionsRow({
    super.key,
    this.onQuickSaleTap,
    this.onAddProductTap,
    this.onRecordPaymentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.point_of_sale,
            label: 'بيع سريع',
            color: AppColors.primary,
            onTap: onQuickSaleTap,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_box,
            label: 'إضافة منتج',
            color: AppColors.secondary,
            onTap: onAddProductTap,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.payments,
            label: 'تسجيل دفعة',
            color: AppColors.success,
            onTap: onRecordPaymentTap,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.md,
            horizontal: AppSizes.lg,
          ),
          decoration: BoxDecoration(
            color:
                _isHovered ? widget.color.withOpacity(0.1) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: _isHovered ? widget.color : AppColors.border,
              width: 1.5,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.color,
                size: 20,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                widget.label,
                style: AppTextStyles.bodyM.copyWith(
                  color: widget.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
