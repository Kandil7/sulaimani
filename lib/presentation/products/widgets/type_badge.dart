import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/product.dart';

class TypeBadge extends StatelessWidget {
  final ProductType type;

  const TypeBadge({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isMedicine = type == ProductType.medicine;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:
            isMedicine ? AppColors.secondarySurface : AppColors.primarySurface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isMedicine ? 'دواء' : 'مبيد',
        style: AppTextStyles.caption.copyWith(
          color: isMedicine ? AppColors.secondary : AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
