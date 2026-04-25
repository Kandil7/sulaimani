import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    debugPrint('NotificationService: Initialized');
  }

  Future<void> showExpiryNotification(List<ProductAlert> products) async {
    if (products.isEmpty) return;
    await initialize();

    debugPrint(
        'NotificationService: Showing expiry notification for ${products.length} products');
  }

  Future<void> showLowStockNotification(int count) async {
    if (count <= 0) return;
    await initialize();

    debugPrint(
        'NotificationService: Showing low stock notification for $count products');
  }

  Future<void> checkAndShowAlerts(List<ProductModel> products) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final expired = <ProductAlert>[];
    final expiringSoon = <ProductAlert>[];
    final lowStock = <ProductAlert>[];

    for (final p in products) {
      if (p.expiryDate != null) {
        final expiryDay = DateTime(
          p.expiryDate!.year,
          p.expiryDate!.month,
          p.expiryDate!.day,
        );

        if (today.isAfter(expiryDay)) {
          expired.add(ProductAlert(
            productId: p.id,
            productName: p.name,
            type: 'Expired',
            expiryDate: p.expiryDate,
            quantity: p.stockQuantity,
            minimumStock: p.minimumStock,
          ));
        } else if (expiryDay.difference(today).inDays <= 30) {
          expiringSoon.add(ProductAlert(
            productId: p.id,
            productName: p.name,
            type: 'Expiring Soon',
            expiryDate: p.expiryDate,
            quantity: p.stockQuantity,
            minimumStock: p.minimumStock,
          ));
        }
      }

      if (p.stockQuantity <= p.minimumStock) {
        lowStock.add(ProductAlert(
          productId: p.id,
          productName: p.name,
          type: 'Low Stock',
          quantity: p.stockQuantity,
          minimumStock: p.minimumStock,
        ));
      }
    }

    final allAlerts = [...expired, ...expiringSoon, ...lowStock];
    if (allAlerts.isNotEmpty) {
      await showExpiryNotification(allAlerts);
      if (lowStock.isNotEmpty) {
        await showLowStockNotification(lowStock.length);
      }
    }
  }
}

// Helper class for alerts (matching ProductAlert from alerts_state)
class ProductAlert {
  final int productId;
  final String productName;
  final String type;
  final DateTime? expiryDate;
  final int quantity;
  final int minimumStock;

  ProductAlert({
    required this.productId,
    required this.productName,
    required this.type,
    this.expiryDate,
    required this.quantity,
    required this.minimumStock,
  });
}
