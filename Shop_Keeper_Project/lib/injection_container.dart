import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:shop_keeper_project/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shop_keeper_project/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:shop_keeper_project/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:shop_keeper_project/features/inventory/data/datasources/inventory_local_data_source.dart';
import 'package:shop_keeper_project/features/inventory/data/datasources/inventory_remote_data_source.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/features/sales/domain/repositories/sales_repository.dart';
import 'package:shop_keeper_project/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:shop_keeper_project/features/sales/data/datasources/sales_local_data_source.dart';
import 'package:shop_keeper_project/features/sales/data/datasources/sales_remote_data_source.dart';
import 'package:shop_keeper_project/features/expenses/presentation/bloc/expenses_cubit.dart';
import 'package:shop_keeper_project/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:shop_keeper_project/features/expenses/data/repositories/expenses_repository_impl.dart';
import 'package:shop_keeper_project/features/expenses/data/datasources/expenses_local_data_source.dart';
import 'package:shop_keeper_project/features/expenses/data/datasources/expenses_remote_data_source.dart';
import 'package:shop_keeper_project/features/ai_assistant/presentation/bloc/ai_assistant_cubit.dart';
import 'package:shop_keeper_project/database/tables/product_table.dart';
import 'package:shop_keeper_project/database/tables/sale_table.dart';
import 'package:shop_keeper_project/database/tables/expense_table.dart';
import 'package:shop_keeper_project/database/tables/inventory_log_table.dart';
import 'package:shop_keeper_project/core/constants/app_constants.dart';
import 'package:shop_keeper_project/services/sync_service.dart';
import 'package:shop_keeper_project/services/ai_assistant_service.dart';

final sl = GetIt.instance;

Future<void> init({bool isDemoMode = false}) async {
  await Hive.initFlutter();
  
  if (!isDemoMode) {
    // External
    sl.registerLazySingleton(() => FirebaseFirestore.instance);
    sl.registerLazySingleton(() => FirebaseAuth.instance);
  }

  // Features - Auth
  sl.registerFactory(() => AuthCubit(authRepository: sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: isDemoMode ? null : sl<FirebaseAuth>(), 
        firestore: isDemoMode ? null : sl<FirebaseFirestore>()
      ));

  // Features - Inventory
  sl.registerFactory(() => InventoryCubit(repository: sl()));
  sl.registerLazySingleton<InventoryRepository>(
      () => InventoryRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()));
  sl.registerLazySingleton<InventoryLocalDataSource>(
      () => InventoryLocalDataSourceImpl(productBox: sl(), logBox: sl()));
  sl.registerLazySingleton<InventoryRemoteDataSource>(
      () => InventoryRemoteDataSourceImpl(firestore: isDemoMode ? null : sl<FirebaseFirestore>()));

  // Features - Sales
  sl.registerFactory(() => SalesCubit(repository: sl()));
  sl.registerLazySingleton<SalesRepository>(
      () => SalesRepositoryImpl(localDataSource: sl(), remoteDataSource: sl(), inventoryRepository: sl()));
  sl.registerLazySingleton<SalesLocalDataSource>(() => SalesLocalDataSourceImpl(saleBox: sl()));
  sl.registerLazySingleton<SalesRemoteDataSource>(
      () => SalesRemoteDataSourceImpl(firestore: isDemoMode ? null : sl<FirebaseFirestore>()));

  // Features - Expenses
  sl.registerFactory(() => ExpensesCubit(repository: sl()));
  sl.registerLazySingleton<ExpensesRepository>(
      () => ExpensesRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()));
  sl.registerLazySingleton<ExpensesLocalDataSource>(() => ExpensesLocalDataSourceImpl(expenseBox: sl()));
  sl.registerLazySingleton<ExpensesRemoteDataSource>(
      () => ExpensesRemoteDataSourceImpl(firestore: isDemoMode ? null : sl<FirebaseFirestore>()));

  // Features - AI Assistant
  sl.registerFactory(() => AIAssistantCubit(assistantService: sl()));
  sl.registerLazySingleton(() => AIAssistantService(
    saleBox: sl(),
    expenseBox: sl(),
    productBox: sl(),
  ));

  // Services
  sl.registerLazySingleton(() => SyncService(
        firestore: isDemoMode ? null : sl<FirebaseFirestore>(),
        auth: isDemoMode ? null : sl<FirebaseAuth>(),
        productBox: sl(),
        saleBox: sl(),
        expenseBox: sl(),
      ));

  // Hive Adapters
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ProductTableAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SaleTableAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ExpenseTableAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(InventoryLogTableAdapter());

  // Hive Boxes
  final productBox = await Hive.openBox<ProductTable>(AppConstants.productsBox);
  final logBox = await Hive.openBox<InventoryLogTable>(AppConstants.inventoryLogsBox);
  final saleBox = await Hive.openBox<SaleTable>(AppConstants.salesBox);
  final expenseBox = await Hive.openBox<ExpenseTable>(AppConstants.expensesBox);

  sl.registerLazySingleton(() => productBox);
  sl.registerLazySingleton(() => logBox);
  sl.registerLazySingleton(() => saleBox);
  sl.registerLazySingleton(() => expenseBox);
}
