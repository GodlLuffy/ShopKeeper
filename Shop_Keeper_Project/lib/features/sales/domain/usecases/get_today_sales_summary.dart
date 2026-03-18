import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/sales_repository.dart';

class GetTodaySalesSummary implements UseCase<double, NoParams> {
  final SalesRepository repository;

  GetTodaySalesSummary(this.repository);

  @override
  Future<Either<Failure, double>> call(NoParams params) async {
    return await repository.getTodaySalesSummary();
  }
}
