abstract class GenericRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(int id);
  Future<int> insert(T item);
  Future<void> update(T item);
  Future<bool> delete(int id);
}
