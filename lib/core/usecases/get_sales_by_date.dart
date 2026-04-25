import '../../domain/repositories/sale_repository.dart';
import '../../domain/entities/sale.dart';

class GetSalesByDate {
  final SaleRepository repository;

  GetSalesByDate(this.repository);

  Future<List<Sale>> call(DateTime from, DateTime to) async {
    return await repository.getByDateRange(from, to);
  }
}
