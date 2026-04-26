import '../../../data/models/sale_model.dart';
import '../../../data/models/sale_item_model.dart';

abstract class InvoicesState {}

class InvoicesInitial extends InvoicesState {}

class InvoicesLoading extends InvoicesState {}

class InvoicesLoaded extends InvoicesState {
  final List<SaleModel> sales;
  final SaleModel? selectedSale;
  final List<SaleItemModel>? selectedSaleItems;
  final List<int>? pdfBytes;
  final String? searchError;

  InvoicesLoaded({
    required this.sales,
    this.selectedSale,
    this.selectedSaleItems,
    this.pdfBytes,
    this.searchError,
  });

  InvoicesLoaded copyWith({
    List<SaleModel>? sales,
    SaleModel? selectedSale,
    List<SaleItemModel>? selectedSaleItems,
    List<int>? pdfBytes,
    String? searchError,
    bool clearSelected = false,
    bool clearPdf = false,
    bool clearSearchError = false,
  }) {
    return InvoicesLoaded(
      sales: sales ?? this.sales,
      selectedSale: clearSelected ? null : (selectedSale ?? this.selectedSale),
      selectedSaleItems:
          clearSelected ? null : (selectedSaleItems ?? this.selectedSaleItems),
      pdfBytes: clearPdf ? null : (pdfBytes ?? this.pdfBytes),
      searchError: clearSearchError ? null : (searchError ?? this.searchError),
    );
  }
}

class InvoicesError extends InvoicesState {
  final String message;
  InvoicesError(this.message);
}
