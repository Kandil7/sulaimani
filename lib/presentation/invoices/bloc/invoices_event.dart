import '../../../data/models/sale_model.dart';
import '../../../data/models/sale_item_model.dart';

abstract class InvoicesEvent {}

class LoadRecentSales extends InvoicesEvent {}

class SearchSaleByReceipt extends InvoicesEvent {
  final String receiptNumber;
  SearchSaleByReceipt(this.receiptNumber);
}

class SelectSale extends InvoicesEvent {
  final SaleModel sale;
  SelectSale(this.sale);
}

class RegenerateInvoicePdf extends InvoicesEvent {
  final SaleModel sale;
  final List<SaleItemModel> items;
  RegenerateInvoicePdf(this.sale, this.items);
}

class ClearSelectedSale extends InvoicesEvent {}

class InternalLoadItems extends InvoicesEvent {
  final SaleModel sale;
  final List<SaleItemModel> items;
  InternalLoadItems(this.sale, this.items);
}
