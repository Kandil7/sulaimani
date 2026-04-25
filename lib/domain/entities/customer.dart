import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final int? id;
  final String name;
  final String phone;
  final double debtBalance;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Customer({
    this.id,
    required this.name,
    required this.phone,
    this.debtBalance = 0.0,
    required this.createdAt,
    this.updatedAt,
  });

  bool get hasDebt => debtBalance > 0;

  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    double? debtBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      debtBalance: debtBalance ?? this.debtBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, phone, debtBalance, createdAt, updatedAt];
}
