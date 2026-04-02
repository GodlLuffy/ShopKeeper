import 'package:dartz/dartz.dart';
import 'package:shop_keeper_project/features/sales/domain/entities/sales_summary.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/sales_repository.dart';

class GetTodaySalesSummary implements UseCase<SalesSummary, NoParams> {
  final SalesRepository repository;

  GetTodaySalesSummary(this.repository);

  @override
  Future<Either<Failure, SalesSummary>> call(NoParams params) async {
    return await repository.getTodaySalesSummary();
  }
}
