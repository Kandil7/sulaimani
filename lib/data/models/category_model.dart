import 'package:isar/isar.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String name;
  
  String? description;
  
  late DateTime createdAt;
  late DateTime updatedAt;
}
