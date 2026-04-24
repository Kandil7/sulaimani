import 'package:isar/isar.dart';
import 'sale_item_model.dart';

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

  late String paymentMethod; // 'cash', 'card'

  @Backlink(to: 'sale')
  final items = IsarLinks<SaleItemModel>();

  late DateTime createdAt;
  late DateTime updatedAt;
}
