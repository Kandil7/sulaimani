import '../entities/customer.dart';
import 'generic_repository.dart';

abstract class CustomerRepository extends GenericRepository<Customer> {
  Future<List<Customer>> getAll();
  Future<Customer?> getById(int id);
  Future<int> insert(Customer customer);
  Future<void> update(Customer customer);
  Future<bool> delete(int id);
  Future<List<Customer>> getByName(String query);
}
