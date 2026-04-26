import 'package:isar/isar.dart';

part 'customer_model.g.dart';

@collection
class CustomerModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  @Index(unique: true)
  late String phone;

  double debtBalance = 0.0;

  late DateTime createdAt;

  DateTime? updatedAt;
}
