import 'package:isar/isar.dart';
import 'category_model.dart';

part 'product_model.g.dart';

@collection
class ProductModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String barcode;

  @Index()
  late String name;

  late String scientificName;

  String? description;

  late double purchasePrice;
  late double sellingPrice;

  late int stockQuantity;
  late int minimumStock;

  DateTime? expiryDate;

  /// Product type: 'medicine' or 'pesticide'. Defaults to 'medicine'.
  late String productType;

  final category = IsarLink<CategoryModel>();

  late DateTime createdAt;
  late DateTime updatedAt;

  ProductModel() {
    productType = 'medicine';
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }
}
