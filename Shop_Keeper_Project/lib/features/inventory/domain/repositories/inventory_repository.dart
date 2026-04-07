import 'package:dartz/dartz.dart';
import 'package:shop_keeper_project/core/error/failures.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'dart:io';

abstract class InventoryRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();
  Future<Either<Failure, ProductEntity>> addProduct(ProductEntity product, {File? imageFile, String? barcode});
  Future<Either<Failure, ProductEntity>> updateProduct(ProductEntity product, {File? imageFile, String? barcode});
  Future<Either<Failure, void>> deleteProduct(String id);
  Future<Either<Failure, void>> updateStock(String productId, int quantityChange, String action);
  Future<Either<Failure, ProductEntity?>> getProductByBarcode(String barcode);
}
