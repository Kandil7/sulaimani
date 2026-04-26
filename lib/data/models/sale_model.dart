import 'package:isar/isar.dart';
import 'sale_item_model.dart';
import 'customer_model.dart';

part 'sale_model.g.dart';

@collection
class SaleModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String receiptNumber;

  late DateTime date;

  late double totalAmount;
  late double discount;
  late double finalAmount;

  late String paymentMethod; // 'cash', 'card', 'credit'

  /// Amount actually paid by customer (for cash sales)
  late double paidAmount;

  /// Remaining amount to be collected (for credit or partial payment)
  late double remainingAmount;

  /// Link to customer for credit sales
  final customer = IsarLink<CustomerModel>();

  /// Customer ID for efficient querying (populated for credit sales)
  @Index()
  int? customerId;

  /// Customer name for easy display without loading the link
  String? customerName;

  /// Optional notes for the sale transaction
  String? notes;

  @Backlink(to: 'sale')
  final items = IsarLinks<SaleItemModel>();

  late DateTime createdAt;
  late DateTime updatedAt;
}
