import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sale_entity.dart';
import '../repositories/sales_repository.dart';

class AddSale implements UseCase<SaleEntity, SaleEntity> {
  final SalesRepository repository;

  AddSale(this.repository);

  @override
  Future<Either<Failure, SaleEntity>> call(SaleEntity sale) async {
    final validation = sale.validate();
    return await validation.fold(
      (failure) async => Left(failure),
      (_) async => await repository.addSale(sale),
    );
  }
}
