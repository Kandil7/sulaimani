import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../models/sale_model.dart';
import '../../models/sale_item_model.dart';
import '../../models/customer_model.dart';
import '../../models/settings_model.dart';

class DatabaseService {
  late Isar _isar;
  bool _isInitialized = false;

  Isar get isar => _isar;

  Future<void> init() async {
    if (_isInitialized) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        CategoryModelSchema,
        ProductModelSchema,
        SaleModelSchema,
        SaleItemModelSchema,
        CustomerModelSchema,
        SettingsModelSchema,
      ],
      directory: dir.path,
      name: 'sulaimani_db',
    );
    _isInitialized = true;
  }
}
