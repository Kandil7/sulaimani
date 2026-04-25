import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_text_styles.dart';

class AppBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final bool isDot;

  const AppBadge({
    super.key,
    required this.text,
    this.color,
    this.isDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.primary;

    if (isDot) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: badgeColor,
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(
          color: badgeColor,
        ),
      ),
    );
  }
}
