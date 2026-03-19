import 'dart:async';
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
import 'package:shop_keeper_project/features/inventory/domain/usecases/get_products.dart';
import 'package:shop_keeper_project/features/inventory/domain/usecases/add_product.dart';
import 'package:shop_keeper_project/features/inventory/domain/usecases/update_stock.dart';
import 'package:shop_keeper_project/features/inventory/domain/usecases/delete_product.dart';
import 'package:shop_keeper_project/features/inventory/domain/usecases/get_product_by_barcode.dart';
import 'package:shop_keeper_project/features/sales/domain/usecases/get_sales_by_date.dart';
import 'package:shop_keeper_project/features/sales/domain/usecases/add_sale.dart';
import 'package:shop_keeper_project/features/sales/domain/usecases/get_sales_by_range.dart';
import 'package:shop_keeper_project/features/sales/domain/usecases/get_today_sales_summary.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/features/sales/domain/repositories/sales_repository.dart';
import 'package:shop_keeper_project/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:shop_keeper_project/features/sales/data/datasources/sales_local_data_source.dart';
import 'package:shop_keeper_project/features/sales/data/datasources/sales_remote_data_source.dart';
import 'package:shop_keeper_project/features/expenses/domain/usecases/get_expenses_by_date.dart';
import 'package:shop_keeper_project/features/expenses/domain/usecases/add_expense.dart';
import 'package:shop_keeper_project/features/expenses/domain/usecases/get_today_expenses_summary.dart';
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
import 'package:shop_keeper_project/services/local_image_service.dart';
import 'package:shop_keeper_project/services/security_service.dart';
import 'package:shop_keeper_project/services/pin_service.dart';
import 'package:shop_keeper_project/services/biometric_auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop_keeper_project/core/routing/app_router.dart';
import 'package:shop_keeper_project/services/report_service.dart';

final sl = GetIt.instance;

Future<void> init({bool isDemoMode = false}) async {
  await Hive.initFlutter();
  
  if (!isDemoMode) {
    // External
    final firestore = FirebaseFirestore.instance;
    firestore.settings = const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
    sl.registerLazySingleton(() => firestore);
    sl.registerLazySingleton(() => FirebaseAuth.instance);
  }

  // Features - Auth
  sl.registerLazySingleton(() => AuthCubit(
    authRepository: sl(), 
    pinService: sl(),
    biometricService: sl(),
  ));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: isDemoMode ? null : sl<FirebaseAuth>(), 
        firestore: isDemoMode ? null : sl<FirebaseFirestore>()
      ));

  // Features - Inventory
  sl.registerFactory(() => InventoryCubit(
        getProducts: sl(),
        addProductUseCase: sl(),
        updateStockUseCase: sl(),
        deleteProductUseCase: sl(),
        getProductByBarcodeUseCase: sl(),
      ));
  
  // Use Cases
  sl.registerLazySingleton(() => GetSalesByDate(sl()));
  sl.registerLazySingleton(() => AddSale(sl()));
  sl.registerLazySingleton(() => GetTodaySalesSummary(sl()));
  sl.registerLazySingleton(() => GetSalesByRange(sl()));
  sl.registerLazySingleton(() => GetExpensesByDate(sl()));
  sl.registerLazySingleton(() => AddExpense(sl()));
  sl.registerLazySingleton(() => GetTodayExpensesSummary(sl()));
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => AddProduct(sl()));
  sl.registerLazySingleton(() => UpdateStock(sl()));
  sl.registerLazySingleton(() => DeleteProduct(sl()));
  sl.registerLazySingleton(() => GetProductByBarcode(sl()));

  // Repository
  sl.registerLazySingleton<InventoryRepository>(
      () => InventoryRepositoryImpl(
        localDataSource: sl(), 
        remoteDataSource: sl(),
        localImageService: sl(),
      ));
  sl.registerLazySingleton<InventoryLocalDataSource>(
      () => InventoryLocalDataSourceImpl(productBox: sl(), logBox: sl()));
  sl.registerLazySingleton<InventoryRemoteDataSource>(
      () => InventoryRemoteDataSourceImpl(firestore: isDemoMode ? null : sl<FirebaseFirestore>()));

  // Features - Sales
  sl.registerFactory(() => SalesCubit(
        getSalesByDate: sl(),
        getSalesByRange: sl(),
        addSaleUseCase: sl(),
        getSummary: sl(),
      ));
  sl.registerLazySingleton<SalesRepository>(
      () => SalesRepositoryImpl(localDataSource: sl(), remoteDataSource: sl(), inventoryRepository: sl()));
  sl.registerLazySingleton<SalesLocalDataSource>(() => SalesLocalDataSourceImpl(saleBox: sl()));
  sl.registerLazySingleton<SalesRemoteDataSource>(
      () => SalesRemoteDataSourceImpl(firestore: isDemoMode ? null : sl<FirebaseFirestore>()));

  // Features - Expenses
  sl.registerFactory(() => ExpensesCubit(
        getExpensesByDate: sl(),
        addExpenseUseCase: sl(),
        getSummary: sl(),
      ));
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

  sl.registerLazySingleton(() => LocalImageService());
  sl.registerLazySingleton(() => ReportService(sl()));
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => PinService(sl()));
  sl.registerLazySingleton(() => BiometricAuthService());
  sl.registerLazySingleton(() => SecurityService(sl()));
  sl.registerLazySingleton(() => AppRouter(sl()));

  // Hive Adapters
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ProductTableAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SaleTableAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ExpenseTableAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(InventoryLogTableAdapter());

  // Hive Boxes with timeouts to prevent hangs
  Future<Box<T>> openBoxWithTimeout<T>(String name) async {
    return await Hive.openBox<T>(name).timeout(
      const Duration(seconds: 3),
      onTimeout: () => throw TimeoutException('Failed to open Hive box: $name'),
    );
  }

  try {
    final productBox = await openBoxWithTimeout<ProductTable>(AppConstants.productsBox);
    final logBox = await openBoxWithTimeout<InventoryLogTable>(AppConstants.inventoryLogsBox);
    final saleBox = await openBoxWithTimeout<SaleTable>(AppConstants.salesBox);
    final expenseBox = await openBoxWithTimeout<ExpenseTable>(AppConstants.expensesBox);

    sl.registerLazySingleton(() => productBox);
    sl.registerLazySingleton(() => logBox);
    sl.registerLazySingleton(() => saleBox);
    sl.registerLazySingleton(() => expenseBox);
  } catch (e) {
    // If boxes fail to open, the app might be unstable, but we still register them to avoid crashes
    // though they might be empty or throw errors later.
    rethrow;
  }
}
