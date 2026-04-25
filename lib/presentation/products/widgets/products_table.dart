import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/product_model.dart';
import 'expiry_cell.dart';
import 'quantity_cell.dart';

class ProductsTable extends StatefulWidget {
  final List<ProductModel> products;
  final int currentPage;
  final int totalPages;
  final ProductModel? selectedProduct;
  final ValueChanged<ProductModel>? onProductSelected;
  final ValueChanged<ProductModel>? onEditProduct;
  final ValueChanged<ProductModel>? onDeleteProduct;
  final ValueChanged<int>? onPageChanged;
  final String? sortColumn;
  final bool sortAscending;

  const ProductsTable({
    super.key,
    required this.products,
    this.currentPage = 0,
    this.totalPages = 1,
    this.selectedProduct,
    this.onProductSelected,
    this.onEditProduct,
    this.onDeleteProduct,
    this.onPageChanged,
    this.sortColumn,
    this.sortAscending = true,
  });

  @override
  State<ProductsTable> createState() => _ProductsTableState();
}

class _ProductsTableState extends State<ProductsTable> {
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'لا توجد منتجات',
        subtitle: 'قم بإضافة منتجات للبدء',
      );
    }

    const int itemsPerPage = 20;

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 800,
              headingRowColor: WidgetStateProperty.all(AppColors.background),
              headingTextStyle: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
              ),
              dataRowColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return AppColors.primarySurface;
                }
                return AppColors.surface;
              }),
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              columns: const [
                DataColumn2(label: Text('#'), size: ColumnSize.S),
                DataColumn2(label: Text('الكود'), size: ColumnSize.M),
                DataColumn2(label: Text('اسم المنتج'), size: ColumnSize.L),
                DataColumn2(label: Text('المادة الفعالة'), size: ColumnSize.L),
                DataColumn2(
                    label: Text('السعر'), size: ColumnSize.S, numeric: true),
                DataColumn2(label: Text('الكمية'), size: ColumnSize.M),
                DataColumn2(label: Text('الصلاحية'), size: ColumnSize.M),
                DataColumn2(label: Text('الحالة'), size: ColumnSize.S),
                DataColumn2(label: Text('إجراءات'), size: ColumnSize.S),
              ],
              rows: List.generate(
                widget.products.length,
                (index) {
                  final product = widget.products[index];
                  final isSelected = widget.selectedProduct?.id == product.id;
                  final isHovered = _hoveredIndex == index;

                  return DataRow2(
                    selected: isSelected,
                    onTap: () => widget.onProductSelected?.call(product),
                    color: WidgetStateProperty.resolveWith((states) {
                      if (isSelected) {
                        return AppColors.primarySurface;
                      }
                      if (isHovered) {
                        return AppColors.primarySurface.withValues(alpha: 0.5);
                      }
                      return null;
                    }),
                    decoration: isSelected
                        ? const BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: AppColors.primary,
                                width: 3,
                              ),
                            ),
                          )
                        : null,
                    cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(product.barcode)),
                      DataCell(
                        Text(
                          product.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DataCell(
                        Text(
                          product.scientificName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DataCell(
                          Text('${product.sellingPrice.toStringAsFixed(2)} ج')),
                      DataCell(
                        QuantityCell(
                          quantity: product.stockQuantity,
                          minimumStock: product.minimumStock,
                        ),
                      ),
                      DataCell(
                        ExpiryCell(expiryDate: product.expiryDate),
                      ),
                      DataCell(_buildStatusBadge(product)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 20,
                              ),
                              color: AppColors.primary,
                              onPressed: () =>
                                  widget.onEditProduct?.call(product),
                              tooltip: 'تعديل',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 20,
                              ),
                              color: AppColors.danger,
                              onPressed: () =>
                                  widget.onDeleteProduct?.call(product),
                              tooltip: 'حذف',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.md),
        // Pagination
        if (widget.totalPages > 1) _buildPagination(itemsPerPage),
      ],
    );
  }

  Widget _buildStatusBadge(ProductModel product) {
    String label;
    Color backgroundColor;
    Color textColor;

    if (product.stockQuantity <= 0) {
      label = 'نفد';
      backgroundColor = AppColors.border;
      textColor = AppColors.textSecondary;
    } else if (product.expiryDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final expiry = DateTime(
        product.expiryDate!.year,
        product.expiryDate!.month,
        product.expiryDate!.day,
      );

      if (today.isAfter(expiry)) {
        label = 'منتهي';
        backgroundColor = AppColors.dangerSurface;
        textColor = AppColors.danger;
      } else if (product.stockQuantity <= product.minimumStock) {
        label = 'مخزون منخفض';
        backgroundColor = AppColors.warningSurface;
        textColor = AppColors.warning;
      } else {
        label = 'متاح';
        backgroundColor = AppColors.successSurface;
        textColor = AppColors.success;
      }
    } else if (product.stockQuantity <= product.minimumStock) {
      label = 'مخزون منخفض';
      backgroundColor = AppColors.warningSurface;
      textColor = AppColors.warning;
    } else {
      label = 'متاح';
      backgroundColor = AppColors.successSurface;
      textColor = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPagination(int itemsPerPage) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: widget.currentPage > 0
                ? () => widget.onPageChanged?.call(widget.currentPage - 1)
                : null,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            'صفحة ${widget.currentPage + 1} من ${widget.totalPages}',
            style: AppTextStyles.bodyM,
          ),
          const SizedBox(width: AppSizes.sm),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: widget.currentPage < widget.totalPages - 1
                ? () => widget.onPageChanged?.call(widget.currentPage + 1)
                : null,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
