import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import '../../../core/utils/invoice_generator.dart';
import '../../../data/datasources/local/sale_local_datasource.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/models/sale_item_model.dart';
import '../../../data/repositories/settings_repository.dart';
import 'invoices_event.dart';
import 'invoices_state.dart';

class InvoicesBloc extends Bloc<InvoicesEvent, InvoicesState> {
  final SaleLocalDatasource _saleDatasource;
  final Isar _isar;
  final SettingsRepository _settingsRepository;

  InvoicesBloc({
    required SaleLocalDatasource saleDatasource,
    required Isar isar,
    required SettingsRepository settingsRepository,
  })  : _saleDatasource = saleDatasource,
        _isar = isar,
        _settingsRepository = settingsRepository,
        super(InvoicesInitial()) {
    on<LoadRecentSales>(_onLoadRecentSales);
    on<SearchSaleByReceipt>(_onSearchSaleByReceipt);
    on<SelectSale>(_onSelectSale);
    on<RegenerateInvoicePdf>(_onRegenerateInvoicePdf);
    on<ClearSelectedSale>(_onClearSelectedSale);
    on<InternalLoadItems>(_onInternalLoadItems);
  }

  Future<void> _onLoadRecentSales(
    LoadRecentSales event,
    Emitter<InvoicesState> emit,
  ) async {
    emit(InvoicesLoading());
    try {
      // Load last 30 days of sales, sorted by date desc
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final sales = await _saleDatasource.getByDateRange(thirtyDaysAgo, now);
      // Sort manually by date desc since getByDateRange may not guarantee order
      sales.sort((a, b) => b.date.compareTo(a.date));
      emit(InvoicesLoaded(sales: sales));
    } catch (e) {
      emit(InvoicesError('فشل في تحميل الفواتير: $e'));
    }
  }

  Future<void> _onSearchSaleByReceipt(
    SearchSaleByReceipt event,
    Emitter<InvoicesState> emit,
  ) async {
    final currentState = state;
    final sales =
        currentState is InvoicesLoaded ? currentState.sales : <SaleModel>[];

    emit(InvoicesLoading());
    try {
      final receipt = event.receiptNumber.trim();
      if (receipt.isEmpty) {
        // Reload recent sales
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        final allSales =
            await _saleDatasource.getByDateRange(thirtyDaysAgo, now);
        allSales.sort((a, b) => b.date.compareTo(a.date));
        emit(InvoicesLoaded(sales: allSales));
        return;
      }

      final sale = await _saleDatasource.getByReceiptNumber(receipt);
      if (sale != null) {
        final items = await _saleDatasource.getSaleItems(sale.id);
        emit(InvoicesLoaded(
            sales: [sale], selectedSale: sale, selectedSaleItems: items));
      } else {
        emit(InvoicesLoaded(
          sales: sales,
          searchError: 'لم يتم العثور على فاتورة رقم: $receipt',
        ));
      }
    } catch (e) {
      emit(InvoicesError('فشل في البحث: $e'));
    }
  }

  Future<void> _onSelectSale(
    SelectSale event,
    Emitter<InvoicesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! InvoicesLoaded) return;

    try {
      final items = await _saleDatasource.getSaleItems(event.sale.id);
      emit(currentState.copyWith(
        selectedSale: event.sale,
        selectedSaleItems: items,
        clearPdf: true,
        clearSearchError: true,
      ));
    } catch (e) {
      emit(InvoicesError('فشل في تحميل محتويات الفاتورة: $e'));
    }
  }

  Future<void> _onInternalLoadItems(
    InternalLoadItems event,
    Emitter<InvoicesState> emit,
  ) async {
    final currentState = state;
    if (currentState is InvoicesLoaded) {
      emit(currentState.copyWith(
        selectedSale: event.sale,
        selectedSaleItems: event.items,
        clearPdf: true,
        clearSearchError: true,
      ));
    }
  }

  Future<void> _onRegenerateInvoicePdf(
    RegenerateInvoicePdf event,
    Emitter<InvoicesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! InvoicesLoaded) return;

    try {
      final settings = await _settingsRepository.getSettings();
      final pdfBytes = await InvoiceGenerator.generatePdfBytes(
        sale: event.sale,
        items: event.items,
        shopName: settings.pharmacyName,
        shopAddress: settings.pharmacyAddress,
        shopPhone: settings.pharmacyPhone,
        header: settings.invoiceHeader,
        footer: settings.invoiceFooter,
      );
      emit(currentState.copyWith(
        selectedSale: event.sale,
        selectedSaleItems: event.items,
        pdfBytes: pdfBytes,
        clearSearchError: true,
      ));
    } catch (e) {
      emit(InvoicesError('فشل في إنشاء الفاتورة: $e'));
    }
  }

  void _onClearSelectedSale(
    ClearSelectedSale event,
    Emitter<InvoicesState> emit,
  ) {
    final currentState = state;
    if (currentState is InvoicesLoaded) {
      emit(currentState.copyWith(
          clearSelected: true, clearPdf: true, clearSearchError: true));
    }
  }
}
