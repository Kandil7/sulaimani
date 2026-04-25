import 'package:equatable/equatable.dart';

enum ProductType { medicine, pesticide }

class Product extends Equatable {
  final int? id;
  final String barcode;
  final String name;
  final String? scientificName;
  final String? description;
  final double purchasePrice;
  final double sellingPrice;
  final int stockQuantity;
  final int minimumStock;
  final DateTime? expiryDate;
  final ProductType type;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Product({
    this.id,
    required this.barcode,
    required this.name,
    this.scientificName,
    this.description,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.minimumStock,
    this.expiryDate,
    required this.type,
    required this.createdAt,
    this.updatedAt,
  });

  double get profitMargin => sellingPrice - purchasePrice;
  double get profitPercentage =>
      purchasePrice > 0 ? (profitMargin / purchasePrice) * 100 : 0;

  bool get isLowStock => stockQuantity <= minimumStock;
  bool get isOutOfStock => stockQuantity <= 0;

  bool get isExpired {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry =
        DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    return today.isAfter(expiry) || today.isAtSameMomentAs(expiry);
  }

  bool get isExpiringSoon {
    if (expiryDate == null || isExpired) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry =
        DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    final daysRemaining = expiry.difference(today).inDays;
    return daysRemaining <= 30;
  }

  Product copyWith({
    int? id,
    String? barcode,
    String? name,
    String? scientificName,
    String? description,
    double? purchasePrice,
    double? sellingPrice,
    int? stockQuantity,
    int? minimumStock,
    DateTime? expiryDate,
    ProductType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      description: description ?? this.description,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minimumStock: minimumStock ?? this.minimumStock,
      expiryDate: expiryDate ?? this.expiryDate,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        barcode,
        name,
        scientificName,
        description,
        purchasePrice,
        sellingPrice,
        stockQuantity,
        minimumStock,
        expiryDate,
        type,
        createdAt,
        updatedAt,
      ];
}
