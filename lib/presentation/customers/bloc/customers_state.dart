import 'package:equatable/equatable.dart';

abstract class CustomersState extends Equatable {
  const CustomersState();
  @override
  List<Object?> get props => [];
}

class CustomersInitial extends CustomersState {}

class CustomersLoading extends CustomersState {}

class CustomersLoaded extends CustomersState {
  final List<Customer> customers;
  final List<Customer> filteredCustomers;
  final String searchQuery;

  const CustomersLoaded({
    required this.customers,
    required this.filteredCustomers,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [customers, filteredCustomers, searchQuery];
}

class CustomersError extends CustomersState {
  final String message;
  const CustomersError(this.message);
  @override
  List<Object?> get props => [message];
}

class Customer extends Equatable {
  final int id;
  final String name;
  final String phone;
  final double debtBalance;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.debtBalance,
    required this.createdAt,
  });

  bool get hasDebt => debtBalance > 0;

  @override
  List<Object?> get props => [id, name, phone, debtBalance, createdAt];
}
