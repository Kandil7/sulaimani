import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/reports_state.dart';

class ReportFilterBar extends StatefulWidget {
  final ReportFilter currentFilter;
  final Function(ReportFilter) onFilterChanged;
  final DateTime fromDate;
  final DateTime toDate;
  final Function(DateTime, DateTime) onDateRangeChanged;
  final String? paymentTypeFilter;
  final Function(String?) onPaymentTypeChanged;

  const ReportFilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.fromDate,
    required this.toDate,
    required this.onDateRangeChanged,
    this.paymentTypeFilter,
    required this.onPaymentTypeChanged,
  });

  @override
  State<ReportFilterBar> createState() => _ReportFilterBarState();
}

class _ReportFilterBarState extends State<ReportFilterBar> {
  late DateTime _fromDate;
  late DateTime _toDate;
  String? _selectedPaymentType;

  @override
  void initState() {
    super.initState();
    _fromDate = widget.fromDate;
    _toDate = widget.toDate;
    _selectedPaymentType = widget.paymentTypeFilter;
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      locale: const Locale('ar', 'IQ'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      widget.onDateRangeChanged(_fromDate, _toDate);
      widget.onFilterChanged(ReportFilter.custom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Today filter button
              _FilterButton(
                label: 'اليوم',
                isActive: widget.currentFilter == ReportFilter.today,
                onTap: () => widget.onFilterChanged(ReportFilter.today),
              ),
              const SizedBox(width: AppSizes.sm),
              // This week filter button
              _FilterButton(
                label: 'الأسبوع',
                isActive: widget.currentFilter == ReportFilter.thisWeek,
                onTap: () => widget.onFilterChanged(ReportFilter.thisWeek),
              ),
              const SizedBox(width: AppSizes.sm),
              // This month filter button
              _FilterButton(
                label: 'الشهر',
                isActive: widget.currentFilter == ReportFilter.thisMonth,
                onTap: () => widget.onFilterChanged(ReportFilter.thisMonth),
              ),
              const SizedBox(width: AppSizes.sm),
              // Custom range button
              _FilterButton(
                label: 'مخصصة',
                isActive: widget.currentFilter == ReportFilter.custom,
                onTap: _selectDateRange,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              // From date display
              Expanded(
                child: _DatePickerField(
                  label: 'من',
                  date: _fromDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _fromDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      locale: const Locale('ar', 'IQ'),
                    );
                    if (picked != null) {
                      setState(() => _fromDate = picked);
                      widget.onDateRangeChanged(_fromDate, _toDate);
                      widget.onFilterChanged(ReportFilter.custom);
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSizes.md),
              // To date display
              Expanded(
                child: _DatePickerField(
                  label: 'إلى',
                  date: _toDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _toDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      locale: const Locale('ar', 'IQ'),
                    );
                    if (picked != null) {
                      setState(() => _toDate = picked);
                      widget.onDateRangeChanged(_fromDate, _toDate);
                      widget.onFilterChanged(ReportFilter.custom);
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSizes.md),
              // Payment type dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedPaymentType,
                      hint: const Text('طريقة الدفع'),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: null, child: Text('الكل')),
                        DropdownMenuItem(value: 'cash', child: Text('نقدي')),
                        DropdownMenuItem(value: 'deferred', child: Text('آجل')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedPaymentType = value);
                        widget.onPaymentTypeChanged(value);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: isActive ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: AppTextStyles.bodyM,
                ),
              ],
            ),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }
}
