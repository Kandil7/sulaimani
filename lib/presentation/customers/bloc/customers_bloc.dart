import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/generic_repository.dart';
import '../../../data/models/customer_model.dart';
import 'customers_event.dart';
import 'customers_state.dart';

class CustomersBloc extends Bloc<CustomersEvent, CustomersState> {
  final GenericRepository<CustomerModel> repository;

  CustomersBloc({required this.repository}) : super(CustomersInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<RecordPayment>(_onRecordPayment);
  }

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomersState> emit,
  ) async {
    emit(CustomersLoading());
    try {
      final customers = await repository.getAll();
      final customerList = customers
          .map((c) => Customer(
                id: c.id,
                name: c.name,
                phone: c.phone,
                debtBalance: c.debtBalance,
                createdAt: c.createdAt,
              ))
          .toList();
      emit(CustomersLoaded(
          customers: customerList, filteredCustomers: customerList));
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  Future<void> _onSearchCustomers(
    SearchCustomers event,
    Emitter<CustomersState> emit,
  ) async {
    final currentState = state;
    if (currentState is CustomersLoaded) {
      if (event.query.isEmpty) {
        emit(CustomersLoaded(
          customers: currentState.customers,
          filteredCustomers: currentState.customers,
        ));
      } else {
        final filtered = currentState.customers
            .where((c) =>
                c.name.contains(event.query) || c.phone.contains(event.query))
            .toList();
        emit(CustomersLoaded(
          customers: currentState.customers,
          filteredCustomers: filtered,
          searchQuery: event.query,
        ));
      }
    }
  }

  Future<void> _onAddCustomer(
    AddCustomer event,
    Emitter<CustomersState> emit,
  ) async {
    try {
      final customer = CustomerModel()
        ..name = event.name
        ..phone = event.phone
        ..debtBalance = 0.0
        ..createdAt = DateTime.now();
      await repository.insert(customer);
      add(LoadCustomers());
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  Future<void> _onRecordPayment(
    RecordPayment event,
    Emitter<CustomersState> emit,
  ) async {
    try {
      final customers = await repository.getAll();
      final customer = customers.firstWhere((c) => c.id == event.customerId);
      customer.debtBalance = customer.debtBalance - event.amount;
      customer.updatedAt = DateTime.now();
      await repository.update(customer);
      add(LoadCustomers());
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }
}
