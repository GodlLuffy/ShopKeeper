import 'package:dartz/dartz.dart';
import 'package:shop_keeper_project/core/error/failures.dart';
import 'package:shop_keeper_project/features/inventory/data/datasources/inventory_local_data_source.dart';
import 'package:shop_keeper_project/features/inventory/data/datasources/inventory_remote_data_source.dart';
import 'package:shop_keeper_project/features/inventory/data/models/product_model.dart';
import 'package:shop_keeper_project/features/inventory/data/models/product_mapper.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:shop_keeper_project/database/tables/inventory_log_table.dart';
import 'package:shop_keeper_project/services/local_image_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource localDataSource;
  final InventoryRemoteDataSource remoteDataSource;
  final LocalImageService localImageService;

  InventoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.localImageService,
  });

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      final localProducts = await localDataSource.getProducts();
      return Right(localProducts.map((t) => ProductMapper.toEntity(ProductModel.fromTable(t))).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> addProduct(ProductEntity product, {File? imageFile, String? barcode}) async {
    try {
      final productId = product.id.isEmpty ? const Uuid().v4() : product.id;
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await localImageService.processAndSaveImage(imageFile);
      }
      final productWithData = ProductEntity(
        id: productId,
        name: product.name,
        category: product.category,
        buyPrice: product.buyPrice,
        sellPrice: product.sellPrice,
        stockQuantity: product.stockQuantity,
        minStockAlert: product.minStockAlert,
        userId: product.userId,
        createdAt: product.createdAt,
        imageUrl: imageUrl ?? product.imageUrl,
        barcode: barcode ?? product.barcode,
      );

      final model = ProductMapper.toModel(productWithData);
      await localDataSource.saveProduct(model.toTable(isSynced: false));

      _syncProductToRemote(model);

      return Right(productWithData);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(ProductEntity product, {File? imageFile, String? barcode}) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await localImageService.processAndSaveImage(imageFile);
      }

      final productWithData = ProductEntity(
        id: product.id,
        name: product.name,
        category: product.category,
        buyPrice: product.buyPrice,
        sellPrice: product.sellPrice,
        stockQuantity: product.stockQuantity,
        minStockAlert: product.minStockAlert,
        userId: product.userId,
        createdAt: product.createdAt,
        imageUrl: imageUrl ?? product.imageUrl,
        barcode: barcode ?? product.barcode,
      );

      final model = ProductMapper.toModel(productWithData);
      await localDataSource.saveProduct(model.toTable(isSynced: false));

      _syncProductToRemote(model);

      return Right(productWithData);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await localDataSource.deleteProduct(id);
      remoteDataSource.deleteProduct(id);
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
      
      // Phase 5: Prevent negative stock
      if (newStock < 0) {
        return const Left(CacheFailure('Insufficient stock for this operation.'));
      }
      
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
      
      // Phase 5: Atomic Sync to remote
      _atomicSyncStock(productTable.userId, productId, quantityChange);
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  void _syncProductToRemote(ProductModel model) async {
    try {
      await remoteDataSource.saveProduct(model);
    } catch (_) {
      // Background sync handled by SyncService
    }
  }

  void _atomicSyncStock(String userId, String productId, int quantityChange) async {
    try {
      await remoteDataSource.updateStockAtomic(userId, productId, quantityChange);
    } catch (_) {
      // If atomic update fails (offline), we should mark for sync
      // Currently SyncService handles full doc sync, which is a fallback.
    }
  }
  @override
  Future<Either<Failure, ProductEntity?>> getProductByBarcode(String barcode) async {
    try {
      final products = await localDataSource.getProducts();
      try {
        final table = products.firstWhere((p) => p.barcode == barcode);
        return Right(ProductMapper.toEntity(ProductModel.fromTable(table)));
      } catch (_) {
        return const Right(null);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
