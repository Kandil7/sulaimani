import 'package:isar/isar.dart';
import '../../models/customer_model.dart';

class CustomerLocalDatasource {
  final Isar isar;

  CustomerLocalDatasource(this.isar);

  Future<List<CustomerModel>> getAll() async {
    return await isar.customerModels.where().findAll();
  }

  Future<CustomerModel?> getById(int id) async {
    return await isar.customerModels.get(id);
  }

  Future<int> insert(CustomerModel customer) async {
    return await isar.writeTxn(() async {
      return await isar.customerModels.put(customer);
    });
  }

  Future<void> update(CustomerModel customer) async {
    await isar.writeTxn(() async {
      await isar.customerModels.put(customer);
    });
  }

  Future<bool> delete(int id) async {
    return await isar.writeTxn(() async {
      return await isar.customerModels.delete(id);
    });
  }

  Future<List<CustomerModel>> getByName(String query) async {
    final lowerQuery = query.toLowerCase();
    return await isar.customerModels
        .filter()
        .nameContains(lowerQuery, caseSensitive: false)
        .findAll();
  }

  Future<CustomerModel?> getByIds(List<int> ids) async {
    return await isar.customerModels
        .getAll(ids)
        .then((list) => list.firstWhere((c) => c != null, orElse: () => null));
  }
}
