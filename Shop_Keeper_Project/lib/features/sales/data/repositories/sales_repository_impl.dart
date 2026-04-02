import 'package:dartz/dartz.dart';
import 'package:shop_keeper_project/core/error/failures.dart';
import 'package:shop_keeper_project/features/sales/data/datasources/sales_local_data_source.dart';
import 'package:shop_keeper_project/features/sales/data/datasources/sales_remote_data_source.dart';
import 'package:shop_keeper_project/features/sales/data/models/sale_model.dart';
import 'package:shop_keeper_project/features/sales/data/models/sale_mapper.dart';
import 'package:shop_keeper_project/features/sales/domain/entities/sale_entity.dart';
import 'package:shop_keeper_project/features/sales/domain/repositories/sales_repository.dart';
import 'package:shop_keeper_project/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:uuid/uuid.dart';

import 'package:shop_keeper_project/features/sales/domain/entities/sales_summary.dart';

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
      return Right(localSales.map((t) => SaleMapper.toEntity(SaleModel.fromTable(t))).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SaleEntity>>> getSalesByRange(DateTime start, DateTime end) async {
    try {
      // For now, let's use remote if available.
      final user = await localDataSource.getSalesByDate(DateTime.now()); // Need userId
      final userId = user.isNotEmpty ? user.first.userId : 'unknown';
      
      final remoteSales = await remoteDataSource.getSalesByRange(userId, start, end);
      return Right(remoteSales.map((m) => SaleMapper.toEntity(m)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SaleEntity>> addSale(SaleEntity sale) async {
    try {
      final saleId = sale.id.isEmpty ? const Uuid().v4() : sale.id;
      final saleWithId = SaleEntity(
        id: saleId,
        productId: sale.productId,
        productName: sale.productName,
        quantitySold: sale.quantitySold,
        salePrice: sale.salePrice,
        totalAmount: sale.totalAmount,
        totalProfit: sale.totalProfit,
        date: sale.date,
        userId: sale.userId,
      );

      final model = SaleMapper.toModel(saleWithId);
      
      // 1. Save sale locally
      await localDataSource.saveSale(model.toTable(isSynced: false));
      
      // 2. Automatically update inventory stock
      final stockResult = await inventoryRepository.updateStock(
        sale.productId, 
        -sale.quantitySold, 
        'SALE',
      );

      return stockResult.fold(
        (failure) => Left(failure),
        (_) {
           _syncSaleToRemote(model);
           return Right(saleWithId);
        }
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SalesSummary>> getTodaySalesSummary() async {
    try {
      final aggregate = await localDataSource.getTodaySalesAggregate();
      return Right(SalesSummary(
        totalRevenue: aggregate['revenue'] ?? 0.0,
        totalProfit: aggregate['profit'] ?? 0.0,
        orderCount: aggregate['count'] ?? 0,
      ));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  void _syncSaleToRemote(SaleModel model) async {
    try {
      await remoteDataSource.saveSale(model);
    } catch (_) {
      // Periodic sync will handle it
    }
  }
}
