import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_summary_row.dart';
import '../widgets/sales_bar_chart.dart';
import '../widgets/top_products_chart.dart';
import '../widgets/invoices_table.dart';
import '../widgets/profit_summary.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String? _paymentTypeFilter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = sl<ReportsBloc>();
        bloc.add(ChangeFilter(ReportFilter.today));
        return bloc;
      },
      child: const _ReportsPageContent(),
    );
  }
}

class _ReportsPageContent extends StatefulWidget {
  const _ReportsPageContent();

  @override
  State<_ReportsPageContent> createState() => _ReportsPageContentState();
}

class _ReportsPageContentState extends State<_ReportsPageContent> {
  String? _paymentTypeFilter;

  void _loadReport(ReportFilter filter) {
    final bloc = context.read<ReportsBloc>();
    final now = DateTime.now();

    DateTime from;
    DateTime to;

    switch (filter) {
      case ReportFilter.today:
        from = DateTime(now.year, now.month, now.day);
        to = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case ReportFilter.thisWeek:
        final daysFromSaturday = now.weekday % 7;
        from = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: daysFromSaturday));
        to = now;
        break;
      case ReportFilter.thisMonth:
        from = DateTime(now.year, now.month, 1);
        to = now;
        break;
      case ReportFilter.custom:
        from = bloc.state is ReportsLoaded
            ? (bloc.state as ReportsLoaded).data.fromDate
            : DateTime(now.year, now.month, 1);
        to = bloc.state is ReportsLoaded
            ? (bloc.state as ReportsLoaded).data.toDate
            : now;
        break;
    }

    bloc.add(LoadReport(from: from, to: to, filter: filter));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('التقارير', style: AppTextStyles.h1),
              IconButton(
                onPressed: () {
                  if (context.read<ReportsBloc>().state is ReportsLoaded) {
                    final currentFilter =
                        (context.read<ReportsBloc>().state as ReportsLoaded)
                            .data
                            .filter;
                    _loadReport(currentFilter);
                  }
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'تحديث',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          // Filter bar
          BlocBuilder<ReportsBloc, ReportsState>(
            builder: (context, state) {
              ReportFilter currentFilter = ReportFilter.today;
              DateTime fromDate = DateTime.now();
              DateTime toDate = DateTime.now();

              if (state is ReportsLoaded) {
                currentFilter = state.data.filter;
                fromDate = state.data.fromDate;
                toDate = state.data.toDate;
              }

              return ReportFilterBar(
                currentFilter: currentFilter,
                onFilterChanged: (filter) {
                  _loadReport(filter);
                },
                fromDate: fromDate,
                toDate: toDate,
                onDateRangeChanged: (from, to) {
                  // Custom date range handling is done in filter bar
                },
                paymentTypeFilter: _paymentTypeFilter,
                onPaymentTypeChanged: (value) {
                  setState(() => _paymentTypeFilter = value);
                },
              );
            },
          ),
          const SizedBox(height: AppSizes.lg),
          // Content
          Expanded(
            child: BlocBuilder<ReportsBloc, ReportsState>(
              builder: (context, state) {
                if (state is ReportsLoading || state is ReportsInitial) {
                  return const _LoadingState();
                }

                if (state is ReportsError) {
                  return _ErrorState(
                    message: state.message,
                    onRetry: () => _loadReport(ReportFilter.today),
                  );
                }

                if (state is ReportsLoaded) {
                  // Apply payment type filter if set
                  final data = state.data;
                  final filteredInvoices = _paymentTypeFilter != null
                      ? data.invoices
                          .where((inv) =>
                              inv.paymentType ==
                              (_paymentTypeFilter == 'cash' ? 'نقدي' : 'آجل'))
                          .toList()
                      : data.invoices;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary cards
                        ReportSummaryRow(data: data),
                        const SizedBox(height: AppSizes.lg),
                        // Charts row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sales bar chart (60%)
                            Expanded(
                              flex: 60,
                              child: SalesBarChart(dailySales: data.dailySales),
                            ),
                            const SizedBox(width: AppSizes.md),
                            // Top products chart (40%)
                            Expanded(
                              flex: 40,
                              child: TopProductsChart(
                                  topProducts: data.topProducts),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.lg),
                        // Profit summary
                        ProfitSummary(data: data),
                        const SizedBox(height: AppSizes.lg),
                        // Invoices table
                        InvoicesTable(invoices: filteredInvoices),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Summary cards skeleton
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: index < 2 ? AppSizes.md : 0,
                  ),
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          // Charts row skeleton
          Row(
            children: [
              Expanded(
                flex: 60,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                flex: 40,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          // Table skeleton
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.danger,
          ),
          const SizedBox(height: AppSizes.md),
          const Text(
            'خطأ في تحميل التقارير',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            message,
            style: AppTextStyles.bodyM,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
