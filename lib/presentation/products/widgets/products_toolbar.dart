import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/product.dart';

class ProductsToolbar extends StatelessWidget {
  final String searchQuery;
  final ProductType? selectedFilter;
  final ValueChanged<String> onSearch;
  final ValueChanged<ProductType?> onFilterChanged;
  final VoidCallback onAddPressed;
  final VoidCallback onExportPressed;

  const ProductsToolbar({
    super.key,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onSearch,
    required this.onFilterChanged,
    required this.onAddPressed,
    required this.onExportPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Search TextField
          SizedBox(
            width: 280,
            child: TextField(
              onChanged: onSearch,
              style: AppTextStyles.bodyL,
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج...',
                hintStyle: AppTextStyles.bodyL.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.lg),
          // Filter Chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'الكل',
                    isSelected: selectedFilter == null,
                    onSelected: () => onFilterChanged(null),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  _FilterChip(
                    label: 'أدوية',
                    isSelected: selectedFilter == ProductType.medicine,
                    onSelected: () => onFilterChanged(ProductType.medicine),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  _FilterChip(
                    label: 'مبيدات',
                    isSelected: selectedFilter == ProductType.pesticide,
                    onSelected: () => onFilterChanged(ProductType.pesticide),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          // Export Button
          OutlinedButton.icon(
            onPressed: onExportPressed,
            icon: const Icon(Icons.file_download_outlined, size: 20),
            label: const Text('تصدير'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          // Add Product Button
          ElevatedButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('إضافة منتج'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
