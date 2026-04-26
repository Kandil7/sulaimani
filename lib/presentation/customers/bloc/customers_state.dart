import 'package:equatable/equatable.dart';
import '../../../data/models/customer_model.dart';

abstract class CustomersState extends Equatable {
  const CustomersState();
  @override
  List<Object?> get props => [];
}

class CustomersInitial extends CustomersState {}

class CustomersLoading extends CustomersState {}

class CustomersLoaded extends CustomersState {
  final List<CustomerModel> customers;
  final List<CustomerModel> filteredCustomers;
  final String searchQuery;
  final CustomerModel? selectedCustomer;
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
    List<CustomerModel>? customers,
    List<CustomerModel>? filteredCustomers,
    String? searchQuery,
    CustomerModel? selectedCustomer,
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
