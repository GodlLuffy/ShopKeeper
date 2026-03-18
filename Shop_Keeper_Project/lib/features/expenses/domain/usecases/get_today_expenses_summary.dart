import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/expenses_repository.dart';

class GetTodayExpensesSummary implements UseCase<double, NoParams> {
  final ExpensesRepository repository;

  GetTodayExpensesSummary(this.repository);

  @override
  Future<Either<Failure, double>> call(NoParams params) async {
    return await repository.getTodayExpensesSummary();
  }
}
