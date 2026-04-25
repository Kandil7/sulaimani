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
  final Customer? selectedCustomer;
  final bool showOnlyWithDebt;
  final String sortField;
  final bool sortAscending;

  const CustomersLoaded({
    required this.customers,
    required this.filteredCustomers,
    this.searchQuery = '',
    this.selectedCustomer,
    this.showOnlyWithDebt = false,
    this.sortField = 'name',
    this.sortAscending = true,
  });

  CustomersLoaded copyWith({
    List<Customer>? customers,
    List<Customer>? filteredCustomers,
    String? searchQuery,
    Customer? selectedCustomer,
    bool? showOnlyWithDebt,
    String? sortField,
    bool? sortAscending,
    bool clearSelectedCustomer = false,
  }) {
    return CustomersLoaded(
      customers: customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCustomer: clearSelectedCustomer
          ? null
          : (selectedCustomer ?? this.selectedCustomer),
      showOnlyWithDebt: showOnlyWithDebt ?? this.showOnlyWithDebt,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  @override
  List<Object?> get props => [
        customers,
        filteredCustomers,
        searchQuery,
        selectedCustomer,
        showOnlyWithDebt,
        sortField,
        sortAscending,
      ];
}

class CustomerOperationSuccess extends CustomersState {
  final String message;
  const CustomerOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
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
  final DateTime? updatedAt;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.debtBalance,
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
