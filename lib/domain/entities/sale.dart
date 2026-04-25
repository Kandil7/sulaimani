import 'package:equatable/equatable.dart';

enum PaymentType { cash, credit }

class Sale extends Equatable {
  final int? id;
  final String invoiceNumber;
  final double totalAmount;
  final double paidAmount;
  final PaymentType paymentType;
  final int? customerId;
  final DateTime createdAt;

  const Sale({
    this.id,
    required this.invoiceNumber,
    required this.totalAmount,
    required this.paidAmount,
    required this.paymentType,
    this.customerId,
    required this.createdAt,
  });

  double get remainingAmount => totalAmount - paidAmount;
  bool get isFullyPaid => paidAmount >= totalAmount;
  bool get isCredit => paymentType == PaymentType.credit;

  Sale copyWith({
    int? id,
    String? invoiceNumber,
    double? totalAmount,
    double? paidAmount,
    PaymentType? paymentType,
    int? customerId,
    DateTime? createdAt,
  }) {
    return Sale(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentType: paymentType ?? this.paymentType,
      customerId: customerId ?? this.customerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        totalAmount,
        paidAmount,
        paymentType,
        customerId,
        createdAt,
      ];
}
