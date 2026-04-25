import 'package:equatable/equatable.dart';

abstract class CustomersEvent extends Equatable {
  const CustomersEvent();
  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomersEvent {}

class SearchCustomers extends CustomersEvent {
  final String query;
  const SearchCustomers(this.query);
  @override
  List<Object?> get props => [query];
}

class AddCustomer extends CustomersEvent {
  final String name;
  final String phone;
  const AddCustomer({required this.name, required this.phone});
  @override
  List<Object?> get props => [name, phone];
}

class UpdateCustomerDebt extends CustomersEvent {
  final int customerId;
  final double amount;
  const UpdateCustomerDebt({required this.customerId, required this.amount});
  @override
  List<Object?> get props => [customerId, amount];
}

class RecordPayment extends CustomersEvent {
  final int customerId;
  final double amount;
  const RecordPayment({required this.customerId, required this.amount});
  @override
  List<Object?> get props => [customerId, amount];
}
