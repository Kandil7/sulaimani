import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/responsive/responsive_layout.dart';
import '../../../core/utils/invoice_generator.dart';
import '../../../core/utils/report_exporter.dart';
import '../../../data/datasources/local/sale_local_datasource.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../invoices/widgets/reprint_invoice_dialog.dart';
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

  Widget _buildExportButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onExport,
  }) {
    return ElevatedButton.icon(
      onPressed: onExport,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
      ),
    );
  }

  /// Build responsive header
  Widget _buildHeader(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('التقارير', style: isMobile ? AppTextStyles.h2 : AppTextStyles.h1),
        Wrap(
          spacing: isMobile ? AppSizes.xs : AppSizes.sm,
          runSpacing: isMobile ? AppSizes.xs : 0,
          children: [
            _buildExportButton(
              label: isMobile ? 'PDF' : 'تصدير PDF',
              icon: Icons.picture_as_pdf,
              color: AppColors.danger,
              onExport: () => _exportReport('pdf'),
            ),
            if (!isMobile) ...[
              const SizedBox(width: AppSizes.sm),
              _buildExportButton(
                label: 'تصدير CSV',
                icon: Icons.table_chart,
                color: AppColors.success,
                onExport: () => _exportReport('csv'),
              ),
              const SizedBox(width: AppSizes.sm),
            ],
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
      ],
    );
  }

  Future<void> _exportReport(String type) async {
    final state = context.read<ReportsBloc>().state;
    if (state is! ReportsLoaded || state.data.invoices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد بيانات للتصدير'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final data = state.data;
    final sales = data.invoices
        .map((inv) => ReportSaleData(
              receiptNumber: inv.invoiceNumber,
              date: inv.date,
              paymentMethod: inv.paymentType,
              totalAmount: inv.amount,
              discount: 0,
              finalAmount: inv.amount,
            ))
        .toList();

    // Fetch shop settings for pharmacy name in exported report
    final settingsRepo = sl<SettingsRepository>();
    final settings = await settingsRepo.getSettings();

    try {
      final filePath = await ReportExporter.getReportPath(type: type);
      final title = _getFilterTitle(data.filter);

      if (type == 'pdf') {
        await ReportExporter.exportToPdf(
          sales: sales,
          title: title,
          fromDate: data.fromDate,
          toDate: data.toDate,
          totalSales: data.totalSales,
          totalProfit: data.totalProfit,
          filePath: filePath,
          shopName: settings.pharmacyName,
        );
      } else {
        await ReportExporter.exportToCsv(
          sales: sales,
          title: title,
          fromDate: data.fromDate,
          toDate: data.toDate,
          filePath: filePath,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تصدير التقرير إلى: $filePath'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التصدير: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _getFilterTitle(ReportFilter filter) {
    switch (filter) {
      case ReportFilter.today:
        return 'تقرير اليوم';
      case ReportFilter.thisWeek:
        return 'تقرير الأسبوع';
      case ReportFilter.thisMonth:
        return 'تقرير الشهر';
      case ReportFilter.custom:
        return 'تقرير مخصص';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ScreenUtils.isMobile(context);
    final padding = ScreenUtils.responsive(
      context,
      mobile: AppSizes.md,
      tablet: AppSizes.md,
      desktop: AppSizes.xl,
    );

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isMobile),
          SizedBox(height: isMobile ? AppSizes.sm : AppSizes.md),
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
                onDateRangeChanged: (from, to) {},
                paymentTypeFilter: _paymentTypeFilter,
                onPaymentTypeChanged: (value) {
                  setState(() => _paymentTypeFilter = value);
                },
              );
            },
          ),
          const SizedBox(height: AppSizes.lg),
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
                        ReportSummaryRow(data: data),
                        const SizedBox(height: AppSizes.lg),
                        Row(
                          children: [
                            Expanded(
                              flex: 60,
                              child: SalesBarChart(dailySales: data.dailySales),
                            ),
                            const SizedBox(width: AppSizes.md),
                            Expanded(
                              flex: 40,
                              child: TopProductsChart(
                                  topProducts: data.topProducts),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.lg),
                        ProfitSummary(data: data),
                        const SizedBox(height: AppSizes.lg),
                        InvoicesTable(
                          invoices: filteredInvoices,
                          onInvoiceTap: (saleId) => _openInvoice(saleId),
                        ),
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

  void _openInvoice(int saleId) async {
    try {
      final saleDatasource = sl<SaleLocalDatasource>();
      final sale = await saleDatasource.getById(saleId);
      if (sale == null || !mounted) return;

      final items = await saleDatasource.getSaleItems(saleId);

      // Fetch settings for logo
      final settingsRepo = sl<SettingsRepository>();
      final settings = await settingsRepo.getSettings();

      final pdfBytes = await InvoiceGenerator.generatePdfBytes(
        sale: sale,
        items: items,
        customerName: sale.customerName,
        shopName: settings.pharmacyName,
        shopAddress: settings.pharmacyAddress,
        shopPhone: settings.pharmacyPhone,
        header: settings.invoiceHeader,
        footer: settings.invoiceFooter,
        logoPath: settings.invoiceLogoPath,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => ReprintInvoiceDialog(
          sale: sale,
          items: items,
          pdfBytes:
              pdfBytes is Uint8List ? pdfBytes : Uint8List.fromList(pdfBytes),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في فتح الفاتورة: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
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
