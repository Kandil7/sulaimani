import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import '../../data/datasources/local/database_service.dart';
import '../../data/datasources/local/product_local_datasource.dart';
import '../../data/datasources/local/customer_local_datasource.dart';
import '../../data/datasources/local/customer_payment_local_datasource.dart';
import '../../data/datasources/local/sale_local_datasource.dart';
import '../../data/datasources/local/alerts_local_datasource.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/sale_model.dart';
import '../../data/models/sale_item_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/repositories/isar_generic_repository.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/repositories/sale_repository_impl.dart';
import '../../data/repositories/alerts_repository_impl.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/repositories/generic_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../../presentation/products/bloc/products_bloc.dart';
import '../../presentation/pos/bloc/pos_bloc.dart';
import '../../presentation/dashboard/bloc/dashboard_bloc.dart';
import '../../presentation/customers/bloc/customers_bloc.dart';
import '../../presentation/alerts/bloc/alerts_bloc.dart';
import '../../presentation/reports/bloc/reports_bloc.dart';
import '../../presentation/settings/bloc/settings_bloc.dart';
import '../../presentation/settings/bloc/backup_bloc.dart';
import '../../presentation/invoices/bloc/invoices_bloc.dart';
import '../usecases/get_product_stats.dart';
import '../usecases/search_products.dart';
import '../usecases/get_expiring_products.dart';
import '../usecases/get_sales_by_date.dart';
import '../usecases/get_report_data.dart';
import '../services/data_backup_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Database Setup
  final databaseService = DatabaseService();
  await databaseService.init();
  sl.registerLazySingleton(() => databaseService);

  // ====== Data Sources ======
  sl.registerLazySingleton(
    () => ProductLocalDatasource(sl<DatabaseService>().isar),
  );
  sl.registerLazySingleton(
    () => CustomerLocalDatasource(sl<DatabaseService>().isar),
  );
  sl.registerLazySingleton(
    () => CustomerPaymentLocalDatasource(sl<DatabaseService>().isar),
  );
  sl.registerLazySingleton(
    () => SaleLocalDatasource(sl<DatabaseService>().isar),
  );
  sl.registerLazySingleton(
    () => AlertsLocalDatasource(sl<DatabaseService>().isar),
  );

  // ====== Domain Repositories (Abstract Interfaces) ======
  // ProductRepository - handled via ProductRepositoryImpl
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl<ProductLocalDatasource>()),
  );
  // CustomerRepository - handled via CustomerRepositoryImpl
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(sl<CustomerLocalDatasource>()),
  );
  // SaleRepository - handled via SaleRepositoryImpl
  sl.registerLazySingleton<SaleRepository>(
    () => SaleRepositoryImpl(sl<SaleLocalDatasource>()),
  );
  // AlertsRepository - handled via AlertsRepositoryImpl
  sl.registerLazySingleton<AlertsRepository>(
    () => AlertsRepositoryImpl(sl<AlertsLocalDatasource>()),
  );

  // ====== Generic Repositories (for BLoCs) ======
  sl.registerLazySingleton<GenericRepository<ProductModel>>(
    () => IsarGenericRepository<ProductModel>(sl<DatabaseService>().isar),
  );
  sl.registerLazySingleton<GenericRepository<CategoryModel>>(
    () => IsarGenericRepository<CategoryModel>(sl<DatabaseService>().isar),
  );
  sl.registerLazySingleton<GenericRepository<SaleModel>>(
    () => IsarGenericRepository<SaleModel>(sl<DatabaseService>().isar),
  );
  sl.registerLazySingleton<GenericRepository<SaleItemModel>>(
    () => IsarGenericRepository<SaleItemModel>(sl<DatabaseService>().isar),
  );
  sl.registerLazySingleton<GenericRepository<CustomerModel>>(
    () => IsarGenericRepository<CustomerModel>(sl<DatabaseService>().isar),
  );

  // ====== Use Cases ======
  sl.registerLazySingleton(
    () => GetProductStats(sl<ProductRepository>()),
  );
  sl.registerLazySingleton(
    () => SearchProducts(sl<ProductRepository>()),
  );
  sl.registerLazySingleton(
    () => GetExpiringProducts(sl<ProductRepository>()),
  );
  sl.registerLazySingleton(
    () => GetSalesByDate(sl<SaleRepository>()),
  );
  sl.registerLazySingleton(
    () => GetReportData(
      saleRepository: sl<SaleRepository>(),
      productRepository: sl<ProductRepository>(),
      customerRepository: sl<CustomerRepository>(),
    ),
  );

  // ====== BLoCs ======
  sl.registerFactory(() => ProductsBloc(repository: sl()));
  sl.registerFactory(() => PosBloc(
        productRepository: sl(),
        saleRepository: sl(),
        saleItemRepository: sl(),
        customerRepository: sl(),
        saleDatasource: sl<SaleLocalDatasource>(),
        settingsRepository: sl<SettingsRepository>(),
      ));
  sl.registerFactory(() => DashboardBloc(
        productRepository: sl(),
        saleRepository: sl(),
        customerRepository: sl(),
      ));
  sl.registerFactory(() => CustomersBloc(repository: sl()));
  sl.registerFactory(() => AlertsBloc(repository: sl()));
  sl.registerFactory(() => ReportsBloc(
        saleRepository: sl<GenericRepository<SaleModel>>(),
        saleItemRepository: sl<GenericRepository<SaleItemModel>>(),
        customerRepository: sl<GenericRepository<CustomerModel>>(),
      ));
  sl.registerLazySingleton(() => SettingsRepository(sl<DatabaseService>()));

  sl.registerLazySingleton(() => SettingsBloc(
        repository: sl<SettingsRepository>(),
        databaseService: sl<DatabaseService>(),
      ));

  // ====== Backup Service ======
  sl.registerLazySingleton(() => DataBackupService(
        productDatasource: sl<ProductLocalDatasource>(),
        customerDatasource: sl<CustomerLocalDatasource>(),
        saleDatasource: sl<SaleLocalDatasource>(),
        databaseService: sl<DatabaseService>(),
        settingsRepository: sl<SettingsRepository>(),
      ));

  sl.registerFactory(() => BackupBloc(backupService: sl<DataBackupService>()));

  sl.registerFactory(() => InvoicesBloc(
        saleDatasource: sl<SaleLocalDatasource>(),
        isar: sl<DatabaseService>().isar,
        settingsRepository: sl<SettingsRepository>(),
      ));

  // Expose Isar directly for clients that need it
  sl.registerLazySingleton<Isar>(() => sl<DatabaseService>().isar);
}
