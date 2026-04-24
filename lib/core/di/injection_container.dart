import 'package:get_it/get_it.dart';
import '../../data/datasources/local/database_service.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/sale_model.dart';
import '../../data/repositories/isar_generic_repository.dart';
import '../../domain/repositories/generic_repository.dart';
import '../../presentation/products/bloc/products_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Database Setup
  final databaseService = DatabaseService();
  await databaseService.init();
  sl.registerLazySingleton(() => databaseService);

  // Repositories
  sl.registerLazySingleton<GenericRepository<ProductModel>>(
    () => IsarGenericRepository<ProductModel>(sl<DatabaseService>().isar),
  );
  sl.registerLazySingleton<GenericRepository<CategoryModel>>(
    () => IsarGenericRepository<CategoryModel>(sl<DatabaseService>().isar),
  );
  sl.registerLazySingleton<GenericRepository<SaleModel>>(
    () => IsarGenericRepository<SaleModel>(sl<DatabaseService>().isar),
  );

  // Blocs
  sl.registerFactory(() => ProductsBloc(repository: sl()));
}
