import 'package:equatable/equatable.dart';
import '../../../data/models/customer_model.dart';

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

class UpdateCustomer extends CustomersEvent {
  final CustomerModel customer;
  const UpdateCustomer(this.customer);
  @override
  List<Object?> get props => [customer];
}

class DeleteCustomer extends CustomersEvent {
  final int id;
  const DeleteCustomer(this.id);
  @override
  List<Object?> get props => [id];
}

class SelectCustomer extends CustomersEvent {
  final int? id;
  const SelectCustomer(this.id);
  @override
  List<Object?> get props => [id];
}

class FilterByDebt extends CustomersEvent {
  final bool showOnlyWithDebt;
  const FilterByDebt(this.showOnlyWithDebt);
  @override
  List<Object?> get props => [showOnlyWithDebt];
}

class SortCustomers extends CustomersEvent {
  final String field;
  final bool ascending;
  const SortCustomers({required this.field, required this.ascending});
  @override
  List<Object?> get props => [field, ascending];
}

class RecordPayment extends CustomersEvent {
  final int customerId;
  final double amount;
  final String? note;
  const RecordPayment(
      {required this.customerId, required this.amount, this.note});
  @override
  List<Object?> get props => [customerId, amount, note];
}
