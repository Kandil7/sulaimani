import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/di/injection_container.dart';
import '../bloc/products_bloc.dart';
import '../bloc/products_event.dart';
import '../bloc/products_state.dart';
import '../widgets/product_form_dialog.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductsBloc>()..add(LoadProducts()),
      child: const ProductsView(),
    );
  }
}

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('إدارة المنتجات', style: AppTextStyles.h1),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: context.read<ProductsBloc>(),
                      child: const ProductFormDialog(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('إضافة منتج'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.md),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xl),
          // Search Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              onChanged: (value) => context.read<ProductsBloc>().add(SearchProducts(value)),
              decoration: const InputDecoration(
                hintText: 'البحث عن طريق الاسم أو الباركود',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          // Data Table
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  if (state is ProductsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProductsLoaded) {
                    if (state.products.isEmpty) {
                      return const Center(child: Text('لا توجد منتجات', style: TextStyle(color: AppColors.textSecondary)));
                    }
                    return SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('الباركود')),
                          DataColumn(label: Text('اسم المنتج')),
                          DataColumn(label: Text('المادة الفعالة')),
                          DataColumn(label: Text('السعر')),
                          DataColumn(label: Text('الكمية')),
                          DataColumn(label: Text('الإجراءات')),
                        ],
                        rows: state.products.map((product) {
                          return DataRow(cells: [
                            DataCell(Text(product.barcode)),
                            DataCell(Text(product.name)),
                            DataCell(Text(product.scientificName)),
                            DataCell(Text('${product.sellingPrice} ج')),
                            DataCell(Text('${product.stockQuantity}')),
                            DataCell(Row(
                              children: [
                                IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<ProductsBloc>(),
                                      child: ProductFormDialog(product: product),
                                    ),
                                  );
                                }),
                                IconButton(icon: const Icon(Icons.delete, color: AppColors.error), onPressed: () {
                                  context.read<ProductsBloc>().add(DeleteProduct(product.id));
                                }),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    );
                  } else if (state is ProductsError) {
                    return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
