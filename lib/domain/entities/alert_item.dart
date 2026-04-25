import 'package:equatable/equatable.dart';

enum AlertType { expired, expiringSoon, lowStock }

class AlertItem extends Equatable {
  final int productId;
  final String productName;
  final AlertType type;
  final String message;
  final DateTime createdAt;

  const AlertItem({
    required this.productId,
    required this.productName,
    required this.type,
    required this.message,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [productId, productName, type, message, createdAt];
}
