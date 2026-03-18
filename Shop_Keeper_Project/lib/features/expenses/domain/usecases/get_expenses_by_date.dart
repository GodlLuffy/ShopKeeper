import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/expense_entity.dart';
import '../repositories/expenses_repository.dart';

class GetExpensesByDate implements UseCase<List<ExpenseEntity>, DateTime> {
  final ExpensesRepository repository;

  GetExpensesByDate(this.repository);

  @override
  Future<Either<Failure, List<ExpenseEntity>>> call(DateTime date) async {
    return await repository.getExpensesByDate(date);
  }
}
