import 'package:isar/isar.dart';
import '../../domain/repositories/generic_repository.dart';

class IsarGenericRepository<T> implements GenericRepository<T> {
  final Isar isar;

  IsarGenericRepository(this.isar);

  @override
  Future<List<T>> getAll() async {
    return await isar.collection<T>().where().findAll();
  }

  @override
  Future<T?> getById(int id) async {
    return await isar.collection<T>().get(id);
  }

  @override
  Future<int> insert(T item) async {
    return await isar.writeTxn(() async {
      return await isar.collection<T>().put(item);
    });
  }

  @override
  Future<void> update(T item) async {
    await isar.writeTxn(() async {
      await isar.collection<T>().put(item);
    });
  }

  @override
  Future<bool> delete(int id) async {
    return await isar.writeTxn(() async {
      return await isar.collection<T>().delete(id);
    });
  }
}
