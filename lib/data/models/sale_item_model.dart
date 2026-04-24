import 'package:isar/isar.dart';
import 'sale_model.dart';
import 'product_model.dart';

part 'sale_item_model.g.dart';

@collection
class SaleItemModel {
  Id id = Isar.autoIncrement;

  final sale = IsarLink<SaleModel>();
  final product = IsarLink<ProductModel>();

  late int quantity;
  late double unitPrice;
  late double total;
}
