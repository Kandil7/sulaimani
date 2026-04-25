import '../../domain/entities/sale.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/sale_repository.dart';
import '../datasources/local/sale_local_datasource.dart';
import '../models/sale_model.dart';
import '../models/sale_item_model.dart';
import '../models/product_model.dart';

class SaleRepositoryImpl implements SaleRepository {
  final SaleLocalDatasource _datasource;

  SaleRepositoryImpl(this._datasource);

  Sale _mapModelToEntity(dynamic model) {
    return Sale(
      id: model.id,
      invoiceNumber: model.receiptNumber,
      totalAmount: model.totalAmount,
      paidAmount: model.finalAmount,
      paymentType:
          model.paymentMethod == 'cash' ? PaymentType.cash : PaymentType.credit,
      customerId: null,
      createdAt: model.createdAt,
    );
  }

  @override
  Future<List<Sale>> getAll() async {
    final models = await _datasource.getAll();
    return models.map((m) => _mapModelToEntity(m)).toList();
  }

  @override
  Future<Sale?> getById(int id) async {
    final model = await _datasource.getById(id);
    return model != null ? _mapModelToEntity(model) : null;
  }

  @override
  Future<int> insert(Sale sale) async {
    throw UnimplementedError('Use createSale method instead');
  }

  @override
  Future<void> update(Sale sale) async {
    throw UnimplementedError('Use createSale method for updates');
  }

  @override
  Future<bool> delete(int id) async {
    return await _datasource.delete(id);
  }

  @override
  Future<List<Sale>> getByDateRange(DateTime from, DateTime to) async {
    final models = await _datasource.getByDateRange(from, to);
    return models.map((m) => _mapModelToEntity(m)).toList();
  }

  @override
  Future<Sale> createSale({
    required List<CartItem> items,
    required double totalAmount,
    required double discount,
    required double finalAmount,
    required String paymentType,
    int? customerId,
    double? paidAmount,
  }) async {
    // Generate receipt number
    final receiptNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';

    // Create SaleModel
    final saleModel = SaleModel()
      ..receiptNumber = receiptNumber
      ..date = DateTime.now()
      ..totalAmount = totalAmount
      ..discount = discount
      ..finalAmount = finalAmount
      ..paymentMethod = paymentType
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    // Create SaleItemModels
    final saleItems = <SaleItemModel>[];
    for (final item in items) {
      final saleItem = SaleItemModel()
        ..quantity = item.quantity
        ..unitPrice = item.unitPrice
        ..total = item.totalPrice;

      // Create product link
      final productModel = ProductModel()
        ..id = item.product.id ?? 0
        ..barcode = item.product.barcode
        ..name = item.product.name
        ..scientificName = item.product.scientificName ?? ''
        ..purchasePrice = item.product.purchasePrice
        ..sellingPrice = item.product.sellingPrice
        ..stockQuantity = item.product.stockQuantity
        ..minimumStock = item.product.minimumStock
        ..expiryDate = item.product.expiryDate
        ..createdAt = item.product.createdAt
        ..updatedAt = item.product.updatedAt ?? DateTime.now();

      saleItem.product.value = productModel;
      saleItems.add(saleItem);
    }

    // Create sale with atomic transaction
    final saleId = await _datasource.createSaleWithItems(
      saleItems: saleItems,
      sale: saleModel,
      customerId: customerId,
    );

    // Return the created sale entity
    return Sale(
      id: saleId,
      invoiceNumber: receiptNumber,
      totalAmount: totalAmount,
      paidAmount: paidAmount ?? finalAmount,
      paymentType:
          paymentType == 'cash' ? PaymentType.cash : PaymentType.credit,
      customerId: customerId,
      createdAt: DateTime.now(),
    );
  }
}
