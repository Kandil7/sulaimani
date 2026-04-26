import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../core/di/injection_container.dart';
import '../../../data/datasources/local/sale_local_datasource.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/models/sale_item_model.dart';
import '../bloc/invoices_bloc.dart';
import '../bloc/invoices_event.dart';
import '../bloc/invoices_state.dart';
import '../widgets/reprint_invoice_dialog.dart';
import 'package:isar/isar.dart';

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InvoicesBloc(
        saleDatasource: sl<SaleLocalDatasource>(),
        isar: sl<Isar>(),
        settingsRepository: sl<SettingsRepository>(),
      )..add(LoadRecentSales()),
      child: const _InvoicesPageContent(),
    );
  }
}

class _InvoicesPageContent extends StatefulWidget {
  const _InvoicesPageContent();

  @override
  State<_InvoicesPageContent> createState() => _InvoicesPageContentState();
}

class _InvoicesPageContentState extends State<_InvoicesPageContent> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSizes.lg),
            _buildSearchBar(),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.receipt_long, size: 32, color: AppColors.primary),
        const SizedBox(width: AppSizes.sm),
        Text('الفواتير', style: AppTextStyles.h1),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () {
            context.read<InvoicesBloc>().add(LoadRecentSales());
            _searchController.clear();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('تحديث'),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'ابحث برقم الفاتورة...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
            ),
            onSubmitted: (value) {
              context.read<InvoicesBloc>().add(SearchSaleByReceipt(value));
            },
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        ElevatedButton(
          onPressed: () {
            context.read<InvoicesBloc>().add(
                  SearchSaleByReceipt(_searchController.text),
                );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.lg,
              vertical: AppSizes.md,
            ),
          ),
          child: const Text('بحث'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return BlocBuilder<InvoicesBloc, InvoicesState>(
      builder: (context, state) {
        if (state is InvoicesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is InvoicesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.danger),
                const SizedBox(height: AppSizes.md),
                Text(state.message,
                    style: const TextStyle(color: AppColors.danger)),
                const SizedBox(height: AppSizes.md),
                OutlinedButton(
                  onPressed: () =>
                      context.read<InvoicesBloc>().add(LoadRecentSales()),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (state is InvoicesLoaded) {
          if (state.searchError != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.searchError!),
                  backgroundColor: AppColors.warning,
                ),
              );
            });
          }

          if (state.sales.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    'لا توجد فواتير في الفترة الأخيرة',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  const Text(
                    'قم ببيع منتجات من نقطة البيع لإضافة فواتير',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return _buildSalesTable(state.sales);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSalesTable(List<SaleModel> sales) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusMd),
                topRight: Radius.circular(AppSizes.radiusMd),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'رقم الفاتورة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'التاريخ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'طريقة الدفع',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'العميل',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'الإجمالي',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'الإجراءات',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Table rows
          Expanded(
            child: ListView.separated(
              itemCount: sales.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final sale = sales[index];
                return _buildSaleRow(sale);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleRow(SaleModel sale) {
    return InkWell(
      onTap: () => _showReprintDialog(sale),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  const Icon(Icons.receipt, size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSizes.xs),
                  Text(
                    sale.receiptNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                app_date.AppDateUtils.formatToDate(sale.date),
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: sale.paymentMethod == 'cash'
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    sale.paymentMethod == 'cash' ? 'نقدي' : 'آجل',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: sale.paymentMethod == 'cash'
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                sale.customerName ?? '—',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                CurrencyUtils.format(sale.finalAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _showReprintDialog(sale),
                    icon: const Icon(Icons.print, size: 18),
                    tooltip: 'إعادة طباعة',
                    color: AppColors.primary,
                  ),
                  IconButton(
                    onPressed: () => _showSaleDetails(sale),
                    icon: const Icon(Icons.visibility, size: 18),
                    tooltip: 'عرض التفاصيل',
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReprintDialog(SaleModel sale) async {
    // Load sale items and regenerate PDF
    final bloc = context.read<InvoicesBloc>();
    bloc.add(SelectSale(sale));

    // Wait a bit for state to update, then show dialog
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    final state = bloc.state;
    if (state is InvoicesLoaded && state.selectedSale != null) {
      bloc.add(RegenerateInvoicePdf(
        state.selectedSale!,
        state.selectedSaleItems ?? [],
      ));

      // Wait for PDF generation
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      final updatedState = bloc.state;
      if (updatedState is InvoicesLoaded &&
          updatedState.selectedSale != null &&
          updatedState.pdfBytes != null) {
        showDialog(
          context: context,
          builder: (ctx) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: bloc),
            ],
            child: BlocBuilder<InvoicesBloc, InvoicesState>(
              builder: (context, state) {
                if (state is InvoicesLoaded &&
                    state.pdfBytes != null &&
                    state.selectedSale != null) {
                  return ReprintInvoiceDialog(
                    sale: state.selectedSale!,
                    items: state.selectedSaleItems ?? [],
                    pdfBytes: state.pdfBytes!,
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        );
      }
    }
  }

  void _showSaleDetails(SaleModel sale) {
    showDialog(
      context: context,
      builder: (ctx) {
        final itemsFuture = context.read<InvoicesBloc>();
        // We'll load items directly
        return FutureBuilder<List<SaleItemModel>>(
          future: sl<SaleLocalDatasource>().getSaleItems(sale.id),
          builder: (context, snapshot) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long,
                            size: 28, color: AppColors.primary),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          sale.receiptNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildDetailRow('التاريخ:',
                        app_date.AppDateUtils.formatToDate(sale.date)),
                    _buildDetailRow('طريقة الدفع:',
                        sale.paymentMethod == 'cash' ? 'نقدي' : 'آجل'),
                    if (sale.customerName != null)
                      _buildDetailRow('العميل:', sale.customerName!),
                    _buildDetailRow(
                        'الإجمالي:', CurrencyUtils.format(sale.totalAmount)),
                    if (sale.discount > 0)
                      _buildDetailRow(
                          'الخصم:', CurrencyUtils.format(sale.discount)),
                    _buildDetailRow(
                        'الصافي:', CurrencyUtils.format(sale.finalAmount)),
                    _buildDetailRow(
                        'المدفوع:', CurrencyUtils.format(sale.paidAmount)),
                    if (sale.remainingAmount > 0)
                      _buildDetailRow('الباقي:',
                          CurrencyUtils.format(sale.remainingAmount)),
                    const SizedBox(height: AppSizes.md),
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) ...[
                      const Text(
                        'المنتجات',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 150),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final item = snapshot.data![index];
                            return _buildDetailRow(
                              '${item.product.value?.name ?? '—'} × ${item.quantity}',
                              CurrencyUtils.format(item.total),
                            );
                          },
                        ),
                      ),
                    ] else if (snapshot.connectionState ==
                        ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: AppSizes.md),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('إغلاق'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
