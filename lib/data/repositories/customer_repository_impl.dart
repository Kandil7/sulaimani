import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/local/customer_local_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDatasource _datasource;

  CustomerRepositoryImpl(this._datasource);

  Customer _mapModelToEntity(CustomerModel model) {
    return Customer(
      id: model.id,
      name: model.name,
      phone: model.phone,
      debtBalance: model.debtBalance,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  @override
  Future<List<Customer>> getAll() async {
    final models = await _datasource.getAll();
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<Customer?> getById(int id) async {
    final model = await _datasource.getById(id);
    return model != null ? _mapModelToEntity(model) : null;
  }

  @override
  Future<int> insert(Customer customer) async {
    final model = CustomerModel()
      ..name = customer.name
      ..phone = customer.phone
      ..debtBalance = customer.debtBalance
      ..createdAt = customer.createdAt
      ..updatedAt = customer.updatedAt;
    return await _datasource.insert(model);
  }

  @override
  Future<void> update(Customer customer) async {
    final model = CustomerModel()
      ..id = customer.id ?? 0
      ..name = customer.name
      ..phone = customer.phone
      ..debtBalance = customer.debtBalance
      ..createdAt = customer.createdAt
      ..updatedAt = DateTime.now();
    await _datasource.update(model);
  }

  @override
  Future<bool> delete(int id) async {
    return await _datasource.delete(id);
  }

  @override
  Future<List<Customer>> getByName(String query) async {
    final models = await _datasource.getByName(query);
    return models.map(_mapModelToEntity).toList();
  }
}
