import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/responsive/responsive_layout.dart';
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
    final isMobile = ScreenUtils.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? AppSizes.sm : AppSizes.md),
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
          // Header row
          Row(
            children: [
              const Text('العملاء', style: AppTextStyles.h2),
              const Spacer(),
              _AnimatedRefreshButton(
                onTap: () {
                  context.read<CustomersBloc>().add(LoadCustomers());
                },
              ),
            ],
          ),
          SizedBox(height: isMobile ? AppSizes.sm : AppSizes.md),
          // Search and filters
          if (isMobile) _buildMobileLayout() else _buildDesktopLayout(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Search field
        _buildSearchField(),
        const SizedBox(height: AppSizes.sm),
        // Filter chips
        Row(
          children: [
            Expanded(child: _buildFilterChip('الكل', !_showOnlyWithDebt)),
            const SizedBox(width: AppSizes.sm),
            Expanded(child: _buildFilterChip('مدينون', _showOnlyWithDebt)),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        // Sort dropdown
        _buildSortDropdown(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Search field
        Expanded(
          flex: 2,
          child: _buildSearchField(),
        ),
        const SizedBox(width: AppSizes.md),
        // Filter chips
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _buildFilterChip('الكل', !_showOnlyWithDebt),
              _buildFilterChip('مدينون', _showOnlyWithDebt),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.md),
        // Sort dropdown
        _buildSortDropdown(),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
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
        decoration: InputDecoration(
          hintText: 'البحث بالاسم أو التليفون...',
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    context.read<CustomersBloc>().add(SearchCustomers(''));
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
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
              const Icon(Icons.sort, color: AppColors.textSecondary, size: 18),
          items: const [
            DropdownMenuItem(value: 'name', child: Text('الاسم')),
            DropdownMenuItem(value: 'debt', child: Text('الدين')),
            DropdownMenuItem(value: 'date', child: Text('التاريخ')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _sortField = value);
              context.read<CustomersBloc>().add(SortCustomers(
                    field: value,
                    ascending: value == 'name',
                  ));
            }
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showOnlyWithDebt = label == 'مدينون';
        });
        context.read<CustomersBloc>().add(FilterByDebt(_showOnlyWithDebt));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _AnimatedRefreshButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedRefreshButton({required this.onTap});

  @override
  State<_AnimatedRefreshButton> createState() => _AnimatedRefreshButtonState();
}

class _AnimatedRefreshButtonState extends State<_AnimatedRefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rotation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotation,
      child: IconButton(
        onPressed: _handleTap,
        icon: const Icon(Icons.refresh),
        color: AppColors.textSecondary,
        tooltip: 'تحديث',
      ),
    );
  }
}
