import 'package:isar/isar.dart';
import '../../models/customer_payment_model.dart';

class CustomerPaymentLocalDatasource {
  final Isar isar;

  CustomerPaymentLocalDatasource(this.isar);

  Future<List<CustomerPaymentModel>> getByCustomerId(int customerId) async {
    return await isar.customerPaymentModels
        .filter()
        .customerIdEqualTo(customerId)
        .sortByPaymentDateDesc()
        .findAll();
  }

  Future<int> insert(CustomerPaymentModel payment) async {
    return await isar.writeTxn(() async {
      return await isar.customerPaymentModels.put(payment);
    });
  }

  Future<bool> delete(int id) async {
    return await isar.writeTxn(() async {
      return await isar.customerPaymentModels.delete(id);
    });
  }

  Future<double> getTotalPaymentsForCustomer(int customerId) async {
    final payments = await getByCustomerId(customerId);
    double total = 0.0;
    for (final p in payments) {
      total += p.amount;
    }
    return total;
  }
}
