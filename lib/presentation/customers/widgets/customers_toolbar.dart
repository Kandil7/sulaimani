import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/customers_bloc.dart';
import '../bloc/customers_event.dart';

class CustomersToolbar extends StatefulWidget {
  const CustomersToolbar({super.key});

  @override
  State<CustomersToolbar> createState() => _CustomersToolbarState();
}

class _CustomersToolbarState extends State<CustomersToolbar> {
  final _searchController = TextEditingController();
  bool _showOnlyWithDebt = false;
  String _sortField = 'name';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('العملاء', style: AppTextStyles.h1),
              const Spacer(),
              IconButton(
                onPressed: () {
                  context.read<CustomersBloc>().add(LoadCustomers());
                },
                icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                tooltip: 'تحديث',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<CustomersBloc>().add(SearchCustomers(value));
                    },
                    decoration: const InputDecoration(
                      hintText: 'البحث بالاسم أو التليفون',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _buildFilterChip('الكل', !_showOnlyWithDebt),
                    _buildFilterChip('مدينون فقط', _showOnlyWithDebt),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortField,
                    icon:
                        const Icon(Icons.sort, color: AppColors.textSecondary),
                    items: const [
                      DropdownMenuItem(
                          value: 'name', child: Text('ترتيب بالاسم')),
                      DropdownMenuItem(
                          value: 'debt', child: Text('ترتيب بالدين')),
                      DropdownMenuItem(
                          value: 'date', child: Text('ترتيب بالتاريخ')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sortField = value;
                        });
                        context.read<CustomersBloc>().add(SortCustomers(
                              field: value,
                              ascending: value == 'name',
                            ));
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showOnlyWithDebt = label == 'مدينون فقط';
        });
        context.read<CustomersBloc>().add(FilterByDebt(_showOnlyWithDebt));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
