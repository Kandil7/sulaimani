import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/di/injection_container.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';
import '../bloc/pos_state.dart';

class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PosBloc>(),
      child: const PosView(),
    );
  }
}

class PosView extends StatelessWidget {
  const PosView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PosBloc, PosState>(
      listener: (context, state) {
        if (state is PosSaleCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تمت عملية البيع بنجاح. رقم الفاتورة: ${state.receiptNumber}')),
          );
        } else if (state is PosError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        final activeState = state is PosActive ? state : const PosActive();
        
        return Row(
          children: [
            // Left Side: Cart & Checkout
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('سلة المشتريات', style: AppTextStyles.h2),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: activeState.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = activeState.cartItems[index];
                          final product = item.product.value;
                          return ListTile(
                            title: Text(product?.name ?? ''),
                            subtitle: Text('${item.unitPrice} ج'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: item.quantity > 1 ? () => context.read<PosBloc>().add(UpdateCartItemQuantity(index, item.quantity - 1)) : null,
                                ),
                                Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => context.read<PosBloc>().add(UpdateCartItemQuantity(index, item.quantity + 1)),
                                ),
                                const SizedBox(width: AppSizes.md),
                                Text('${item.total} ج', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                  onPressed: () => context.read<PosBloc>().add(RemoveFromCart(index)),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الإجمالي:', style: AppTextStyles.h2),
                        Text('${activeState.total} ج', style: AppTextStyles.h1.copyWith(color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: activeState.cartItems.isEmpty ? null : () => context.read<PosBloc>().add(ClearCart()),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                            ),
                            child: const Text('إلغاء'),
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: activeState.cartItems.isEmpty ? null : () => context.read<PosBloc>().add(ProcessSale()),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('دفع وإصدار الفاتورة (F12)'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            
            // Right Side: Products Search
            Expanded(
              flex: 6,
              child: Container(
                color: AppColors.background,
                padding: const EdgeInsets.all(AppSizes.xl),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (value) => context.read<PosBloc>().add(SearchProductPos(value)),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن منتج (باركود / اسم)',
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: AppSizes.md,
                          mainAxisSpacing: AppSizes.md,
                        ),
                        itemCount: activeState.searchResults.length,
                        itemBuilder: (context, index) {
                          final product = activeState.searchResults[index];
                          return InkWell(
                            onTap: () => context.read<PosBloc>().add(AddToCart(product)),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSizes.md),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.medication, size: 40, color: AppColors.primary),
                                    const SizedBox(height: AppSizes.sm),
                                    Text(product.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const Spacer(),
                                    Text('${product.sellingPrice} ج', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
