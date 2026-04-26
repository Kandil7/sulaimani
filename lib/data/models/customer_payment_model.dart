import 'package:isar/isar.dart';

part 'customer_payment_model.g.dart';

@collection
class CustomerPaymentModel {
  Id id = Isar.autoIncrement;

  @Index()
  late int customerId;

  late double amount;

  late DateTime paymentDate;

  /// The sale ID this payment is linked to (optional — for credit settlement)
  int? linkedSaleId;

  /// Optional note for the payment
  String? note;

  /// Payment type: 'full_settlement', 'partial', 'adjustment'
  late String paymentType;

  late DateTime createdAt;
}
