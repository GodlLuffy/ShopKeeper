import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/expense_entity.dart';
import '../repositories/expenses_repository.dart';

class AddExpense implements UseCase<ExpenseEntity, ExpenseEntity> {
  final ExpensesRepository repository;

  AddExpense(this.repository);

  @override
  Future<Either<Failure, ExpenseEntity>> call(ExpenseEntity expense) async {
    final validation = expense.validate();
    return await validation.fold(
      (failure) async => Left(failure),
      (_) async => await repository.addExpense(expense),
    );
  }
}
