import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import '../../../domain/repositories/generic_repository.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/customer_payment_model.dart';
import '../../../data/datasources/local/customer_local_datasource.dart';
import '../../../core/di/injection_container.dart';
import 'customers_event.dart';
import 'customers_state.dart';

class CustomersBloc extends Bloc<CustomersEvent, CustomersState> {
  final GenericRepository<CustomerModel> repository;
  late final CustomerLocalDatasource _customerDatasource;
  late final Isar _isar;

  CustomersBloc({required this.repository}) : super(CustomersInitial()) {
    _customerDatasource = sl<CustomerLocalDatasource>();
    _isar = sl<Isar>();
    on<LoadCustomers>(_onLoadCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
    on<SelectCustomer>(_onSelectCustomer);
    on<FilterByDebt>(_onFilterByDebt);
    on<SortCustomers>(_onSortCustomers);
    on<RecordPayment>(_onRecordPayment);
  }

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomersState> emit,
  ) async {
    emit(CustomersLoading());
    try {
      final customers = await repository.getAll();
      customers.sort((a, b) => a.name.compareTo(b.name));

      emit(CustomersLoaded(
        customers: customers,
        filteredCustomers: customers,
        selectedCustomer: customers.isNotEmpty ? customers.first : null,
      ));
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
        final filtered = _applyFilters(
          currentState.customers,
          currentState.showOnlyWithDebt,
          currentState.sortField,
          currentState.sortAscending,
        );
        emit(currentState.copyWith(
          filteredCustomers: filtered,
          searchQuery: '',
        ));
      } else {
        final filtered = currentState.customers
            .where((c) =>
                c.name.toLowerCase().contains(event.query.toLowerCase()) ||
                c.phone.contains(event.query))
            .toList();
        final sorted = _applySorting(
            filtered, currentState.sortField, currentState.sortAscending);
        emit(currentState.copyWith(
          filteredCustomers: sorted,
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
      if (await _customerDatasource.phoneExists(event.phone)) {
        emit(const CustomersError('رقم التليفون مسجل بالفعل لعميل آخر'));
        return;
      }

      final customer = CustomerModel()
        ..name = event.name
        ..phone = event.phone
        ..address = event.address
        ..debtBalance = 0.0
        ..createdAt = DateTime.now();
      await repository.insert(customer);
      add(LoadCustomers());
      emit(const CustomerOperationSuccess('تمت إضافة العميل بنجاح'));
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<CustomersState> emit,
  ) async {
    try {
      if (await _customerDatasource.phoneExists(
        event.customer.phone,
        excludeCustomerId: event.customer.id,
      )) {
        emit(const CustomersError('رقم التليفون مسجل بالفعل لعميل آخر'));
        return;
      }

      event.customer.updatedAt = DateTime.now();
      await repository.update(event.customer);
      add(LoadCustomers());
      emit(const CustomerOperationSuccess('تم تحديث بيانات العميل بنجاح'));
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomersState> emit,
  ) async {
    try {
      await repository.delete(event.id);
      add(LoadCustomers());
      emit(const CustomerOperationSuccess('تم حذف العميل بنجاح'));
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  Future<void> _onSelectCustomer(
    SelectCustomer event,
    Emitter<CustomersState> emit,
  ) async {
    final currentState = state;
    if (currentState is CustomersLoaded) {
      if (event.id == null) {
        emit(currentState.copyWith(clearSelectedCustomer: true));
      } else {
        final customer = currentState.customers.firstWhere(
          (c) => c.id == event.id,
          orElse: () => currentState.customers.first,
        );
        emit(currentState.copyWith(selectedCustomer: customer));
      }
    }
  }

  Future<void> _onFilterByDebt(
    FilterByDebt event,
    Emitter<CustomersState> emit,
  ) async {
    final currentState = state;
    if (currentState is CustomersLoaded) {
      final baseList = currentState.searchQuery.isEmpty
          ? currentState.customers
          : currentState.customers
              .where((c) =>
                  c.name
                      .toLowerCase()
                      .contains(currentState.searchQuery.toLowerCase()) ||
                  c.phone.contains(currentState.searchQuery))
              .toList();

      final filtered = _applyFilters(
        baseList,
        event.showOnlyWithDebt,
        currentState.sortField,
        currentState.sortAscending,
      );

      emit(currentState.copyWith(
        filteredCustomers: filtered,
        showOnlyWithDebt: event.showOnlyWithDebt,
      ));
    }
  }

  Future<void> _onSortCustomers(
    SortCustomers event,
    Emitter<CustomersState> emit,
  ) async {
    final currentState = state;
    if (currentState is CustomersLoaded) {
      final baseList = currentState.searchQuery.isEmpty
          ? currentState.customers
          : currentState.customers
              .where((c) =>
                  c.name
                      .toLowerCase()
                      .contains(currentState.searchQuery.toLowerCase()) ||
                  c.phone.contains(currentState.searchQuery))
              .toList();

      final filtered = _applySorting(baseList, event.field, event.ascending);

      emit(currentState.copyWith(
        filteredCustomers: filtered,
        sortField: event.field,
        sortAscending: event.ascending,
      ));
    }
  }

  Future<void> _onRecordPayment(
    RecordPayment event,
    Emitter<CustomersState> emit,
  ) async {
    try {
      final customers = await repository.getAll();
      final customer = customers.firstWhere((c) => c.id == event.customerId);

      if (event.amount <= 0) {
        emit(const CustomersError('يجب أن يكون المبلغ أكبر من صفر'));
        return;
      }

      if (event.amount > customer.debtBalance) {
        emit(const CustomersError('المبلغ المدفوع أكبر من الدين الحالي'));
        return;
      }

      await _isar.writeTxn(() async {
        final payment = CustomerPaymentModel()
          ..customerId = event.customerId
          ..amount = event.amount
          ..paymentDate = DateTime.now()
          ..paymentType = event.amount == customer.debtBalance
              ? 'full_settlement'
              : 'partial'
          ..note = event.note
          ..createdAt = DateTime.now();

        payment.customer.value = customer;
        await _isar.customerPaymentModels.put(payment);
        await payment.customer.save();

        customer.debtBalance -= event.amount;
        if (customer.debtBalance < 0) customer.debtBalance = 0;
        customer.updatedAt = DateTime.now();
        await _isar.customerModels.put(customer);
      });

      add(LoadCustomers());
      emit(const CustomerOperationSuccess('تم تسجيل الدفعة بنجاح'));
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  List<CustomerModel> _applyFilters(
    List<CustomerModel> customers,
    bool showOnlyWithDebt,
    String sortField,
    bool sortAscending,
  ) {
    var filtered = showOnlyWithDebt
        ? customers.where((c) => c.debtBalance > 0).toList()
        : customers;
    return _applySorting(filtered, sortField, sortAscending);
  }

  List<CustomerModel> _applySorting(
    List<CustomerModel> customers,
    String sortField,
    bool ascending,
  ) {
    final sorted = List<CustomerModel>.from(customers);
    switch (sortField) {
      case 'name':
        sorted.sort((a, b) =>
            ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
        break;
      case 'debt':
        sorted.sort((a, b) => ascending
            ? a.debtBalance.compareTo(b.debtBalance)
            : b.debtBalance.compareTo(a.debtBalance));
        break;
      case 'date':
        sorted.sort((a, b) => ascending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
    }
    return sorted;
  }
}
