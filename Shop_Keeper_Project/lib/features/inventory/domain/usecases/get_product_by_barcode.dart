import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/inventory_repository.dart';

class GetProductByBarcode implements UseCase<ProductEntity?, String> {
  final InventoryRepository repository;

  GetProductByBarcode(this.repository);

  @override
  Future<Either<Failure, ProductEntity?>> call(String barcode) async {
    return await repository.getProductByBarcode(barcode);
  }
}
