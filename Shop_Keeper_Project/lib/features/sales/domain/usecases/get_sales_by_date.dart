import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sale_entity.dart';
import '../repositories/sales_repository.dart';

class GetSalesByDate implements UseCase<List<SaleEntity>, DateTime> {
  final SalesRepository repository;

  GetSalesByDate(this.repository);

  @override
  Future<Either<Failure, List<SaleEntity>>> call(DateTime date) async {
    return await repository.getSalesByDate(date);
  }
}
