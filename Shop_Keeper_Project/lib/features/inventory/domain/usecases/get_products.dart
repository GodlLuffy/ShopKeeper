import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/inventory_repository.dart';

class GetProducts implements UseCase<List<ProductEntity>, NoParams> {
  final InventoryRepository repository;

  GetProducts(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(NoParams params) async {
    return await repository.getProducts();
  }
}
