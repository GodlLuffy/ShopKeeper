import 'package:dartz/dartz.dart';
import 'package:shop_keeper_project/core/error/failures.dart';
import 'package:shop_keeper_project/features/inventory/data/datasources/inventory_local_data_source.dart';
import 'package:shop_keeper_project/features/inventory/data/datasources/inventory_remote_data_source.dart';
import 'package:shop_keeper_project/features/inventory/data/models/product_model.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:shop_keeper_project/database/tables/inventory_log_table.dart';
import 'package:uuid/uuid.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource localDataSource;
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      final localProducts = await localDataSource.getProducts();
      return Right(localProducts.map((t) => ProductModel.fromTable(t)).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> addProduct(ProductEntity product) async {
    try {
      final model = product as ProductModel; // Should ideally use a mapper
      await localDataSource.saveProduct(model.toTable(isSynced: false));
      
      // Async sync to remote
      _syncProductToRemote(model);
      
      return Right(product);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(ProductEntity product) async {
    return addProduct(product); // Logic is same for save/update in Hive
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await localDataSource.deleteProduct(id);
      remoteDataSource.deleteProduct(id); // Fire and forget
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStock(
    String productId, 
    int quantityChange, 
    String action,
  ) async {
    try {
      final products = await localDataSource.getProducts();
      final productTable = products.firstWhere((p) => p.id == productId);
      
      final previousStock = productTable.stockQuantity;
      final newStock = previousStock + quantityChange;
      
      productTable.stockQuantity = newStock;
      await localDataSource.saveProduct(productTable);
      
      // Log the movement
      final log = InventoryLogTable(
        id: const Uuid().v4(),
        productId: productId,
        productName: productTable.name,
        action: action,
        quantity: quantityChange,
        previousStock: previousStock,
        newStock: newStock,
        timestamp: DateTime.now(),
        userId: productTable.userId,
      );
      
      await localDataSource.saveInventoryLog(log);
      
      // Sync to remote
      _syncProductToRemote(ProductModel.fromTable(productTable));
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  void _syncProductToRemote(ProductModel model) async {
    try {
      await remoteDataSource.saveProduct(model);
      // Update local synced status (Optional refinement)
    } catch (_) {
      // Background sync will handle it if retry logic is added to SyncService
    }
  }
}
