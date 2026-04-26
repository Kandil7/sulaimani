import 'package:isar/isar.dart';
import '../../models/sale_model.dart';
import '../../models/sale_item_model.dart';
import '../../models/product_model.dart';
import '../../models/customer_model.dart';

class SaleLocalDatasource {
  final Isar isar;

  SaleLocalDatasource(this.isar);

  Future<List<SaleModel>> getAll() async {
    return await isar.collection<SaleModel>().where().findAll();
  }

  Future<SaleModel?> getById(int id) async {
    return await isar.collection<SaleModel>().get(id);
  }

  Future<SaleModel?> getByReceiptNumber(String receiptNumber) async {
    return await isar
        .collection<SaleModel>()
        .filter()
        .receiptNumberEqualTo(receiptNumber)
        .findFirst();
  }

  Future<int> insert(SaleModel sale) async {
    return await isar.writeTxn(() async {
      return await isar.collection<SaleModel>().put(sale);
    });
  }

  Future<void> update(SaleModel sale) async {
    await isar.writeTxn(() async {
      await isar.collection<SaleModel>().put(sale);
    });
  }

  Future<bool> delete(int id) async {
    return await isar.writeTxn(() async {
      return await isar.collection<SaleModel>().delete(id);
    });
  }

  Future<List<SaleModel>> getByDateRange(DateTime from, DateTime to) async {
    return await isar
        .collection<SaleModel>()
        .filter()
        .dateGreaterThan(from.subtract(const Duration(seconds: 1)))
        .dateLessThan(to.add(const Duration(days: 1)))
        .findAll();
  }

  Future<int> createSaleWithItems({
    required List<SaleItemModel> saleItems,
    required SaleModel sale,
    int? customerId,
  }) async {
    return await isar.writeTxn(() async {
      // Insert the sale first
      final saleId = await isar.collection<SaleModel>().put(sale);

      // Insert all sale items and link them
      for (final item in saleItems) {
        item.sale.value = sale;

        // Ensure product link is set — fetch from DB to guarantee proper ID
        if (item.product.value != null && item.product.value!.id > 0) {
          final productFromDb =
              await isar.collection<ProductModel>().get(item.product.value!.id);
          if (productFromDb != null) {
            item.product.value = productFromDb;
            // Decrement stock on the fresh DB copy
            productFromDb.stockQuantity -= item.quantity;
            if (productFromDb.stockQuantity < 0) {
              productFromDb.stockQuantity = 0;
            }
            productFromDb.updatedAt = DateTime.now();
            await isar.collection<ProductModel>().put(productFromDb);
          }
        }

        await isar.collection<SaleItemModel>().put(item);
        // Explicitly save IsarLinks
        await item.sale.save();
        await item.product.save();
      }

      // Update customer debt if credit sale
      if (customerId != null) {
        final customer = await isar.collection<CustomerModel>().get(customerId);
        if (customer != null) {
          final saleRecord = await isar.collection<SaleModel>().get(saleId);
          if (saleRecord != null) {
            // For credit sales, add to debt balance
            customer.debtBalance += saleRecord.finalAmount;
            customer.updatedAt = DateTime.now();
            await isar.collection<CustomerModel>().put(customer);
          }
        }
      }

      return saleId;
    });
  }

  Future<List<SaleItemModel>> getSaleItems(int saleId) async {
    final sale = await isar.collection<SaleModel>().get(saleId);
    if (sale == null) return [];
    await sale.items.load();
    // Explicitly load product links for each sale item
    for (final item in sale.items) {
      await item.product.load();
    }
    return sale.items.toList();
  }

  Future<List<SaleModel>> getByCustomerId(int customerId) async {
    // Use indexed customerId field for efficient querying
    return await isar
        .collection<SaleModel>()
        .filter()
        .customerIdEqualTo(customerId)
        .sortByDateDesc()
        .findAll();
  }
}
