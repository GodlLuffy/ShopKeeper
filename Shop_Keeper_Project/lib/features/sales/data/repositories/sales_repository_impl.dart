import 'package:dartz/dartz.dart';
import 'package:shop_keeper_project/core/error/failures.dart';
import 'package:shop_keeper_project/features/sales/data/datasources/sales_local_data_source.dart';
import 'package:shop_keeper_project/features/sales/data/datasources/sales_remote_data_source.dart';
import 'package:shop_keeper_project/features/sales/data/models/sale_model.dart';
import 'package:shop_keeper_project/features/sales/domain/entities/sale_entity.dart';
import 'package:shop_keeper_project/features/sales/domain/repositories/sales_repository.dart';
import 'package:shop_keeper_project/features/inventory/domain/repositories/inventory_repository.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesLocalDataSource localDataSource;
  final SalesRemoteDataSource remoteDataSource;
  final InventoryRepository inventoryRepository;

  SalesRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.inventoryRepository,
  });

  @override
  Future<Either<Failure, List<SaleEntity>>> getSalesByDate(DateTime date) async {
    try {
      final localSales = await localDataSource.getSalesByDate(date);
      return Right(localSales.map((t) => SaleModel.fromTable(t)).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SaleEntity>> addSale(SaleEntity sale) async {
    try {
      final model = sale as SaleModel;
      
      // 1. Save sale locally
      await localDataSource.saveSale(model.toTable(isSynced: false));
      
      // 2. Automatically update inventory stock
      await inventoryRepository.updateStock(
        sale.productId, 
        -sale.quantitySold, 
        'SALE',
      );
      
      // 3. Async sync to remote
      _syncSaleToRemote(model);
      
      return Right(sale);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTodaySalesSummary() async {
    try {
      final total = await localDataSource.getTodaySalesSummary();
      return Right(total);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  void _syncSaleToRemote(SaleModel model) async {
    try {
      await remoteDataSource.saveSale(model);
    } catch (_) {
      // Background sync handled by SyncService later
    }
  }
}
