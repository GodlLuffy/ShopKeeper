import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/inventory_repository.dart';

class UpdateStock implements UseCase<void, UpdateStockParams> {
  final InventoryRepository repository;

  UpdateStock(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateStockParams params) async {
    return await repository.updateStock(
      params.productId,
      params.quantityChange,
      params.action,
    );
  }
}

class UpdateStockParams extends Equatable {
  final String productId;
  final int quantityChange;
  final String action;

  const UpdateStockParams({
    required this.productId,
    required this.quantityChange,
    required this.action,
  });

  @override
  List<Object> get props => [productId, quantityChange, action];
}
